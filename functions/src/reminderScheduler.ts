import * as admin from "firebase-admin";
import { generateReminder } from "./templates";
import { sendPushNotification, sendEmailReminder } from "./notifications";

interface TaskData {
  title: string;
  details: string;
  deadline: admin.firestore.Timestamp;
  isCompleted: boolean;
  intensity: number;
  reminderTypes: string[];
  userId: string;
}

interface ProfileData {
  email: string;
  fcmToken?: string;
  quietHoursStart: number;
  quietHoursEnd: number;
}

/**
 * Calculate the probability that a reminder should be sent in this 15-minute window.
 *
 * The algorithm:
 * - Base frequency scales with intensity (1-10)
 * - Frequency increases exponentially as deadline approaches
 * - Returns a probability (0-1) that a reminder should fire NOW
 */
function calculateReminderProbability(
  hoursRemaining: number,
  intensity: number
): number {
  // Normalize intensity to 0.1 - 1.0
  const normalizedIntensity = intensity / 10;

  let baseProbability: number;

  if (hoursRemaining <= 0) {
    // Overdue: high probability, scaled by intensity
    baseProbability = 0.6 * normalizedIntensity;
  } else if (hoursRemaining < 1) {
    // Less than 1 hour: very high
    baseProbability = 0.5 * normalizedIntensity;
  } else if (hoursRemaining < 6) {
    // Less than 6 hours: high
    baseProbability = 0.35 * normalizedIntensity;
  } else if (hoursRemaining < 24) {
    // Less than 1 day: moderate-high
    baseProbability = 0.2 * normalizedIntensity;
  } else if (hoursRemaining < 72) {
    // 1-3 days: moderate
    baseProbability = 0.1 * normalizedIntensity;
  } else if (hoursRemaining < 168) {
    // 3-7 days: low
    baseProbability = 0.04 * normalizedIntensity;
  } else {
    // 7+ days: very low
    baseProbability = 0.015 * normalizedIntensity;
  }

  // Cap at 0.8 to never guarantee a reminder every single interval
  return Math.min(baseProbability, 0.8);
}

/**
 * Check if the current hour falls within quiet hours.
 */
function isQuietHours(
  currentHour: number,
  quietStart: number,
  quietEnd: number
): boolean {
  if (quietStart <= quietEnd) {
    // e.g., quiet from 22 to 8 doesn't wrap — this case is start < end like 1-5
    // Actually for 22 to 8, start > end, so this handles e.g. 9 to 17
    return currentHour >= quietStart && currentHour < quietEnd;
  } else {
    // Wraps around midnight, e.g., 22 to 8
    return currentHour >= quietStart || currentHour < quietEnd;
  }
}

/**
 * Main scheduler function. Called every 15 minutes.
 * Iterates all users and their incomplete tasks, rolls the dice for each,
 * and sends reminders as appropriate.
 */
export async function processReminders(): Promise<void> {
  const db = admin.firestore();
  const usersSnapshot = await db.collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;

    // Get user profile for FCM token, email, and quiet hours
    const profileDoc = await db
      .collection("users")
      .doc(userId)
      .collection("profile")
      .doc("settings")
      .get();

    if (!profileDoc.exists) continue;
    const profile = profileDoc.data() as ProfileData;

    // Check quiet hours
    const currentHour = new Date().getHours();
    if (
      isQuietHours(
        currentHour,
        profile.quietHoursStart,
        profile.quietHoursEnd
      )
    ) {
      continue;
    }

    // Get all incomplete tasks for this user
    const tasksSnapshot = await db
      .collection("users")
      .doc(userId)
      .collection("tasks")
      .where("isCompleted", "==", false)
      .get();

    for (const taskDoc of tasksSnapshot.docs) {
      const task = taskDoc.data() as TaskData;
      const deadlineMs = task.deadline.toMillis();
      const hoursRemaining = (deadlineMs - Date.now()) / (1000 * 60 * 60);

      // Calculate probability and roll
      const probability = calculateReminderProbability(
        hoursRemaining,
        task.intensity
      );
      const roll = Math.random();

      if (roll > probability) continue;

      // Generate a reminder message
      const message = generateReminder(task.title, hoursRemaining);

      // Send via configured channels
      const sendPromises: Promise<unknown>[] = [];

      if (task.reminderTypes.includes("push") && profile.fcmToken) {
        sendPromises.push(
          sendPushNotification(profile.fcmToken, message)
        );
      }

      if (task.reminderTypes.includes("email") && profile.email) {
        sendPromises.push(sendEmailReminder(profile.email, message));
      }

      await Promise.all(sendPromises);
    }
  }
}

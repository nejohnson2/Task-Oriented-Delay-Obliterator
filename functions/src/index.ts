import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { processReminders } from "./reminderScheduler";

admin.initializeApp();

/**
 * Scheduled Cloud Function that runs every 15 minutes.
 * Evaluates all incomplete tasks across all users and randomly
 * sends reminders based on deadline proximity and intensity settings.
 */
export const reminderScheduler = onSchedule("every 15 minutes", async () => {
  console.log("Running reminder scheduler...");
  try {
    await processReminders();
    console.log("Reminder scheduler completed successfully.");
  } catch (error) {
    console.error("Reminder scheduler error:", error);
  }
});

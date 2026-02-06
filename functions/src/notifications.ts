import * as admin from "firebase-admin";
import { ReminderMessage } from "./templates";

/**
 * Send a push notification via FCM.
 */
export async function sendPushNotification(
  fcmToken: string,
  message: ReminderMessage
): Promise<boolean> {
  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: message.title,
        body: message.body,
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    });
    return true;
  } catch (error: unknown) {
    const err = error as { code?: string };
    // If the token is invalid, return false so we can clean it up
    if (
      err.code === "messaging/invalid-registration-token" ||
      err.code === "messaging/registration-token-not-registered"
    ) {
      console.warn(`Invalid FCM token, should be cleaned up: ${fcmToken}`);
      return false;
    }
    console.error("Error sending push notification:", error);
    return false;
  }
}

/**
 * Send an email reminder using the Firebase Trigger Email extension.
 * This writes a document to the `mail` collection, which the extension picks up.
 */
export async function sendEmailReminder(
  toEmail: string,
  message: ReminderMessage
): Promise<void> {
  try {
    await admin.firestore().collection("mail").add({
      to: toEmail,
      message: {
        subject: `T.O.D.O: ${message.title}`,
        html: `
          <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px;">
            <h2 style="color: #f97316; margin-bottom: 4px;">T.O.D.O</h2>
            <p style="color: #6b7280; font-size: 12px; margin-top: 0;">Task-Oriented Delay Obliterator</p>
            <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 16px 0;">
            <h3 style="margin-bottom: 8px;">${message.title}</h3>
            <p style="color: #374151; line-height: 1.6;">${message.body}</p>
            <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 16px 0;">
            <p style="color: #9ca3af; font-size: 12px;">Open the T.O.D.O app to manage your tasks.</p>
          </div>
        `,
      },
    });
  } catch (error) {
    console.error("Error queuing email:", error);
  }
}

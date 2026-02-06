export interface ReminderMessage {
  title: string;
  body: string;
}

type Urgency = "overdue" | "critical" | "soon" | "normal";

const templates: Record<Urgency, ReminderMessage[]> = {
  overdue: [
    {
      title: "Overdue Alert",
      body: "'{task}' is OVERDUE! Time to get it done right now.",
    },
    {
      title: "Past Deadline",
      body: "'{task}' was due {timeAgo}. Don't let it slip any further!",
    },
    {
      title: "Action Required",
      body: "OVERDUE: '{task}' needed your attention already. Get on it!",
    },
    {
      title: "No More Delays",
      body: "'{task}' is past due. The best time to start is NOW.",
    },
  ],
  critical: [
    {
      title: "Final Call",
      body: "'{task}' is due in less than a day! Lock in now.",
    },
    {
      title: "Hours Left",
      body: "'{task}' deadline is TODAY. You've got this — finish strong!",
    },
    {
      title: "Deadline Imminent",
      body: "'{task}' is due very soon. Drop everything and focus!",
    },
    {
      title: "Last Chance",
      body: "'{task}' — this is your last chance to get it done on time!",
    },
  ],
  soon: [
    {
      title: "Coming Up",
      body: "'{task}' is due {timeLeft}. Time to make progress!",
    },
    {
      title: "Don't Wait",
      body: "'{task}' needs your attention. Due {timeLeft}.",
    },
    {
      title: "Getting Close",
      body: "'{task}' is approaching fast. Have you started yet?",
    },
    {
      title: "Heads Up",
      body: "'{task}' is due {timeLeft}. Better get cracking!",
    },
  ],
  normal: [
    {
      title: "Friendly Nudge",
      body: "Have you thought about '{task}' today?",
    },
    {
      title: "T.O.D.O Reminder",
      body: "'{task}' is on your list — due {timeLeft}.",
    },
    {
      title: "Stay On Track",
      body: "You've got this! '{task}' is due {timeLeft}.",
    },
    {
      title: "Quick Check-In",
      body: "Just a nudge about '{task}'. Due {timeLeft}.",
    },
  ],
};

function getUrgency(hoursRemaining: number): Urgency {
  if (hoursRemaining <= 0) return "overdue";
  if (hoursRemaining < 24) return "critical";
  if (hoursRemaining < 72) return "soon";
  return "normal";
}

function formatTimeRemaining(hoursRemaining: number): string {
  if (hoursRemaining <= 0) {
    const hoursOverdue = Math.abs(hoursRemaining);
    if (hoursOverdue < 1) return "just now";
    if (hoursOverdue < 24)
      return `${Math.round(hoursOverdue)} hours ago`;
    return `${Math.round(hoursOverdue / 24)} days ago`;
  }
  if (hoursRemaining < 1)
    return `in ${Math.round(hoursRemaining * 60)} minutes`;
  if (hoursRemaining < 24)
    return `in ${Math.round(hoursRemaining)} hours`;
  return `in ${Math.round(hoursRemaining / 24)} days`;
}

export function generateReminder(
  taskTitle: string,
  hoursRemaining: number
): ReminderMessage {
  const urgency = getUrgency(hoursRemaining);
  const pool = templates[urgency];
  const template = pool[Math.floor(Math.random() * pool.length)];
  const timeStr = formatTimeRemaining(hoursRemaining);

  return {
    title: template.title,
    body: template.body
      .replace("{task}", taskTitle)
      .replace("{timeLeft}", timeStr)
      .replace("{timeAgo}", timeStr),
  };
}

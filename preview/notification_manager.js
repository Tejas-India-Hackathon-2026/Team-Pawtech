// PashuRakhshak Notification Manager
// Handles local browser push notification scheduling for vaccination reminders,
// medicine alarms, and rescue case updates.

const NOTIFICATION_PERMISSION_KEY = 'pashu_notif_permission';

/**
 * Request push notification permission from the browser.
 * @returns {Promise<boolean>} true if granted
 */
export async function requestNotificationPermission() {
  if (!('Notification' in window)) {
    console.warn('[Notifications] Browser does not support notifications.');
    return false;
  }

  if (Notification.permission === 'granted') return true;

  const permission = await Notification.requestPermission();
  localStorage.setItem(NOTIFICATION_PERMISSION_KEY, permission);
  return permission === 'granted';
}

/**
 * Schedule a local browser notification at a given delay.
 * @param {string} title - Notification title
 * @param {string} body  - Notification body text
 * @param {number} delayMs - Delay in milliseconds
 * @param {object} [options] - Additional notification options
 */
export function scheduleLocalNotification(title, body, delayMs = 0, options = {}) {
  if (Notification.permission !== 'granted') {
    console.warn('[Notifications] Permission not granted. Skipping:', title);
    return;
  }

  setTimeout(() => {
    const notif = new Notification(title, {
      body,
      icon: '/icons/icon-192.png',
      badge: '/icons/icon-192.png',
      tag: options.tag || 'pashu-default',
      requireInteraction: options.urgent || false,
      ...options
    });

    notif.onclick = () => {
      window.focus();
      if (options.screen) {
        // Navigate to relevant screen on click
        if (window.navigateTo) window.navigateTo(options.screen);
      }
      notif.close();
    };
  }, delayMs);
}

/**
 * Schedule a vaccination reminder notification.
 * @param {string} petName - Name of the pet
 * @param {string} vaccineName - Vaccine name
 * @param {Date} dueDate - Due date for the vaccination
 */
export function scheduleVaccinationReminder(petName, vaccineName, dueDate) {
  const now = new Date();
  const delayMs = Math.max(0, dueDate.getTime() - now.getTime() - 24 * 60 * 60 * 1000); // 1 day before

  scheduleLocalNotification(
    `💉 Vaccination Reminder — ${petName}`,
    `${vaccineName} is due tomorrow! Visit your vet to keep ${petName} protected.`,
    delayMs,
    { tag: `vaccine-${petName}`, screen: 'pet-health', urgent: true }
  );
}

/**
 * Schedule a daily medicine alarm for a pet.
 * @param {string} petName - Name of the pet
 * @param {string} medicineName - Medicine name
 * @param {number} hour - Hour of day (24h format, e.g. 20 for 8 PM)
 */
export function scheduleDailyMedicineAlarm(petName, medicineName, hour = 20) {
  const now = new Date();
  const nextAlarm = new Date();
  nextAlarm.setHours(hour, 0, 0, 0);
  if (nextAlarm <= now) nextAlarm.setDate(nextAlarm.getDate() + 1); // Next day

  const delayMs = nextAlarm.getTime() - now.getTime();
  scheduleLocalNotification(
    `💊 Medicine Time — ${petName}`,
    `Time to give ${medicineName} to ${petName}. Tap to view pet health.`,
    delayMs,
    { tag: `medicine-${petName}-${medicineName}`, screen: 'pet-health' }
  );
}

/**
 * Send an immediate SOS-dispatched notification to the user.
 * @param {string} animalType - Type of animal rescued
 * @param {string} location - Rescue location
 */
export function notifySosDispatched(animalType, location) {
  scheduleLocalNotification(
    '🚨 PashuRakhshak SOS Dispatched!',
    `Rescue squad dispatched for ${animalType} near ${location}. Stay with the animal if safe.`,
    500,
    { tag: 'sos-dispatch', urgent: true }
  );
}

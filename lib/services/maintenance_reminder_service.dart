import '../models/maintenance_reminder.dart';
import 'database_service.dart';
import 'notification_service.dart';

class MaintenanceReminderService {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notifications = NotificationService();

  Future<MaintenanceReminder> addReminder(MaintenanceReminder reminder) async {
    final id = await _db.insertReminder(reminder);
    final newReminder = reminder.copyWith(id: id);
    await _notifications.scheduleReminder(newReminder);
    return newReminder;
  }

  Future<List<MaintenanceReminder>> getReminders({int? vehicleId}) async {
    return await _db.getReminders(vehicleId: vehicleId);
  }

  Future<List<MaintenanceReminder>> getDueReminders() async {
    return await _db.getDueReminders();
  }

  Future<bool> updateReminder(MaintenanceReminder reminder) async {
    final result = await _db.updateReminder(reminder);
    if (result > 0) {
      if (reminder.isCompleted) {
        await _notifications.cancelReminder(reminder.id!);
      } else {
        await _notifications.scheduleReminder(reminder);
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteReminder(int id) async {
    final result = await _db.deleteReminder(id);
    if (result > 0) {
      await _notifications.cancelReminder(id);
      return true;
    }
    return false;
  }

  Future<void> rescheduleAllReminders() async {
    await _notifications.cancelAllReminders();
    final reminders = await _db.getReminders();
    for (final reminder in reminders) {
      if (!reminder.isCompleted) {
        await _notifications.scheduleReminder(reminder);
      }
    }
  }

  // Helper method to get the next due date based on frequency
  DateTime getNextDueDate(MaintenanceReminder reminder) {
    final now = DateTime.now();
    switch (reminder.frequency) {
      case 'monthly':
        return DateTime(now.year, now.month + 1, now.day);
      case 'yearly':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return reminder.dueDate;
    }
  }

  // Helper method to get the next due mileage based on frequency
  int? getNextDueMileage(MaintenanceReminder reminder, int currentMileage) {
    if (reminder.frequency == 'mileage' && reminder.repeatMiles != null) {
      return currentMileage + reminder.repeatMiles!;
    }
    return reminder.dueMileage;
  }
}

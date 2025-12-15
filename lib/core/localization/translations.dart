import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';

class AppLocalizations {
  AppLocalizations(this.language);

  final AppLanguage language;

  String t(String key) {
    final values = _translations[key];
    if (values == null) {
      return key;
    }
    return values[language] ?? values[AppLanguage.en] ?? key;
  }
}

final localizationProvider = Provider<AppLocalizations>((ref) {
  final lang = ref.watch(settingsControllerProvider).language;
  return AppLocalizations(lang);
});

final Map<String, Map<AppLanguage, String>> _translations = {
  // Settings
  'settings': {
    AppLanguage.en: 'Settings',
    AppLanguage.he: 'הגדרות',
  },
  'theme': {
    AppLanguage.en: 'Theme',
    AppLanguage.he: 'ערכת נושא',
  },
  'language': {
    AppLanguage.en: 'Language',
    AppLanguage.he: 'שפה',
  },
  'mainCountdown': {
    AppLanguage.en: 'Main Countdown',
    AppLanguage.he: 'ספירה לאחור ראשית',
  },
  'targetDate': {
    AppLanguage.en: 'Target Date',
    AppLanguage.he: 'תאריך יעד',
  },
  'startDate': {
    AppLanguage.en: 'Start Date (for progress ring)',
    AppLanguage.he: 'תאריך התחלה (לטבעת ההתקדמות)',
  },
  'menu': {
    AppLanguage.en: 'Menu',
    AppLanguage.he: 'תפריט',
  },

  // Navigation
  'timer': {
    AppLanguage.en: 'Timer',
    AppLanguage.he: 'טיימר',
  },
  'calendar': {
    AppLanguage.en: 'Calendar',
    AppLanguage.he: 'לוח שנה',
  },
  'todo': {
    AppLanguage.en: 'Todo',
    AppLanguage.he: 'משימות',
  },

  // Index page
  'countdowns': {
    AppLanguage.en: 'Countdowns',
    AppLanguage.he: 'ספירות לאחור',
  },
  'addTimer': {
    AppLanguage.en: 'Add Timer',
    AppLanguage.he: 'הוסף טיימר',
  },
  'createNewTimer': {
    AppLanguage.en: 'Create New Timer',
    AppLanguage.he: 'צור טיימר חדש',
  },
  'timerTitle': {
    AppLanguage.en: 'Timer Title',
    AppLanguage.he: 'כותרת הטיימר',
  },
  'timerEmoji': {
    AppLanguage.en: 'Emoji',
    AppLanguage.he: 'אימוג׳י',
  },
  'create': {
    AppLanguage.en: 'Create',
    AppLanguage.he: 'צור',
  },
  'cancel': {
    AppLanguage.en: 'Cancel',
    AppLanguage.he: 'ביטול',
  },
  'delete': {
    AppLanguage.en: 'Delete',
    AppLanguage.he: 'מחק',
  },
  'save': {
    AppLanguage.en: 'Save',
    AppLanguage.he: 'שמור',
  },
  'editTimer': {
    AppLanguage.en: 'Edit Timer',
    AppLanguage.he: 'ערוך טיימר',
  },
  'deleteTimer': {
    AppLanguage.en: 'Delete Timer?',
    AppLanguage.he: 'למחוק את הטיימר?',
  },
  'deleteTimerConfirm': {
    AppLanguage.en:
        'Are you sure you want to delete this timer? This action cannot be undone.',
    AppLanguage.he:
        'האם אתה בטוח שברצונך למחוק את הטיימר הזה? פעולה זו לא ניתנת לביטול.',
  },
  'importFromTodo': {
    AppLanguage.en: 'Import from Todo',
    AppLanguage.he: 'ייבוא ממשימות',
  },
  'selectTodo': {
    AppLanguage.en: 'Select a todo item',
    AppLanguage.he: 'בחר פריט משימה',
  },
  'noTodosWithDueDate': {
    AppLanguage.en: 'No todos with due dates',
    AppLanguage.he: 'אין משימות עם תאריך יעד',
  },
  'tapToSwitch': {
    AppLanguage.en: 'Tap to switch between days, hours, minutes, seconds',
    AppLanguage.he: 'לחץ כדי לעבור בין ימים, שעות, דקות, שניות',
  },
  'enterTimerTitle': {
    AppLanguage.en: 'Enter timer title',
    AppLanguage.he: 'הזן כותרת',
  },

  // Todo page
  'tasks': {
    AppLanguage.en: 'Tasks',
    AppLanguage.he: 'משימות',
  },
  'open': {
    AppLanguage.en: 'Open',
    AppLanguage.he: 'פתוחות',
  },
  'completed': {
    AppLanguage.en: 'Completed',
    AppLanguage.he: 'הושלמו',
  },
  'addTask': {
    AppLanguage.en: 'Add Task',
    AppLanguage.he: 'הוסף משימה',
  },
  'createNewTask': {
    AppLanguage.en: 'Create New Task',
    AppLanguage.he: 'צור משימה חדשה',
  },
  'taskTitle': {
    AppLanguage.en: 'Task Title',
    AppLanguage.he: 'כותרת המשימה',
  },
  'repeat': {
    AppLanguage.en: 'Repeat',
    AppLanguage.he: 'חזרה',
  },
  'noRepeat': {
    AppLanguage.en: 'No repeat',
    AppLanguage.he: 'ללא חזרה',
  },
  'daily': {
    AppLanguage.en: 'Daily',
    AppLanguage.he: 'יומי',
  },
  'weekly': {
    AppLanguage.en: 'Weekly',
    AppLanguage.he: 'שבועי',
  },
  'monthly': {
    AppLanguage.en: 'Monthly',
    AppLanguage.he: 'חודשי',
  },
  'yearly': {
    AppLanguage.en: 'Yearly',
    AppLanguage.he: 'שנתי',
  },
  'deleteTask': {
    AppLanguage.en: 'Delete Task?',
    AppLanguage.he: 'למחוק את המשימה?',
  },
  'deleteTaskConfirm': {
    AppLanguage.en:
        'Are you sure you want to delete this task? This action cannot be undone.',
    AppLanguage.he:
        'האם אתה בטוח שברצונך למחוק את המשימה הזו? פעולה זו לא ניתנת לביטול.',
  },
  'noOpenTasks': {
    AppLanguage.en: 'No open tasks',
    AppLanguage.he: 'אין משימות פתוחות',
  },
  'noCompletedTasks': {
    AppLanguage.en: 'No completed tasks',
    AppLanguage.he: 'אין משימות שהושלמו',
  },
  'viewAllTasks': {
    AppLanguage.en: 'View All Tasks',
    AppLanguage.he: 'צפה בכל המשימות',
  },
  'moreTasks': {
    AppLanguage.en: 'more tasks',
    AppLanguage.he: 'משימות נוספות',
  },
  'enterTaskTitle': {
    AppLanguage.en: 'Enter task title',
    AppLanguage.he: 'הזן כותרת משימה',
  },
  'optional': {
    AppLanguage.en: 'optional',
    AppLanguage.he: 'אופציונלי',
  },

  // Calendar
  'day': {
    AppLanguage.en: 'Day',
    AppLanguage.he: 'יום',
  },
  'week': {
    AppLanguage.en: 'Week',
    AppLanguage.he: 'שבוע',
  },
  'month': {
    AppLanguage.en: 'Month',
    AppLanguage.he: 'חודש',
  },
  'today': {
    AppLanguage.en: 'Today',
    AppLanguage.he: 'היום',
  },
  'noEvents': {
    AppLanguage.en: 'No events for this day',
    AppLanguage.he: 'אין אירועים ליום זה',
  },
  'createEvent': {
    AppLanguage.en: 'Create Event',
    AppLanguage.he: 'צור אירוע',
  },
  'createClass': {
    AppLanguage.en: 'Create Class',
    AppLanguage.he: 'צור שיעור',
  },
  'eventTitle': {
    AppLanguage.en: 'Event Title',
    AppLanguage.he: 'כותרת האירוע',
  },
  'time': {
    AppLanguage.en: 'Time',
    AppLanguage.he: 'שעה',
  },
  'duration': {
    AppLanguage.en: 'Duration',
    AppLanguage.he: 'משך',
  },
  'color': {
    AppLanguage.en: 'Color',
    AppLanguage.he: 'צבע',
  },
  'recurrence': {
    AppLanguage.en: 'Recurrence',
    AppLanguage.he: 'חזרה',
  },
  'none': {
    AppLanguage.en: 'None',
    AppLanguage.he: 'ללא',
  },
  'semesterSchedule': {
    AppLanguage.en: 'Semester Schedule',
    AppLanguage.he: 'מערכת סמסטר',
  },
  'semesterEndDate': {
    AppLanguage.en: 'Semester End Date',
    AppLanguage.he: 'תאריך סיום סמסטר',
  },
  'addClass': {
    AppLanguage.en: 'Add Class',
    AppLanguage.he: 'הוסף שיעור',
  },
  'className': {
    AppLanguage.en: 'Class Name',
    AppLanguage.he: 'שם השיעור',
  },
  'classType': {
    AppLanguage.en: 'Class Type',
    AppLanguage.he: 'סוג שיעור',
  },
  'lecture': {
    AppLanguage.en: 'Lecture',
    AppLanguage.he: 'הרצאה',
  },
  'tutorial': {
    AppLanguage.en: 'Tutorial',
    AppLanguage.he: 'תרגול',
  },
  'reinforcement': {
    AppLanguage.en: 'Reinforcement',
    AppLanguage.he: 'חיזוק',
  },
  'other': {
    AppLanguage.en: 'Other',
    AppLanguage.he: 'אחר',
  },
  'dayOfWeek': {
    AppLanguage.en: 'Day of Week',
    AppLanguage.he: 'יום בשבוע',
  },
  'sunday': {
    AppLanguage.en: 'Sunday',
    AppLanguage.he: 'ראשון',
  },
  'monday': {
    AppLanguage.en: 'Monday',
    AppLanguage.he: 'שני',
  },
  'tuesday': {
    AppLanguage.en: 'Tuesday',
    AppLanguage.he: 'שלישי',
  },
  'wednesday': {
    AppLanguage.en: 'Wednesday',
    AppLanguage.he: 'רביעי',
  },
  'thursday': {
    AppLanguage.en: 'Thursday',
    AppLanguage.he: 'חמישי',
  },
  'friday': {
    AppLanguage.en: 'Friday',
    AppLanguage.he: 'שישי',
  },
  'saturday': {
    AppLanguage.en: 'Saturday',
    AppLanguage.he: 'שבת',
  },
  'sun': {
    AppLanguage.en: 'Sun',
    AppLanguage.he: 'א׳',
  },
  'mon': {
    AppLanguage.en: 'Mon',
    AppLanguage.he: 'ב׳',
  },
  'tue': {
    AppLanguage.en: 'Tue',
    AppLanguage.he: 'ג׳',
  },
  'wed': {
    AppLanguage.en: 'Wed',
    AppLanguage.he: 'ד׳',
  },
  'thu': {
    AppLanguage.en: 'Thu',
    AppLanguage.he: 'ה׳',
  },
  'fri': {
    AppLanguage.en: 'Fri',
    AppLanguage.he: 'ו׳',
  },
  'sat': {
    AppLanguage.en: 'Sat',
    AppLanguage.he: 'ש׳',
  },

  // Time units
  'days': {
    AppLanguage.en: 'days',
    AppLanguage.he: 'ימים',
  },
  'hours': {
    AppLanguage.en: 'hours',
    AppLanguage.he: 'שעות',
  },
  'minutes': {
    AppLanguage.en: 'minutes',
    AppLanguage.he: 'דקות',
  },
  'seconds': {
    AppLanguage.en: 'seconds',
    AppLanguage.he: 'שניות',
  },
  'day_singular': {
    AppLanguage.en: 'day',
    AppLanguage.he: 'יום',
  },
  'hour_singular': {
    AppLanguage.en: 'hour',
    AppLanguage.he: 'שעה',
  },
  'minute_singular': {
    AppLanguage.en: 'minute',
    AppLanguage.he: 'דקה',
  },
  'second_singular': {
    AppLanguage.en: 'second',
    AppLanguage.he: 'שנייה',
  },

  // Duration
  'minutes15': {
    AppLanguage.en: '15 minutes',
    AppLanguage.he: '15 דקות',
  },
  'minutes30': {
    AppLanguage.en: '30 minutes',
    AppLanguage.he: '30 דקות',
  },
  'minutes45': {
    AppLanguage.en: '45 minutes',
    AppLanguage.he: '45 דקות',
  },
  'hour1': {
    AppLanguage.en: '1 hour',
    AppLanguage.he: 'שעה',
  },
  'hours15': {
    AppLanguage.en: '1.5 hours',
    AppLanguage.he: 'שעה וחצי',
  },
  'hours2': {
    AppLanguage.en: '2 hours',
    AppLanguage.he: 'שעתיים',
  },
  'hours3': {
    AppLanguage.en: '3 hours',
    AppLanguage.he: '3 שעות',
  },
  'hours4': {
    AppLanguage.en: '4 hours',
    AppLanguage.he: '4 שעות',
  },
  'hours6': {
    AppLanguage.en: '6 hours',
    AppLanguage.he: '6 שעות',
  },
  'hours8': {
    AppLanguage.en: '8 hours',
    AppLanguage.he: '8 שעות',
  },

  // General
  'until': {
    AppLanguage.en: 'until',
    AppLanguage.he: 'עד',
  },
  'graduation': {
    AppLanguage.en: 'Graduation',
    AppLanguage.he: 'סיום לימודים',
  },
  'done': {
    AppLanguage.en: 'done',
    AppLanguage.he: 'הושלמו',
  },
};

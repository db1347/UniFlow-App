import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/localization/app_language.dart';
import 'package:students_app/features/settings/application/settings_controller.dart';

class AppLocalizations {
  AppLocalizations(this.language);

  final AppLanguage language;

  String t(String key) {
    final values = _translations[key];
    if (values == null) return key;
    return values[language] ?? values[AppLanguage.en] ?? key;
  }
}

final localizationProvider = Provider<AppLocalizations>((ref) {
  final lang = ref.watch(settingsControllerProvider).language;
  return AppLocalizations(lang);
});

final Map<String, Map<AppLanguage, String>> _translations = {
  // ── Settings ────────────────────────────────────────────────────────────────
  'settings': {
    AppLanguage.en: 'Settings',
    AppLanguage.he: 'הגדרות',
    AppLanguage.ru: 'Настройки',
    AppLanguage.ar: 'الإعدادات',
  },
  'theme': {
    AppLanguage.en: 'Theme',
    AppLanguage.he: 'ערכת נושא',
    AppLanguage.ru: 'Тема',
    AppLanguage.ar: 'المظهر',
  },
  'language': {
    AppLanguage.en: 'Language',
    AppLanguage.he: 'שפה',
    AppLanguage.ru: 'Язык',
    AppLanguage.ar: 'اللغة',
  },
  'mainCountdown': {
    AppLanguage.en: 'Main Countdown',
    AppLanguage.he: 'ספירה לאחור ראשית',
    AppLanguage.ru: 'Основной обратный отсчёт',
    AppLanguage.ar: 'العداد التنازلي الرئيسي',
  },
  'targetDate': {
    AppLanguage.en: 'Target Date',
    AppLanguage.he: 'תאריך יעד',
    AppLanguage.ru: 'Целевая дата',
    AppLanguage.ar: 'تاريخ الهدف',
  },
  'startDate': {
    AppLanguage.en: 'Start Date (for progress ring)',
    AppLanguage.he: 'תאריך התחלה (לטבעת ההתקדמות)',
    AppLanguage.ru: 'Дата начала (для кольца прогресса)',
    AppLanguage.ar: 'تاريخ البداية (لحلقة التقدم)',
  },
  'menu': {
    AppLanguage.en: 'Menu',
    AppLanguage.he: 'תפריט',
    AppLanguage.ru: 'Меню',
    AppLanguage.ar: 'القائمة',
  },
  'close': {
    AppLanguage.en: 'Close',
    AppLanguage.he: 'סגור',
    AppLanguage.ru: 'Закрыть',
    AppLanguage.ar: 'إغلاق',
  },

  // ── Navigation ───────────────────────────────────────────────────────────────
  'timer': {
    AppLanguage.en: 'Timer',
    AppLanguage.he: 'טיימר',
    AppLanguage.ru: 'Таймер',
    AppLanguage.ar: 'المؤقت',
  },
  'calendar': {
    AppLanguage.en: 'Calendar',
    AppLanguage.he: 'לוח שנה',
    AppLanguage.ru: 'Календарь',
    AppLanguage.ar: 'التقويم',
  },
  'todo': {
    AppLanguage.en: 'Todo',
    AppLanguage.he: 'משימות',
    AppLanguage.ru: 'Задачи',
    AppLanguage.ar: 'المهام',
  },
  'schedule': {
    AppLanguage.en: 'Schedule',
    AppLanguage.he: 'מערכת שעות',
    AppLanguage.ru: 'Расписание',
    AppLanguage.ar: 'الجدول الدراسي',
  },

  // ── Timer / Dashboard ────────────────────────────────────────────────────────
  'countdowns': {
    AppLanguage.en: 'Countdowns',
    AppLanguage.he: 'ספירות לאחור',
    AppLanguage.ru: 'Обратные отсчёты',
    AppLanguage.ar: 'العدادات التنازلية',
  },
  'addTimer': {
    AppLanguage.en: 'Add Timer',
    AppLanguage.he: 'הוסף טיימר',
    AppLanguage.ru: 'Добавить таймер',
    AppLanguage.ar: 'إضافة مؤقت',
  },
  'createNewTimer': {
    AppLanguage.en: 'Create New Timer',
    AppLanguage.he: 'צור טיימר חדש',
    AppLanguage.ru: 'Создать новый таймер',
    AppLanguage.ar: 'إنشاء مؤقت جديد',
  },
  'timerTitle': {
    AppLanguage.en: 'Timer Title',
    AppLanguage.he: 'כותרת הטיימר',
    AppLanguage.ru: 'Название таймера',
    AppLanguage.ar: 'عنوان المؤقت',
  },
  'timerEmoji': {
    AppLanguage.en: 'Emoji',
    AppLanguage.he: 'אימוג׳י',
    AppLanguage.ru: 'Эмодзи',
    AppLanguage.ar: 'رمز تعبيري',
  },
  'create': {
    AppLanguage.en: 'Create',
    AppLanguage.he: 'צור',
    AppLanguage.ru: 'Создать',
    AppLanguage.ar: 'إنشاء',
  },
  'cancel': {
    AppLanguage.en: 'Cancel',
    AppLanguage.he: 'ביטול',
    AppLanguage.ru: 'Отмена',
    AppLanguage.ar: 'إلغاء',
  },
  'yes': {
    AppLanguage.en: 'Yes',
    AppLanguage.he: 'כן',
    AppLanguage.ru: 'Да',
    AppLanguage.ar: 'نعم',
  },
  'exitApp': {
    AppLanguage.en: 'Exit App',
    AppLanguage.he: 'צא מהאפליקציה',
    AppLanguage.ru: 'Выйти из приложения',
    AppLanguage.ar: 'الخروج من التطبيق',
  },
  'exitAppConfirm': {
    AppLanguage.en: 'Are you sure you want to exit the app?',
    AppLanguage.he: 'האם אתה בטוח שברצונך לצאת מהאפליקציה?',
    AppLanguage.ru: 'Вы уверены, что хотите выйти из приложения?',
    AppLanguage.ar: 'هل أنت متأكد أنك تريد الخروج من التطبيق؟',
  },
  'delete': {
    AppLanguage.en: 'Delete',
    AppLanguage.he: 'מחק',
    AppLanguage.ru: 'Удалить',
    AppLanguage.ar: 'حذف',
  },
  'save': {
    AppLanguage.en: 'Save',
    AppLanguage.he: 'שמור',
    AppLanguage.ru: 'Сохранить',
    AppLanguage.ar: 'حفظ',
  },
  'editTimer': {
    AppLanguage.en: 'Edit Timer',
    AppLanguage.he: 'ערוך טיימר',
    AppLanguage.ru: 'Изменить таймер',
    AppLanguage.ar: 'تعديل المؤقت',
  },
  'deleteTimer': {
    AppLanguage.en: 'Delete Timer?',
    AppLanguage.he: 'למחוק את הטיימר?',
    AppLanguage.ru: 'Удалить таймер?',
    AppLanguage.ar: 'حذف المؤقت؟',
  },
  'deleteTimerConfirm': {
    AppLanguage.en: 'Are you sure you want to delete this timer? This action cannot be undone.',
    AppLanguage.he: 'האם אתה בטוח שברצונך למחוק את הטיימר הזה? פעולה זו לא ניתנת לביטול.',
    AppLanguage.ru: 'Вы уверены, что хотите удалить этот таймер? Это действие нельзя отменить.',
    AppLanguage.ar: 'هل أنت متأكد أنك تريد حذف هذا المؤقت؟ لا يمكن التراجع عن هذا الإجراء.',
  },
  'importFromTodo': {
    AppLanguage.en: 'Import from Todo',
    AppLanguage.he: 'ייבוא ממשימות',
    AppLanguage.ru: 'Импорт из задач',
    AppLanguage.ar: 'استيراد من المهام',
  },
  'selectTodo': {
    AppLanguage.en: 'Select a todo item',
    AppLanguage.he: 'בחר פריט משימה',
    AppLanguage.ru: 'Выберите задачу',
    AppLanguage.ar: 'اختر مهمة',
  },
  'noTodosWithDueDate': {
    AppLanguage.en: 'No todos with due dates',
    AppLanguage.he: 'אין משימות עם תאריך יעד',
    AppLanguage.ru: 'Нет задач с дедлайнами',
    AppLanguage.ar: 'لا توجد مهام بتواريخ استحقاق',
  },
  'tapToSwitch': {
    AppLanguage.en: 'Tap to switch between days, hours, minutes, seconds',
    AppLanguage.he: 'לחץ כדי לעבור בין ימים, שעות, דקות, שניות',
    AppLanguage.ru: 'Нажмите для переключения: дни, часы, минуты, секунды',
    AppLanguage.ar: 'انقر للتبديل بين الأيام والساعات والدقائق والثواني',
  },
  'enterTimerTitle': {
    AppLanguage.en: 'Enter timer title',
    AppLanguage.he: 'הזן כותרת',
    AppLanguage.ru: 'Введите название таймера',
    AppLanguage.ar: 'أدخل عنوان المؤقت',
  },

  // ── Todo page ────────────────────────────────────────────────────────────────
  'tasks': {
    AppLanguage.en: 'Tasks',
    AppLanguage.he: 'משימות',
    AppLanguage.ru: 'Задачи',
    AppLanguage.ar: 'المهام',
  },
  'open': {
    AppLanguage.en: 'Open',
    AppLanguage.he: 'פתוחות',
    AppLanguage.ru: 'Открытые',
    AppLanguage.ar: 'مفتوحة',
  },
  'completed': {
    AppLanguage.en: 'Completed',
    AppLanguage.he: 'הושלמו',
    AppLanguage.ru: 'Выполненные',
    AppLanguage.ar: 'مكتملة',
  },
  'addTask': {
    AppLanguage.en: 'Add Task',
    AppLanguage.he: 'הוסף משימה',
    AppLanguage.ru: 'Добавить задачу',
    AppLanguage.ar: 'إضافة مهمة',
  },
  'createNewTask': {
    AppLanguage.en: 'Create New Task',
    AppLanguage.he: 'צור משימה חדשה',
    AppLanguage.ru: 'Создать новую задачу',
    AppLanguage.ar: 'إنشاء مهمة جديدة',
  },
  'taskTitle': {
    AppLanguage.en: 'Task Title',
    AppLanguage.he: 'כותרת המשימה',
    AppLanguage.ru: 'Название задачи',
    AppLanguage.ar: 'عنوان المهمة',
  },
  'repeat': {
    AppLanguage.en: 'Repeat',
    AppLanguage.he: 'חזרה',
    AppLanguage.ru: 'Повтор',
    AppLanguage.ar: 'تكرار',
  },
  'noRepeat': {
    AppLanguage.en: 'No repeat',
    AppLanguage.he: 'ללא חזרה',
    AppLanguage.ru: 'Без повтора',
    AppLanguage.ar: 'بدون تكرار',
  },
  'daily': {
    AppLanguage.en: 'Daily',
    AppLanguage.he: 'יומי',
    AppLanguage.ru: 'Ежедневно',
    AppLanguage.ar: 'يومياً',
  },
  'weekly': {
    AppLanguage.en: 'Weekly',
    AppLanguage.he: 'שבועי',
    AppLanguage.ru: 'Еженедельно',
    AppLanguage.ar: 'أسبوعياً',
  },
  'monthly': {
    AppLanguage.en: 'Monthly',
    AppLanguage.he: 'חודשי',
    AppLanguage.ru: 'Ежемесячно',
    AppLanguage.ar: 'شهرياً',
  },
  'yearly': {
    AppLanguage.en: 'Yearly',
    AppLanguage.he: 'שנתי',
    AppLanguage.ru: 'Ежегодно',
    AppLanguage.ar: 'سنوياً',
  },
  'deleteTask': {
    AppLanguage.en: 'Delete Task?',
    AppLanguage.he: 'למחוק את המשימה?',
    AppLanguage.ru: 'Удалить задачу?',
    AppLanguage.ar: 'حذف المهمة؟',
  },
  'deleteTaskConfirm': {
    AppLanguage.en: 'Are you sure you want to delete this task? This action cannot be undone.',
    AppLanguage.he: 'האם אתה בטוח שברצונך למחוק את המשימה הזו? פעולה זו לא ניתנת לביטול.',
    AppLanguage.ru: 'Вы уверены, что хотите удалить эту задачу? Это действие нельзя отменить.',
    AppLanguage.ar: 'هل أنت متأكد أنك تريد حذف هذه المهمة؟ لا يمكن التراجع عن هذا الإجراء.',
  },
  'noOpenTasks': {
    AppLanguage.en: 'No open tasks',
    AppLanguage.he: 'אין משימות פתוחות',
    AppLanguage.ru: 'Нет открытых задач',
    AppLanguage.ar: 'لا توجد مهام مفتوحة',
  },
  'noCompletedTasks': {
    AppLanguage.en: 'No completed tasks',
    AppLanguage.he: 'אין משימות שהושלמו',
    AppLanguage.ru: 'Нет выполненных задач',
    AppLanguage.ar: 'لا توجد مهام مكتملة',
  },
  'viewAllTasks': {
    AppLanguage.en: 'View All Tasks',
    AppLanguage.he: 'צפה בכל המשימות',
    AppLanguage.ru: 'Просмотреть все задачи',
    AppLanguage.ar: 'عرض جميع المهام',
  },
  'moreTasks': {
    AppLanguage.en: 'more tasks',
    AppLanguage.he: 'משימות נוספות',
    AppLanguage.ru: 'ещё задач',
    AppLanguage.ar: 'مهام أخرى',
  },
  'enterTaskTitle': {
    AppLanguage.en: 'Enter task title',
    AppLanguage.he: 'הזן כותרת משימה',
    AppLanguage.ru: 'Введите название задачи',
    AppLanguage.ar: 'أدخل عنوان المهمة',
  },
  'optional': {
    AppLanguage.en: 'optional',
    AppLanguage.he: 'אופציונלי',
    AppLanguage.ru: 'необязательно',
    AppLanguage.ar: 'اختياري',
  },
  'dueDate': {
    AppLanguage.en: 'Due Date',
    AppLanguage.he: 'תאריך יעד',
    AppLanguage.ru: 'Дедлайн',
    AppLanguage.ar: 'تاريخ الاستحقاق',
  },
  'editTask': {
    AppLanguage.en: 'Edit Task',
    AppLanguage.he: 'ערוך משימה',
    AppLanguage.ru: 'Изменить задачу',
    AppLanguage.ar: 'تعديل المهمة',
  },

  // ── Calendar ─────────────────────────────────────────────────────────────────
  'day': {
    AppLanguage.en: 'Day',
    AppLanguage.he: 'יום',
    AppLanguage.ru: 'День',
    AppLanguage.ar: 'يوم',
  },
  'week': {
    AppLanguage.en: 'Week',
    AppLanguage.he: 'שבוע',
    AppLanguage.ru: 'Неделя',
    AppLanguage.ar: 'أسبوع',
  },
  'month': {
    AppLanguage.en: 'Month',
    AppLanguage.he: 'חודש',
    AppLanguage.ru: 'Месяц',
    AppLanguage.ar: 'شهر',
  },
  'today': {
    AppLanguage.en: 'Today',
    AppLanguage.he: 'היום',
    AppLanguage.ru: 'Сегодня',
    AppLanguage.ar: 'اليوم',
  },
  'noEvents': {
    AppLanguage.en: 'No events for this day',
    AppLanguage.he: 'אין אירועים ליום זה',
    AppLanguage.ru: 'Нет событий на этот день',
    AppLanguage.ar: 'لا توجد أحداث لهذا اليوم',
  },
  'createEvent': {
    AppLanguage.en: 'Create Event',
    AppLanguage.he: 'צור אירוע',
    AppLanguage.ru: 'Создать событие',
    AppLanguage.ar: 'إنشاء حدث',
  },
  'createClass': {
    AppLanguage.en: 'Create Class',
    AppLanguage.he: 'צור שיעור',
    AppLanguage.ru: 'Создать занятие',
    AppLanguage.ar: 'إنشاء درس',
  },
  'eventTitle': {
    AppLanguage.en: 'Event Title',
    AppLanguage.he: 'כותרת האירוע',
    AppLanguage.ru: 'Название события',
    AppLanguage.ar: 'عنوان الحدث',
  },
  'time': {
    AppLanguage.en: 'Time',
    AppLanguage.he: 'שעה',
    AppLanguage.ru: 'Время',
    AppLanguage.ar: 'الوقت',
  },
  'duration': {
    AppLanguage.en: 'Duration',
    AppLanguage.he: 'משך',
    AppLanguage.ru: 'Продолжительность',
    AppLanguage.ar: 'المدة',
  },
  'color': {
    AppLanguage.en: 'Color',
    AppLanguage.he: 'צבע',
    AppLanguage.ru: 'Цвет',
    AppLanguage.ar: 'اللون',
  },
  'recurrence': {
    AppLanguage.en: 'Recurrence',
    AppLanguage.he: 'חזרה',
    AppLanguage.ru: 'Повторение',
    AppLanguage.ar: 'التكرار',
  },
  'none': {
    AppLanguage.en: 'None',
    AppLanguage.he: 'ללא',
    AppLanguage.ru: 'Нет',
    AppLanguage.ar: 'لا شيء',
  },
  'semesterSchedule': {
    AppLanguage.en: 'Semester Schedule',
    AppLanguage.he: 'מערכת סמסטר',
    AppLanguage.ru: 'Расписание семестра',
    AppLanguage.ar: 'جدول الفصل الدراسي',
  },
  'semesterEndDate': {
    AppLanguage.en: 'Semester End Date',
    AppLanguage.he: 'תאריך סיום סמסטר',
    AppLanguage.ru: 'Дата окончания семестра',
    AppLanguage.ar: 'تاريخ نهاية الفصل الدراسي',
  },
  'addClass': {
    AppLanguage.en: 'Add Class',
    AppLanguage.he: 'הוסף שיעור',
    AppLanguage.ru: 'Добавить занятие',
    AppLanguage.ar: 'إضافة درس',
  },
  'className': {
    AppLanguage.en: 'Class Name',
    AppLanguage.he: 'שם השיעור',
    AppLanguage.ru: 'Название занятия',
    AppLanguage.ar: 'اسم الدرس',
  },
  'classType': {
    AppLanguage.en: 'Class Type',
    AppLanguage.he: 'סוג שיעור',
    AppLanguage.ru: 'Тип занятия',
    AppLanguage.ar: 'نوع الدرس',
  },
  'lecture': {
    AppLanguage.en: 'Lecture',
    AppLanguage.he: 'הרצאה',
    AppLanguage.ru: 'Лекция',
    AppLanguage.ar: 'محاضرة',
  },
  'tutorial': {
    AppLanguage.en: 'Tutorial',
    AppLanguage.he: 'תרגול',
    AppLanguage.ru: 'Семинар',
    AppLanguage.ar: 'درس تطبيقي',
  },
  'reinforcement': {
    AppLanguage.en: 'Reinforcement',
    AppLanguage.he: 'חיזוק',
    AppLanguage.ru: 'Закрепление',
    AppLanguage.ar: 'تعزيز',
  },
  'other': {
    AppLanguage.en: 'Other',
    AppLanguage.he: 'אחר',
    AppLanguage.ru: 'Другое',
    AppLanguage.ar: 'أخرى',
  },
  'dayOfWeek': {
    AppLanguage.en: 'Day of Week',
    AppLanguage.he: 'יום בשבוע',
    AppLanguage.ru: 'День недели',
    AppLanguage.ar: 'يوم الأسبوع',
  },
  'sunday': {
    AppLanguage.en: 'Sunday',
    AppLanguage.he: 'ראשון',
    AppLanguage.ru: 'Воскресенье',
    AppLanguage.ar: 'الأحد',
  },
  'monday': {
    AppLanguage.en: 'Monday',
    AppLanguage.he: 'שני',
    AppLanguage.ru: 'Понедельник',
    AppLanguage.ar: 'الاثنين',
  },
  'tuesday': {
    AppLanguage.en: 'Tuesday',
    AppLanguage.he: 'שלישי',
    AppLanguage.ru: 'Вторник',
    AppLanguage.ar: 'الثلاثاء',
  },
  'wednesday': {
    AppLanguage.en: 'Wednesday',
    AppLanguage.he: 'רביעי',
    AppLanguage.ru: 'Среда',
    AppLanguage.ar: 'الأربعاء',
  },
  'thursday': {
    AppLanguage.en: 'Thursday',
    AppLanguage.he: 'חמישי',
    AppLanguage.ru: 'Четверг',
    AppLanguage.ar: 'الخميس',
  },
  'friday': {
    AppLanguage.en: 'Friday',
    AppLanguage.he: 'שישי',
    AppLanguage.ru: 'Пятница',
    AppLanguage.ar: 'الجمعة',
  },
  'saturday': {
    AppLanguage.en: 'Saturday',
    AppLanguage.he: 'שבת',
    AppLanguage.ru: 'Суббота',
    AppLanguage.ar: 'السبت',
  },
  'sun': {
    AppLanguage.en: 'Sun',
    AppLanguage.he: 'א׳',
    AppLanguage.ru: 'Вс',
    AppLanguage.ar: 'أحد',
  },
  'mon': {
    AppLanguage.en: 'Mon',
    AppLanguage.he: 'ב׳',
    AppLanguage.ru: 'Пн',
    AppLanguage.ar: 'اثن',
  },
  'tue': {
    AppLanguage.en: 'Tue',
    AppLanguage.he: 'ג׳',
    AppLanguage.ru: 'Вт',
    AppLanguage.ar: 'ثلث',
  },
  'wed': {
    AppLanguage.en: 'Wed',
    AppLanguage.he: 'ד׳',
    AppLanguage.ru: 'Ср',
    AppLanguage.ar: 'أرب',
  },
  'thu': {
    AppLanguage.en: 'Thu',
    AppLanguage.he: 'ה׳',
    AppLanguage.ru: 'Чт',
    AppLanguage.ar: 'خمس',
  },
  'fri': {
    AppLanguage.en: 'Fri',
    AppLanguage.he: 'ו׳',
    AppLanguage.ru: 'Пт',
    AppLanguage.ar: 'جمع',
  },
  'sat': {
    AppLanguage.en: 'Sat',
    AppLanguage.he: 'ש׳',
    AppLanguage.ru: 'Сб',
    AppLanguage.ar: 'سبت',
  },

  // ── Time units ────────────────────────────────────────────────────────────────
  'days': {
    AppLanguage.en: 'days',
    AppLanguage.he: 'ימים',
    AppLanguage.ru: 'дней',
    AppLanguage.ar: 'أيام',
  },
  'hours': {
    AppLanguage.en: 'hours',
    AppLanguage.he: 'שעות',
    AppLanguage.ru: 'часов',
    AppLanguage.ar: 'ساعات',
  },
  'minutes': {
    AppLanguage.en: 'minutes',
    AppLanguage.he: 'דקות',
    AppLanguage.ru: 'минут',
    AppLanguage.ar: 'دقائق',
  },
  'seconds': {
    AppLanguage.en: 'seconds',
    AppLanguage.he: 'שניות',
    AppLanguage.ru: 'секунд',
    AppLanguage.ar: 'ثوان',
  },
  'day_singular': {
    AppLanguage.en: 'day',
    AppLanguage.he: 'יום',
    AppLanguage.ru: 'день',
    AppLanguage.ar: 'يوم',
  },
  'hour_singular': {
    AppLanguage.en: 'hour',
    AppLanguage.he: 'שעה',
    AppLanguage.ru: 'час',
    AppLanguage.ar: 'ساعة',
  },
  'minute_singular': {
    AppLanguage.en: 'minute',
    AppLanguage.he: 'דקה',
    AppLanguage.ru: 'минута',
    AppLanguage.ar: 'دقيقة',
  },
  'second_singular': {
    AppLanguage.en: 'second',
    AppLanguage.he: 'שנייה',
    AppLanguage.ru: 'секунда',
    AppLanguage.ar: 'ثانية',
  },

  // ── Duration options ──────────────────────────────────────────────────────────
  'minutes15': {
    AppLanguage.en: '15 minutes',
    AppLanguage.he: '15 דקות',
    AppLanguage.ru: '15 минут',
    AppLanguage.ar: '١٥ دقيقة',
  },
  'minutes30': {
    AppLanguage.en: '30 minutes',
    AppLanguage.he: '30 דקות',
    AppLanguage.ru: '30 минут',
    AppLanguage.ar: '٣٠ دقيقة',
  },
  'minutes45': {
    AppLanguage.en: '45 minutes',
    AppLanguage.he: '45 דקות',
    AppLanguage.ru: '45 минут',
    AppLanguage.ar: '٤٥ دقيقة',
  },
  'hour1': {
    AppLanguage.en: '1 hour',
    AppLanguage.he: 'שעה',
    AppLanguage.ru: '1 час',
    AppLanguage.ar: 'ساعة',
  },
  'hours15': {
    AppLanguage.en: '1.5 hours',
    AppLanguage.he: 'שעה וחצי',
    AppLanguage.ru: '1.5 часа',
    AppLanguage.ar: 'ساعة ونصف',
  },
  'hours2': {
    AppLanguage.en: '2 hours',
    AppLanguage.he: 'שעתיים',
    AppLanguage.ru: '2 часа',
    AppLanguage.ar: 'ساعتان',
  },
  'hours3': {
    AppLanguage.en: '3 hours',
    AppLanguage.he: '3 שעות',
    AppLanguage.ru: '3 часа',
    AppLanguage.ar: '٣ ساعات',
  },
  'hours4': {
    AppLanguage.en: '4 hours',
    AppLanguage.he: '4 שעות',
    AppLanguage.ru: '4 часа',
    AppLanguage.ar: '٤ ساعات',
  },
  'hours6': {
    AppLanguage.en: '6 hours',
    AppLanguage.he: '6 שעות',
    AppLanguage.ru: '6 часов',
    AppLanguage.ar: '٦ ساعات',
  },
  'hours8': {
    AppLanguage.en: '8 hours',
    AppLanguage.he: '8 שעות',
    AppLanguage.ru: '8 часов',
    AppLanguage.ar: '٨ ساعات',
  },

  // ── General ───────────────────────────────────────────────────────────────────
  'until': {
    AppLanguage.en: 'until',
    AppLanguage.he: 'עד',
    AppLanguage.ru: 'до',
    AppLanguage.ar: 'حتى',
  },
  'graduation': {
    AppLanguage.en: 'Graduation',
    AppLanguage.he: 'סיום לימודים',
    AppLanguage.ru: 'Выпуск',
    AppLanguage.ar: 'التخرج',
  },
  'done': {
    AppLanguage.en: 'done',
    AppLanguage.he: 'הושלמו',
    AppLanguage.ru: 'выполнено',
    AppLanguage.ar: 'تم',
  },
  'timerAdded': {
    AppLanguage.en: 'Timer added successfully',
    AppLanguage.he: 'הטיימר נוסף בהצלחה',
    AppLanguage.ru: 'Таймер успешно добавлен',
    AppLanguage.ar: 'تمت إضافة المؤقت بنجاح',
  },
  'addAsTimer': {
    AppLanguage.en: 'Add as Timer',
    AppLanguage.he: 'הוסף כטיימר',
    AppLanguage.ru: 'Добавить как таймер',
    AppLanguage.ar: 'إضافة كمؤقت',
  },

  // ── Schedule page ─────────────────────────────────────────────────────────────
  'noSchedule': {
    AppLanguage.en: 'No classes today',
    AppLanguage.he: 'אין שיעורים היום',
    AppLanguage.ru: 'Занятий сегодня нет',
    AppLanguage.ar: 'لا توجد دروس اليوم',
  },
  'addEntry': {
    AppLanguage.en: 'Add Class',
    AppLanguage.he: 'הוסף שיעור',
    AppLanguage.ru: 'Добавить занятие',
    AppLanguage.ar: 'إضافة درس',
  },
  'editEntry': {
    AppLanguage.en: 'Edit Class',
    AppLanguage.he: 'ערוך שיעור',
    AppLanguage.ru: 'Изменить занятие',
    AppLanguage.ar: 'تعديل الدرس',
  },
  'courseName': {
    AppLanguage.en: 'Course Name',
    AppLanguage.he: 'שם הקורס',
    AppLanguage.ru: 'Название курса',
    AppLanguage.ar: 'اسم المادة',
  },
  'enterCourseName': {
    AppLanguage.en: 'Enter course name',
    AppLanguage.he: 'הזן שם קורס',
    AppLanguage.ru: 'Введите название курса',
    AppLanguage.ar: 'أدخل اسم المادة',
  },
  'optionalLocation': {
    AppLanguage.en: 'Location (optional)',
    AppLanguage.he: 'מיקום (אופציונלי)',
    AppLanguage.ru: 'Место (необязательно)',
    AppLanguage.ar: 'الموقع (اختياري)',
  },
  'locationHint': {
    AppLanguage.en: 'Building, room...',
    AppLanguage.he: 'בניין, חדר...',
    AppLanguage.ru: 'Корпус, аудитория...',
    AppLanguage.ar: 'المبنى، القاعة...',
  },
  'lab': {
    AppLanguage.en: 'Lab',
    AppLanguage.he: 'מעבדה',
    AppLanguage.ru: 'Лабораторная',
    AppLanguage.ar: 'مختبر',
  },
  'startTime': {
    AppLanguage.en: 'Start Time',
    AppLanguage.he: 'שעת התחלה',
    AppLanguage.ru: 'Время начала',
    AppLanguage.ar: 'وقت البداية',
  },
  'endTime': {
    AppLanguage.en: 'End Time',
    AppLanguage.he: 'שעת סיום',
    AppLanguage.ru: 'Время окончания',
    AppLanguage.ar: 'وقت النهاية',
  },
  'colorLabel': {
    AppLanguage.en: 'Color',
    AppLanguage.he: 'צבע',
    AppLanguage.ru: 'Цвет',
    AppLanguage.ar: 'اللون',
  },
  'deleteEntry': {
    AppLanguage.en: 'Delete Class',
    AppLanguage.he: 'מחק שיעור',
    AppLanguage.ru: 'Удалить занятие',
    AppLanguage.ar: 'حذف الدرس',
  },
  'add': {
    AppLanguage.en: 'Add',
    AppLanguage.he: 'הוסף',
    AppLanguage.ru: 'Добавить',
    AppLanguage.ar: 'إضافة',
  },

  // ── Onboarding ───────────────────────────────────────────────────────────────
  'onboarding_welcome_title': {
    AppLanguage.en: 'Welcome to UniFlow',
    AppLanguage.he: 'ברוך הבא ל-UniFlow',
    AppLanguage.ru: 'Добро пожаловать в UniFlow',
    AppLanguage.ar: 'مرحباً بك في UniFlow',
  },
  'onboarding_welcome_subtitle': {
    AppLanguage.en: 'Your all-in-one student planner.\nChoose your language to get started.',
    AppLanguage.he: 'הפלאנר המלא לסטודנטים.\nבחר שפה כדי להתחיל.',
    AppLanguage.ru: 'Универсальный планировщик для студентов.\nВыберите язык для начала.',
    AppLanguage.ar: 'منظّمك الشامل كطالب.\nاختر لغتك للبدء.',
  },
  'onboarding_countdowns_title': {
    AppLanguage.en: 'Track Important Dates',
    AppLanguage.he: 'עקוב אחר תאריכים חשובים',
    AppLanguage.ru: 'Отслеживайте важные даты',
    AppLanguage.ar: 'تتبع التواريخ المهمة',
  },
  'onboarding_countdowns_desc': {
    AppLanguage.en: 'Set countdowns for exams, assignments, and milestones — always know what\'s coming.',
    AppLanguage.he: 'הגדר ספירות לאחור לבחינות, מטלות ואירועים — תמיד דע מה מתקרב.',
    AppLanguage.ru: 'Устанавливайте обратный отсчёт до экзаменов, заданий и важных событий.',
    AppLanguage.ar: 'اضبط عدادات تنازلية للامتحانات والواجبات والمعالم — اعرف دائماً ما هو قادم.',
  },
  'onboarding_todo_title': {
    AppLanguage.en: 'Stay on Top of Tasks',
    AppLanguage.he: 'הישאר על גבי המשימות שלך',
    AppLanguage.ru: 'Контролируйте свои задачи',
    AppLanguage.ar: 'ابقَ على رأس مهامك',
  },
  'onboarding_todo_desc': {
    AppLanguage.en: 'Manage your daily tasks, star the important ones, and check them off as you go.',
    AppLanguage.he: 'נהל את המשימות היומיות שלך, סמן את החשובות בכוכב ותסמן אותן כשתסיים.',
    AppLanguage.ru: 'Управляйте ежедневными задачами, отмечайте важные звёздочкой и завершайте их по ходу.',
    AppLanguage.ar: 'أدر مهامك اليومية، نجّم المهمة منها، وضع علامة اكتمال عند الانتهاء.',
  },
  'onboarding_schedule_title': {
    AppLanguage.en: 'Organize Your Week',
    AppLanguage.he: 'ארגן את השבוע שלך',
    AppLanguage.ru: 'Организуйте свою неделю',
    AppLanguage.ar: 'نظّم أسبوعك',
  },
  'onboarding_schedule_desc': {
    AppLanguage.en: 'Set up your class schedule, view it by day or week, and never miss a lecture.',
    AppLanguage.he: 'הגדר את מערכת השעות שלך, צפה בה לפי יום או שבוע ואל תחמיץ שיעור.',
    AppLanguage.ru: 'Настройте расписание занятий, просматривайте его по дням или неделям.',
    AppLanguage.ar: 'أعدّ جدولك الدراسي، اعرضه يومياً أو أسبوعياً، ولا تفوّت محاضرة.',
  },
  'onboarding_calendar_title': {
    AppLanguage.en: 'See the Big Picture',
    AppLanguage.he: 'ראה את התמונה הגדולה',
    AppLanguage.ru: 'Видьте общую картину',
    AppLanguage.ar: 'شاهد الصورة الكاملة',
  },
  'onboarding_calendar_desc': {
    AppLanguage.en: 'View all your tasks and events in one calendar so nothing slips through the cracks.',
    AppLanguage.he: 'צפה בכל המשימות והאירועים שלך בלוח שנה אחד כדי שלא תפספס דבר.',
    AppLanguage.ru: 'Смотрите все задачи и события в одном календаре — ничего не упустите.',
    AppLanguage.ar: 'اعرض جميع مهامك وأحداثك في تقويم واحد حتى لا يفوتك شيء.',
  },
  'onboarding_ready_title': {
    AppLanguage.en: 'You\'re All Set!',
    AppLanguage.he: 'הכל מוכן!',
    AppLanguage.ru: 'Всё готово!',
    AppLanguage.ar: 'أنت جاهز!',
  },
  'onboarding_ready_desc': {
    AppLanguage.en: 'Start your productive journey with UniFlow. You can always change settings later.',
    AppLanguage.he: 'התחל את המסע הפרודוקטיבי שלך עם UniFlow. תמיד אפשר לשנות הגדרות מאוחר יותר.',
    AppLanguage.ru: 'Начните продуктивное путешествие с UniFlow. Настройки всегда можно изменить позже.',
    AppLanguage.ar: 'ابدأ رحلتك المنتجة مع UniFlow. يمكنك دائماً تغيير الإعدادات لاحقاً.',
  },
  'onboarding_next': {
    AppLanguage.en: 'Next',
    AppLanguage.he: 'הבא',
    AppLanguage.ru: 'Далее',
    AppLanguage.ar: 'التالي',
  },
  'onboarding_skip': {
    AppLanguage.en: 'Skip',
    AppLanguage.he: 'דלג',
    AppLanguage.ru: 'Пропустить',
    AppLanguage.ar: 'تخطى',
  },
  'onboarding_get_started': {
    AppLanguage.en: 'Get Started',
    AppLanguage.he: 'בואו נתחיל',
    AppLanguage.ru: 'Начать',
    AppLanguage.ar: 'ابدأ الآن',
  },
  'onboarding_choose_language': {
    AppLanguage.en: 'Choose Language',
    AppLanguage.he: 'בחר שפה',
    AppLanguage.ru: 'Выберите язык',
    AppLanguage.ar: 'اختر اللغة',
  },
};

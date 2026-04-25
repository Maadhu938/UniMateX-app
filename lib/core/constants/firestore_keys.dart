class FirestoreKeys {
  static const String users = 'users';
  static const String timetable = 'timetable';
  static const String attendance = 'attendance';
  static const String assignments = 'assignments';
  static const String notes = 'notes';
  static const String notifications = 'notifications';
  static const String stats = 'stats';
  static const String summary = 'summary';

  // Common fields
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  // User fields
  static const String name = 'name';
  static const String email = 'email';

  // Subject fields
  static const String subject = 'subject';
  static const String subjectCode = 'subjectCode';

  // Timetable fields
  static const String dayOfWeek = 'dayOfWeek';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String room = 'room';

  // Attendance fields
  static const String totalClasses = 'totalClasses';
  static const String attendedClasses = 'attendedClasses';

  // Assignment fields
  static const String title = 'title';
  static const String description = 'description';
  static const String dueDate = 'dueDate';
  static const String status = 'status';

  // Note fields
  static const String content = 'content';

  // Notification fields
  static const String body = 'body';
  static const String type = 'type';
  static const String isRead = 'isRead';

  // Stats fields
  static const String overallAttendance = 'overallAttendance';
  static const String pendingAssignments = 'pendingAssignments';
  static const String todayClasses = 'todayClasses';

  // Status values
  static const String statusPending = 'pending';
  static const String statusCompleted = 'completed';
}

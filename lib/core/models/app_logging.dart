class AppLogging {
  final String id;
  final String loggerName;
  final String level;
  final String time;
  final String className;
  final String methodName;
  final String message;
  final String? stackTrace;
  final String printable;

  AppLogging({
    required this.id,
    required this.loggerName,
    required this.level,
    required this.time,
    required this.className,
    required this.methodName,
    required this.message,
    this.stackTrace,
    required this.printable,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loggerName': loggerName,
      'level': level,
      'time': time,
      'className': className,
      'methodName': methodName,
      'message': message,
      'stackTrace': stackTrace,
      'printable': printable
    };
  }

}

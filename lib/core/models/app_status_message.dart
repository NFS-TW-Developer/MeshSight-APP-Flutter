class AppStatusMessage {
  final bool status;
  final String? message;

  AppStatusMessage({
    required this.status,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'message': message,
    };
  }
}

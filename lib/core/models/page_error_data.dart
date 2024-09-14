class PageErrorData {
  final String code;
  final String description;

  PageErrorData({required this.code, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
    };
  }
}

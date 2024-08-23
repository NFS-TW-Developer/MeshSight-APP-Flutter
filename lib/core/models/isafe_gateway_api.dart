class BaseResponse {
  final String status;
  final String message;
  final dynamic data;

  BaseResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'],
    );
  }
}


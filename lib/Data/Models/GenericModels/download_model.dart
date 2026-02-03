class DownloadModel {
  final String data;
  final String message;
  final int status;

  DownloadModel({
    required this.data,
    required this.message,
    required this.status,
  });

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      data: json['data'],
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'message': message,
      'status': status,
    };
  }
}

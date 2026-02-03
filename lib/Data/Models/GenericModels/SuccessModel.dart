class SuccessModel {
  List<void>? data;
  String? message;

  SuccessModel({this.data, this.message});

  SuccessModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Null>[];
      json['data'].forEach((v) {
        data!.add(null);
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => null).toList();
    }
    data['message'] = message;
    return data;
  }
}

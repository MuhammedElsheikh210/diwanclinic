
import '../../../index/index_main.dart';

class UserMapper {
  static BaseUser fromMap(Map<String, dynamic> json) {
    final userType = UserTypeExtension.fromString(json['userType']);

    switch (userType) {
      case UserType.doctor:
        return DoctorUser.fromJson(json);

      case UserType.assistant:
        return AssistantUser.fromJson(json);

      default:
        return BaseUser.fromJson(json);
    }
  }
}

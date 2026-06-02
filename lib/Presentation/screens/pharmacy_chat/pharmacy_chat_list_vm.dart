import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import '../../../index/index_main.dart';

class PharmacyChatListVm extends GetxController {
  final _chatService = ChatService();

  List<PharmacyChatThread>? threads;

  void listenChats(String pharmacyId) {
    _chatService.getPharmacyChatList(pharmacyId).listen((data) {
      threads = data;
      update();
    });
  }

  int get unreadCount =>
      threads?.where((t) => t.isPharmacyRead == false).length ?? 0;
}

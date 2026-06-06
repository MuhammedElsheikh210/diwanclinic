import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import '../../../index/index_main.dart';

class AssistantChatListVm extends GetxController {
  final _chatService = ChatService();

  List<AssistantChatThread>? threads;

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<UserSession>().user?.user;
    if (user is AssistantUser) {
      _listenChats(user.doctorKey ?? "");
    }
  }

  void _listenChats(String doctorKey) {
    if (doctorKey.isEmpty) return;
    _chatService.getAssistantChatList(doctorKey).listen((data) {
      threads = data;
      update();
    });
  }

  int get unreadCount =>
      threads?.where((t) => t.isAssistantRead == false).length ?? 0;
}

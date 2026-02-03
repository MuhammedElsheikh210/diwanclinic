import 'package:diwanclinic/Presentation/screens/chat/chat_details/chat_view.dart';
import 'package:diwanclinic/Presentation/screens/chat/chat_details/chat_view_model.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final controller = Get.put(ChatViewModel());
  final user = LocalUser().getUserData();

  @override
  void initState() {
    super.initState();
    controller.listenChats(user.uid ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatViewModel>(
      init: controller,
      builder: (vm) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const HomePatientAppBar(),
          body: vm.chatList == null
              ? const ShimmerLoader()
              : vm.chatList!.isEmpty
              ? NoDataAnimated(
                  title: "المحادثة مع الطبيب قريباً",
                  subtitle:
                      "نعمل حالياً على توفير خدمة الدردشة مع الأطباء لتسهيل تواصلك… انتظرونا!",
                  lottiePath: Animations.comming_soon,
                  height: 200.h,
                )
              : ListView.separated(
                  itemCount: vm.chatList!.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.borderNeutralPrimary,
                  ),
                  itemBuilder: (context, index) {
                    final chat = vm.chatList![index];

                    return InkWell(
                      onTap: () {
                        Get.to(
                          () => ChatView(
                            receiverId: chat.receiverId ?? "",
                            receiverName: chat.receiverName ?? "مريض",
                          ),
                          binding: Binding(),
                        );
                      },
                      child: Container(
                        color: chat.isRead == false
                            ? AppColors.primary.withOpacity(
                                0.1,
                              ) // 🔹 highlight unread chats
                            : Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 16.w,
                        ),
                        child: Row(
                          children: [
                            // ✅ Avatar
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.grayLight,
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade700,
                                size: 30,
                              ),
                            ),
                            SizedBox(width: 12.w),

                            // ✅ Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        chat.receiverName ?? "مريض",
                                        style: context.typography.mdBold,
                                      ),
                                      Text(
                                        _formatDate(chat.lastMessageTime),
                                        style: context.typography.smRegular
                                            .copyWith(
                                              color: AppColors.grayMedium,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat.lastMessage ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.typography.smRegular
                                        .copyWith(
                                          color: chat.isRead == true
                                              ? AppColors.grayMedium
                                              : AppColors.background_black,
                                          fontWeight: chat.isRead == true
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return "";
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (dt.isAfter(today)) {
      // same day → show time
      return DateFormat("hh:mm a").format(dt);
    } else {
      // old → show date
      return DateFormat("dd/MM/yyyy").format(dt);
    }
  }
}

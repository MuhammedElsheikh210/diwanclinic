import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import 'package:diwanclinic/Presentation/screens/chat/chat_details/chat_view.dart';
import 'package:diwanclinic/Presentation/screens/pharmacy_chat/pharmacy_chat_detail_view.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

// ─────────────────────────────────────────────────────────────
// Patient Chat List — shows pharmacy chat threads (Tab 5)
// ─────────────────────────────────────────────────────────────
class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  late final _vm = Get.put(PatientPharmacyChatListVm());

  @override
  void initState() {
    super.initState();
    final uid = Get.find<UserSession>().user?.uid ?? "";
    if (uid.isNotEmpty) _vm.listenPharmacyChats(uid);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientPharmacyChatListVm>(
      builder: (vm) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const HomePatientAppBar(),
          body: vm.threads == null
              ? const ShimmerLoader()
              : vm.threads!.isEmpty
                  ? NoDataAnimated(
                      title: "لا توجد محادثات مع صيدليات",
                      subtitle:
                          "عند طلب دواء من صيدلية يمكنك التواصل معها مباشرةً هنا.",
                      lottiePath: Animations.comming_soon,
                      height: 200.h,
                    )
                  : ListView.separated(
                      itemCount: vm.threads!.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.borderNeutralPrimary,
                      ),
                      itemBuilder: (context, i) {
                        final thread = vm.threads![i];
                        final isUnread =
                            thread.isPatientRead == false;
                        return _PatientThreadTile(
                          thread: thread,
                          isUnread: isUnread,
                        );
                      },
                    ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Patient Pharmacy Chat List ViewModel
// ─────────────────────────────────────────────────────────────
class PatientPharmacyChatListVm extends GetxController {
  final _chatService = ChatService();

  List<PharmacyChatThread>? threads;

  void listenPharmacyChats(String patientUid) {
    _chatService.getPatientPharmacyChats(patientUid).listen((data) {
      threads = data;
      update();
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Thread Tile Widget
// ─────────────────────────────────────────────────────────────
class _PatientThreadTile extends StatelessWidget {
  final PharmacyChatThread thread;
  final bool isUnread;

  const _PatientThreadTile(
      {required this.thread, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final session = Get.find<UserSession>();
        Get.to(
          () => PharmacyChatDetailView(
            pharmacyId: thread.pharmacyId ?? "",
            pharmacyName: thread.pharmacyName ?? "الصيدلية",
            patientId: session.user?.uid ?? "",
            patientName: session.user?.name ?? "مريض",
            isPharmacySide: false,
            receiverFcmToken: thread.pharmacyFcmToken,
          ),
          binding: Binding(),
        );
      },
      child: Container(
        color: isUnread
            ? AppColors.primary.withOpacity(0.06)
            : Colors.transparent,
        padding:
            EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                color: Color(0xFFFF6B35),
                size: 26,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        thread.pharmacyName ?? "الصيدلية",
                        style: isUnread
                            ? context.typography.mdBold
                            : context.typography.mdMedium,
                      ),
                      Text(
                        _formatDate(thread.lastMessageTime),
                        style: context.typography.smRegular.copyWith(
                          color: AppColors.grayMedium,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.lastMessage ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.smRegular.copyWith(
                            color: isUnread
                                ? AppColors.background_black
                                : AppColors.grayMedium,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: EdgeInsets.only(right: 6.w),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int? ts) {
    if (ts == null) return "";
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dt.isAfter(today)
        ? DateFormat("hh:mm a").format(dt)
        : DateFormat("dd-MM").format(dt);
  }
}

// ─────────────────────────────────────────────────────────────
// Keep original ChatListView for Doctor/Assistant users
// (used internally by doctor/assistant chat — not patient)
// ─────────────────────────────────────────────────────────────
class DoctorChatListView extends StatefulWidget {
  const DoctorChatListView({super.key});

  @override
  State<DoctorChatListView> createState() => _DoctorChatListViewState();
}

class _DoctorChatListViewState extends State<DoctorChatListView> {
  final controller = Get.put(ChatViewModel());

  BaseUser? get user => Get.find<UserSession>().user?.user;

  String _resolveUid() {
    final u = user;
    if (u == null) throw Exception("❌ No user");
    if (u is DoctorUser) return u.uid!;
    if (u is AssistantUser) return u.doctorKey!;
    return u.uid!;
  }

  @override
  void initState() {
    super.initState();
    final uid = _resolveUid();
    controller.listenChats(uid);
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
                          "نعمل حالياً على توفير خدمة الدردشة مع الأطباء.",
                      lottiePath: Animations.comming_soon,
                      height: 200.h,
                    )
                  : ListView.separated(
                      itemCount: vm.chatList!.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.borderNeutralPrimary,
                      ),
                      itemBuilder: (context, i) {
                        final chat = vm.chatList![i];
                        return InkWell(
                          onTap: () {
                            Get.to(
                              () => ChatView(
                                receiverId: chat.receiverId ?? "",
                                receiverName:
                                    chat.receiverName ?? "مريض",
                              ),
                              binding: Binding(),
                            );
                          },
                          child: Container(
                            color: chat.isRead == false
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 16.w,
                            ),
                            child: Row(
                              children: [
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            chat.receiverName ?? "مريض",
                                            style: context
                                                .typography.mdBold,
                                          ),
                                          Text(
                                            _formatDate(
                                                chat.lastMessageTime),
                                            style: context
                                                .typography.smRegular
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
    return dt.isAfter(today)
        ? DateFormat("hh:mm a").format(dt)
        : DateFormat("dd-MM-yyyy").format(dt);
  }
}

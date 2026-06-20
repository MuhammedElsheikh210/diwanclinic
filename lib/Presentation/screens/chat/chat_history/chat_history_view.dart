import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import 'package:diwanclinic/Presentation/screens/chat/chat_details/chat_view.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

// ─────────────────────────────────────────────────────────────
// Patient Chat List — shows assistant chats for doctors the
// patient has reservations with (Tab: المحادثة)
// ─────────────────────────────────────────────────────────────
class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  late final _vm = Get.put(PatientAssistantChatListVm());

  @override
  void initState() {
    super.initState();
    final uid = Get.find<UserSession>().user?.uid ?? "";
    if (uid.isNotEmpty) _vm.listen(uid);
  }

  // Unique doctors (= assistants) derived from patient reservations
  List<_AssistantContact> _deriveContacts(
      List<ReservationModel?>? reservations) {
    final map = <String, _AssistantContact>{};
    for (final r in reservations ?? []) {
      final id = r?.doctorUid;
      if (id == null || id.isEmpty) continue;
      if (map.containsKey(id)) continue;
      map[id] = _AssistantContact(
        doctorUid: id,
        doctorName: r?.doctorName ?? "العيادة",
        receiverFcm: r?.assistantFcm ?? r?.doctorFcm,
      );
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationPatientViewModel>(
      init: Get.isRegistered<ReservationPatientViewModel>()
          ? Get.find<ReservationPatientViewModel>()
          : ReservationPatientViewModel(),
      builder: (resVm) {
        final contacts = _deriveContacts(resVm.listReservations);
        return GetBuilder<PatientAssistantChatListVm>(
          builder: (vm) {
            return Scaffold(
              backgroundColor: AppColors.white,
              appBar: const HomePatientAppBar(),
              body: contacts.isEmpty
                  ? NoDataAnimated(
                      title: "لا توجد محادثات",
                      subtitle:
                          "بعد حجز كشف يمكنك التواصل مع مساعدة العيادة من هنا.",
                      lottiePath: Animations.comming_soon,
                      height: 200.h,
                    )
                  : ListView.separated(
                      itemCount: contacts.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.borderNeutralPrimary,
                      ),
                      itemBuilder: (context, i) {
                        final contact = contacts[i];
                        final thread = vm.threadFor(contact.doctorUid);
                        return _AssistantContactTile(
                          contact: contact,
                          thread: thread,
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Patient Assistant Chat List ViewModel
// ─────────────────────────────────────────────────────────────
class PatientAssistantChatListVm extends GetxController {
  final _chatService = ChatService();

  List<AssistantChatThread>? threads;
  StreamSubscription? _sub;

  void listen(String patientUid) {
    _sub?.cancel();
    _sub = _chatService.getPatientAssistantChats(patientUid).listen((data) {
      threads = data;
      update();
    });
  }

  AssistantChatThread? threadFor(String assistantId) {
    final list = threads;
    if (list == null) return null;
    for (final t in list) {
      if (t.assistantId == assistantId) return t;
    }
    return null;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

// ─────────────────────────────────────────────────────────────
// Assistant Contact (one per doctor the patient booked with)
// ─────────────────────────────────────────────────────────────
class _AssistantContact {
  final String doctorUid;
  final String doctorName;
  final String? receiverFcm;

  const _AssistantContact({
    required this.doctorUid,
    required this.doctorName,
    this.receiverFcm,
  });
}

// ─────────────────────────────────────────────────────────────
// Contact Tile Widget
// ─────────────────────────────────────────────────────────────
class _AssistantContactTile extends StatelessWidget {
  final _AssistantContact contact;
  final AssistantChatThread? thread;

  const _AssistantContactTile({required this.contact, this.thread});

  @override
  Widget build(BuildContext context) {
    final isUnread = thread?.isPatientRead == false;
    final lastMessage = thread?.lastMessage;
    return InkWell(
      onTap: () {
        final session = Get.find<UserSession>();
        Get.to(
          () => AssistantChatDetailView(
            assistantId: contact.doctorUid,
            assistantName: contact.doctorName,
            patientId: session.user?.uid ?? "",
            patientName: session.user?.name ?? "مريض",
            isAssistantSide: false,
            receiverFcmToken: contact.receiverFcm,
          ),
          binding: Binding(),
        );
      },
      child: Container(
        color: isUnread
            ? AppColors.primary.withOpacity(0.06)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contact.doctorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isUnread
                              ? context.typography.mdBold
                              : context.typography.mdMedium,
                        ),
                      ),
                      if (thread?.lastMessageTime != null)
                        Text(
                          _formatDate(thread!.lastMessageTime),
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
                          lastMessage ?? "اضغط لبدء المحادثة مع المساعدة",
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

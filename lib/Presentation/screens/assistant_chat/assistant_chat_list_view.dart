import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import 'package:diwanclinic/Presentation/screens/assistant_chat/assistant_chat_detail_view.dart';
import 'package:diwanclinic/Presentation/screens/assistant_chat/assistant_chat_list_vm.dart';
import 'package:intl/intl.dart';
import '../../../index/index_main.dart';

/// Assistant side: list of all patient chat threads.
class AssistantChatListView extends StatefulWidget {
  const AssistantChatListView({super.key});

  @override
  State<AssistantChatListView> createState() => _AssistantChatListViewState();
}

class _AssistantChatListViewState extends State<AssistantChatListView> {
  late final String _assistantId;
  late final String _assistantName;

  @override
  void initState() {
    super.initState();
    final user = Get.find<UserSession>().user?.user as AssistantUser?;
    _assistantId = user?.doctorKey ?? "";
    _assistantName = Get.find<UserSession>().user?.name ?? "المساعدة";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AssistantChatListVm>(
      builder: (vm) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              "محادثات المرضى",
              style: context.typography.lgBold.copyWith(color: AppColors.white),
            ),
            centerTitle: true,
          ),
          body: vm.threads == null
              ? const ShimmerLoader()
              : vm.threads!.isEmpty
                  ? NoDataAnimated(
                      title: "لا توجد محادثات بعد",
                      subtitle:
                          "ستظهر هنا محادثات المرضى عند بدء أي مريض للتواصل معك.",
                      lottiePath: Animations.comming_soon,
                      height: 200.h,
                    )
                  : ListView.separated(
                      itemCount: vm.threads!.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AppColors.borderNeutralPrimary),
                      itemBuilder: (context, i) {
                        final thread = vm.threads![i];
                        final isUnread = thread.isAssistantRead == false;
                        return _ThreadTile(
                          thread: thread,
                          isUnread: isUnread,
                          onTap: () => Get.to(
                            () => AssistantChatDetailView(
                              assistantId: _assistantId,
                              assistantName: _assistantName,
                              patientId: thread.patientId ?? "",
                              patientName: thread.patientName ?? "مريض",
                              isAssistantSide: true,
                              receiverFcmToken: thread.patientFcmToken,
                            ),
                            binding: Binding(),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// Thread Tile
// ─────────────────────────────────────────
class _ThreadTile extends StatelessWidget {
  final AssistantChatThread thread;
  final bool isUnread;
  final VoidCallback onTap;

  const _ThreadTile({
    required this.thread,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread
            ? AppColors.primary.withOpacity(0.06)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    (thread.patientName ?? "م")[0].toUpperCase(),
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
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
                          thread.patientName ?? "مريض",
                          style: isUnread
                              ? context.typography.mdBold
                              : context.typography.mdMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(thread.lastMessageTime),
                        style: context.typography.smRegular.copyWith(
                          color: isUnread
                              ? AppColors.primary
                              : AppColors.grayMedium,
                          fontSize: 11.sp,
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.lastMessage ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.smRegular.copyWith(
                      color: isUnread
                          ? AppColors.background_black
                          : AppColors.grayMedium,
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
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

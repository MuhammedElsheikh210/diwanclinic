import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import 'package:diwanclinic/Presentation/screens/assistant_chat/assistant_chat_detail_view.dart';
import 'package:diwanclinic/Presentation/screens/assistant_chat/assistant_chat_list_vm.dart';
import 'package:intl/intl.dart';
import '../../../index/index_main.dart';

/// Doctor side: read-only view of all assistant↔patient chat threads.
/// No notifications reach the doctor — chats open in read-only mode.
class AssistantChatsForDoctorView extends StatefulWidget {
  const AssistantChatsForDoctorView({super.key});

  @override
  State<AssistantChatsForDoctorView> createState() => _AssistantChatsForDoctorViewState();
}

class _AssistantChatsForDoctorViewState extends State<AssistantChatsForDoctorView> {
  late final String _doctorId;
  late final String _doctorName;

  @override
  void initState() {
    super.initState();
    final session = Get.find<UserSession>();
    final user = session.user?.user as DoctorUser?;
    _doctorId = user?.uid ?? "";
    _doctorName = session.user?.name ?? "الدكتور";
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
                          "ستظهر هنا محادثات المرضى مع المساعدة.",
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
                        return _DoctorThreadTile(
                          thread: thread,
                          onTap: () => Get.to(
                            () => AssistantChatDetailView(
                              assistantId: _doctorId,
                              assistantName: _doctorName,
                              patientId: thread.patientId ?? "",
                              patientName: thread.patientName ?? "مريض",
                              isAssistantSide: true,
                              isReadOnly: true,
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

class _DoctorThreadTile extends StatelessWidget {
  final AssistantChatThread thread;
  final VoidCallback onTap;

  const _DoctorThreadTile({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                (thread.patientName ?? "م")[0].toUpperCase(),
                style: context.typography.lgBold
                    .copyWith(color: AppColors.primary),
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
                          thread.patientName ?? "مريض",
                          style: context.typography.mdMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  Text(
                    thread.lastMessage ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.grayMedium,
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

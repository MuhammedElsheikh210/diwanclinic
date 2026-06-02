import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import 'package:diwanclinic/Presentation/screens/pharmacy_chat/pharmacy_chat_detail_view.dart';
import 'package:diwanclinic/Presentation/screens/pharmacy_chat/pharmacy_chat_list_vm.dart';
import 'package:intl/intl.dart';
import '../../../index/index_main.dart';

/// Pharmacist side: list of all patient chat threads.
class PharmacyChatListView extends StatefulWidget {
  const PharmacyChatListView({super.key});

  @override
  State<PharmacyChatListView> createState() => _PharmacyChatListViewState();
}

class _PharmacyChatListViewState extends State<PharmacyChatListView> {
  late final PharmacyChatListVm _vm;
  late final String _pharmacyId;
  late final String _pharmacyName;

  @override
  void initState() {
    super.initState();
    _vm = Get.put(PharmacyChatListVm());

    final session = Get.find<UserSession>();
    final pharmacy = session.user?.asPharmacy;
    _pharmacyId = pharmacy?.pharmacyId ?? pharmacy?.uid ?? "";
    _pharmacyName = session.user?.name ?? "الصيدلية";

    if (_pharmacyId.isNotEmpty) {
      _vm.listenChats(_pharmacyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyChatListVm>(
      builder: (vm) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: Text(
              "محادثات المرضى",
              style: context.typography.lgBold
                  .copyWith(color: AppColors.white),
            ),
            centerTitle: true,
          ),
          body: vm.threads == null
              ? const ShimmerLoader()
              : vm.threads!.isEmpty
                  ? NoDataAnimated(
                      title: "لا توجد محادثات بعد",
                      subtitle:
                          "ستظهر هنا محادثات المرضى عند بدء أي مريض للدردشة معك.",
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
                        final isUnread = thread.isPharmacyRead == false;
                        return _ThreadTile(
                          thread: thread,
                          isUnread: isUnread,
                          onTap: () => Get.to(
                            () => PharmacyChatDetailView(
                              pharmacyId: _pharmacyId,
                              pharmacyName: _pharmacyName,
                              patientId: thread.patientId ?? "",
                              patientName: thread.patientName ?? "مريض",
                              isPharmacySide: true,
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

class _ThreadTile extends StatelessWidget {
  final PharmacyChatThread thread;
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
        padding:
            EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 28,
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
                        thread.patientName ?? "مريض",
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

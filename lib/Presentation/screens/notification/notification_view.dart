import 'package:diwanclinic/Presentation/screens/notification/notification_item.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();

    // بعد ما الصفحة تترسم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<NotificationController>();
      controller.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text("الإشعارات", style: context.typography.lgBold),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: GetBuilder<NotificationController>(
            init: NotificationController(),
            builder: (controller) {
              // if (controller.isLoading) {
              //   return const Center(child: CircularProgressIndicator());
              // }

              if (controller.notifications.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد إشعارات بعد",
                    style: context.typography.mdMedium.copyWith(
                      color: AppColors.secondary100,
                    ),
                  ),
                );
              }

              final currentUser = Get.find<UserSession>().user;

              final bool isAssistant =
                  currentUser?.user.userType == UserType.assistant;

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notif = controller.notifications[index];
                  if (notif == null) return const SizedBox.shrink();

                  final formattedDate =
                      notif.createAt != null
                          ? DateFormat('dd/MM/yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              notif.createAt!,
                            ),
                          )
                          : '';

                  final bool isNewReservation =
                      notif.notificationType == "new_reservation";

                  ReservationModel? reservation;
                  if (notif.extraData != null &&
                      notif.extraData is Map<String, dynamic>) {
                    reservation = ReservationModel.fromJson(
                      Map<String, dynamic>.from(notif.extraData!),
                    );
                  }

                  final bool isPending =
                      reservation?.status == ReservationStatus.pending.value;

                  final bool showActions =
                      isAssistant && isNewReservation && isPending;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: NotificationItem(
                      title: notif.title ?? "إشعار جديد",
                      description: notif.body,
                      date: formattedDate,
                      isPatient: currentUser?.user.userType == UserType.patient,
                      imageUrl: reservation?.transfer_image,
                      isUnread: isPending,
                      showActions: showActions,

                      // ✅ ACCEPT
                      onAccept:
                          showActions && reservation != null
                              ? () => controller.confirmApproveReservation(
                                context: context,
                                reservation: reservation!,
                                notificationKey: notif.key!,
                              )
                              : null,

                      // ❌ REJECT
                      onReject:
                          showActions && reservation != null
                              ? () => controller.confirmRejectReservation(
                                context: context,
                                reservation: reservation!,
                                notificationKey: notif.key!,
                              )
                              : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

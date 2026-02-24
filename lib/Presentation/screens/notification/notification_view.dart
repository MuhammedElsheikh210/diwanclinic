import 'package:diwanclinic/Presentation/screens/notification/notification_item.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

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

              final currentUser = LocalUser().getUserData();
              final bool isAssistant =
                  currentUser.userType?.name == "assistant";

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notif = controller.notifications[index];
                  if (notif == null) return const SizedBox.shrink();

                  final formattedDate = notif.createAt != null
                      ? DateFormat('dd/MM/yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(notif.createAt!),
                        )
                      : '';

                  final bool isNewReservation =
                      notif.notificationType == "new_reservation";

                  final bool isUnread = !(notif.isRead ?? false);

                  final bool showActions =
                      isAssistant && isNewReservation && isUnread;

                  ReservationModel? reservation;
                  if (notif.extraData != null &&
                      notif.extraData is Map<String, dynamic>) {
                    reservation = ReservationModel.fromJson(
                      Map<String, dynamic>.from(notif.extraData!),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: NotificationItem(
                      title: notif.title ?? "إشعار جديد",
                      description: notif.body,
                      date: formattedDate,
                      isPatient: currentUser.userType?.name == "patient",
                      imageUrl: reservation?.transfer_image,
                      isUnread: isUnread,
                      showActions: showActions,

                      // ✅ ACCEPT
                      onAccept: showActions && reservation != null
                          ? () => controller.confirmApproveReservation(
                              context: context,
                              reservation: reservation!,
                              notificationKey: notif.key!,
                            )
                          : null,

                      // ❌ REJECT
                      onReject: showActions && reservation != null
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

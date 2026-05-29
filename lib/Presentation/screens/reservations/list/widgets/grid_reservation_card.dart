import 'package:diwanclinic/Global/managers/location_manager.dart';
import 'package:diwanclinic/index/index_main.dart';

class GridReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationViewModel controller;

  const GridReservationCard({
    super.key,
    required this.reservation,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ahead = (reservation.orderReserved ?? 0) - 1;

    final bool isCompleted =
        reservation.status == ReservationStatus.completed.value;

    final bool isCancelled =
        reservation.status == ReservationStatus.cancelledByAssistant.value ||
        reservation.status == ReservationStatus.cancelledByDoctor.value ||
        reservation.status == ReservationStatus.cancelledByUser.value;

    final Color statusColor = _statusColor(reservation.status);
    final String statusLabel = isCompleted
        ? "تم الكشف"
        : isCancelled
        ? "ملغي"
        : "";

    final paymentStatus = reservation.paymentStatus;
    final paymentBadge = _buildPaymentBadge(context, paymentStatus);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: paymentStatus == 'pending_payment'
              ? Colors.orange.shade300
              : paymentStatus == 'payment_rejected'
                  ? AppColors.errorForeground.withValues(alpha: 0.6)
                  : AppColors.borderNeutralPrimary.withValues(alpha: 0.4),
          width: paymentStatus != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------
              // LEFT SIDE (NAME + STATUS)
              // -------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.patientName ?? "بدون اسم",
                      style: context.typography.mdBold.copyWith(
                        color: AppColors.background_black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (isCompleted || isCancelled)
                      Text(
                        statusLabel,
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                  ],
                ),
              ),

              // -------------------------
              // RIGHT SIDE (QUEUE INFO)
              // -------------------------
              if (!isCompleted &&
                  !isCancelled &&
                  (paymentStatus == null || paymentStatus == 'payment_approved'))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ahead <= 0 ? "دورك الآن" : "قدّامك: $ahead",
                      style: context.typography.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "رقم: ${reservation.orderNum ?? "-"}",
                      style: context.typography.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ),
              _MapIconButton(controller: controller),
            ],
          ),

          // -------------------------
          // PAYMENT BADGE (if any)
          // -------------------------
          if (paymentBadge != null) ...[
            const SizedBox(height: 6),
            paymentBadge,
          ],

          // -------------------------
          // PAYMENT METHOD BADGE
          // -------------------------
          if (reservation.paymentMethod != null) ...[
            const SizedBox(height: 4),
            _PaymentMethodBadge(method: reservation.paymentMethod!),
          ],
        ],
      ),
    );
  }

  // -------------------------
  // PAYMENT BADGE HELPER
  // -------------------------
  Widget? _buildPaymentBadge(BuildContext context, String? paymentStatus) {
    if (paymentStatus == null) return null;

    final (icon, label, bgColor, textColor) = switch (paymentStatus) {
      'pending_payment' => (
          Icons.hourglass_empty_rounded,
          'بانتظار مراجعة الدفع',
          Colors.orange.shade50,
          Colors.orange.shade800,
        ),
      'payment_approved' => (
          Icons.check_circle_outline,
          'تم قبول الدفع',
          AppColors.successBackground,
          AppColors.successForeground,
        ),
      'payment_rejected' => (
          Icons.cancel_outlined,
          'تم رفض الدفع',
          AppColors.errorForeground.withValues(alpha: 0.08),
          AppColors.errorForeground,
        ),
      _ => (Icons.payment, paymentStatus, AppColors.background_neutral_100,
          AppColors.textDefault),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // STATUS COLOR HELPER
  // -------------------------
  Color _statusColor(String? status) {
    if (status == ReservationNewStatus.completed.value) {
      return AppColors.primary;
    }

    if (status == ReservationStatus.cancelledByAssistant.value ||
        status == ReservationStatus.cancelledByDoctor.value ||
        status == ReservationStatus.cancelledByUser.value) {
      return AppColors.errorForeground;
    }

    return AppColors.white;
  }
}

class _MapIconButton extends StatelessWidget {
  final ReservationViewModel controller;
  const _MapIconButton({required this.controller});

  Future<void> _openDirections() async {
    final clinic = controller.selectedClinic;
    final lat = clinic?.latitude;
    final lng = clinic?.longitude;

    if (lat == null || lng == null) {
      Get.snackbar("الموقع غير متاح", "لم يتم تحديد موقع العيادة بعد");
      return;
    }

    final userLatLng = await LocationManager().getLatLng();
    final Uri uri;
    if (userLatLng != null) {
      uri = Uri.parse(
        "https://www.google.com/maps/dir/?api=1"
        "&origin=${userLatLng['lat']},${userLatLng['lng']}"
        "&destination=$lat,$lng"
        "&travelmode=driving",
      );
    } else {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        controller.selectedClinic?.latitude != null &&
        controller.selectedClinic?.longitude != null;

    if (!hasLocation) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _openDirections,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.directions,
          size: 18,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _PaymentMethodBadge extends StatelessWidget {
  final String method;
  const _PaymentMethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (method) {
      'instapay' => (Icons.payment, 'InstaPay', Colors.green.shade700),
      'wallet' => (
          Icons.account_balance_wallet_outlined,
          'محفظة إلكترونية',
          Colors.blue.shade700,
        ),
      _ => (Icons.payments_outlined, 'كاش', Colors.orange.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.red, color.green, color.blue, 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Color.fromRGBO(color.red, color.green, color.blue, 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

import 'package:diwanclinic/Global/managers/location_manager.dart';
import '../../../../../../../index/index_main.dart';

class DoctorInfoSection extends StatelessWidget {
  final ReservationModel reservation;

  const DoctorInfoSection({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ReservationListTileWidget(
                  icon: IconsConstants.avatar,
                  title: "الدكتور",
                  body: reservation.doctorName ?? "غير معروف",
                ),
              ),

              if (reservation.clinicLatitude != null ||
                  reservation.clinicAddress?.isNotEmpty == true)
                _MapIconButton(reservation: reservation),
            ],
          ),

          if (reservation.paymentMethod != null) ...[
            const SizedBox(height: 8),
            _PaymentMethodBadge(
              method: reservation.paymentMethod!,
            ),
          ],

          // if (reservation.paymentStatus != null) ...[
          //   const SizedBox(height: 8),
          //   _PaymentStatusBadge(
          //     status: reservation.paymentStatus!,
          //   ),
          // ],

          if (reservation.paymentScreenshotUrl?.isNotEmpty == true) ...[
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                Get.dialog(
                  Dialog(
                    insetPadding: const EdgeInsets.all(16),
                    child: InteractiveViewer(
                      child: CachedNetworkImage(
                        imageUrl:
                        reservation.paymentScreenshotUrl!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                  reservation.paymentScreenshotUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

//══════════════════════════════════════════════
// MAP BUTTON
//══════════════════════════════════════════════

class _MapIconButton extends StatelessWidget {
  final ReservationModel reservation;

  const _MapIconButton({
    required this.reservation,
  });

  Future<void> _open() async {
    final lat = reservation.clinicLatitude;
    final lng = reservation.clinicLongitude;
    final address = reservation.clinicAddress;

    Uri uri;

    if (lat != null && lng != null) {
      final userLatLng = await LocationManager().getLatLng();

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
    } else if (address != null && address.isNotEmpty) {
      final encoded = Uri.encodeComponent(address);

      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$encoded",
      );
    } else {
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.directions,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

//══════════════════════════════════════════════
// PAYMENT METHOD
//══════════════════════════════════════════════

class _PaymentMethodBadge extends StatelessWidget {
  final String method;

  const _PaymentMethodBadge({
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (method) {
      'instapay' => (
      Icons.payment,
      'InstaPay',
      Colors.green.shade700,
      ),

      'wallet' => (
      Icons.account_balance_wallet_outlined,
      'محفظة إلكترونية',
      Colors.blue.shade700,
      ),

      _ => (
      Icons.payments_outlined,
      'كاش',
      Colors.orange.shade700,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          color.red,
          color.green,
          color.blue,
          0.08,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color.fromRGBO(
            color.red,
            color.green,
            color.blue,
            0.3,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            "طريقة الدفع: $label",
            style: context.typography.xsMedium.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

//══════════════════════════════════════════════
// PAYMENT STATUS
//══════════════════════════════════════════════

class _PaymentStatusBadge extends StatelessWidget {
  final String status;

  const _PaymentStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, text, color) = switch (status) {
      'pending_payment' => (
      Icons.hourglass_top,
      'بانتظار مراجعة الدفع',
      Colors.orange,
      ),

      'payment_approved' => (
      Icons.check_circle,
      'تم قبول الدفع',
      Colors.green,
      ),

      'payment_rejected' => (
      Icons.cancel,
      'تم رفض الدفع',
      Colors.red,
      ),

      _ => (
      Icons.info_outline,
      status,
      Colors.grey,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: context.typography.xsMedium.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
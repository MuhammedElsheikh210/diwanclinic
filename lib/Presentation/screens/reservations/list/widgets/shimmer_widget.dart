import 'package:shimmer/shimmer.dart';
import '../../../../../index/index_main.dart';

class ReservationCardShimmer extends StatelessWidget {
  const ReservationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorMappingImpl();

    // 🎨 Perfect shimmer palette
    final base = colors.background_neutral_100.withOpacity(0.55);
    final highlight = Colors.white.withOpacity(0.28);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1100),
      direction: ShimmerDirection.ltr,

      child: Container(
        margin: EdgeInsets.only(bottom: 14.h, left: 8.w, right: 8.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.borderNeutralPrimary,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderShimmer(colors),
            SizedBox(height: 12.h),
            _buildPatientSection(colors),
            SizedBox(height: 10.h),
            _buildPaymentPrescription(colors),
            SizedBox(height: 12.h),
            _buildTypeDate(colors),
            SizedBox(height: 14.h),
            _buildButtons(colors),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🔹 HEADER SHIMMER
  // ============================================================
  Widget _buildHeaderShimmer(ColorMappingImpl colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.background_neutral_100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _shimmerBox(width: 90.w, height: 15.h),
          Row(
            children: [
              _shimmerBox(width: 60.w, height: 20.h, radius: 20),
              SizedBox(width: 10.w),
              _shimmerCircle(size: 26.h),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔹 PATIENT + IMAGE
  // ============================================================
  Widget _buildPatientSection(ColorMappingImpl colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          _shimmerBox(width: 42.h, height: 42.h, radius: 12),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 140.w, height: 13.h),
                SizedBox(height: 8.h),
                _shimmerBox(width: 180.w, height: 13.h),
              ],
            ),
          ),

          SizedBox(width: 10.w),
          _shimmerBox(width: 85.w, height: 55.h, radius: 10),
        ],
      ),
    );
  }

  // ============================================================
  // 🔹 PAYMENT + PRESCRIPTION
  // ============================================================
  Widget _buildPaymentPrescription(ColorMappingImpl colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _shimmerBox(height: 58.h, radius: 14),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _shimmerBox(height: 78.h, radius: 14),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔹 TYPE + DATE
  // ============================================================
  Widget _buildTypeDate(ColorMappingImpl colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(child: _shimmerBox(height: 44.h, radius: 12)),
          SizedBox(width: 10.w),
          Expanded(child: _shimmerBox(height: 44.h, radius: 12)),
        ],
      ),
    );
  }

  // ============================================================
  // 🔹 BUTTONS
  // ============================================================
  Widget _buildButtons(ColorMappingImpl colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(child: _shimmerBox(height: 38.h, radius: 10)),
          SizedBox(width: 12.w),
          Expanded(child: _shimmerBox(height: 38.h, radius: 10)),
        ],
      ),
    );
  }

  // ============================================================
  // 🔸 COMMON SHIMMER BOX
  // ============================================================
  Widget _shimmerBox({
    required double height,
    double? width,
    double radius = 8,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _shimmerCircle({required double size}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}


class ReservationCardSkeletonShimmer extends StatelessWidget {
  const ReservationCardSkeletonShimmer({super.key});

  static const Color _base = Color(0xFFE5E7EB);
  static const Color _highlight = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: _base,
        highlightColor: _highlight,
        period: const Duration(milliseconds: 1200),

        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),

          // FIX 1: REMOVE WHITE BACKGROUND (this was hiding all skeletons)
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _base),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerShimmer(),
              _patientRowShimmer(),
              _paymentPrescriptionShimmer(),
              _typeDateShimmer(),
              _buttonsShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),

      // FIX 2: SHOW TRUE SKELETON GRAY
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(width: 90.w, height: 14.h),
              SizedBox(height: 6.h),
              _box(width: 120.w, height: 14.h),
            ],
          ),
          Row(
            children: [
              _box(width: 70.w, height: 22.h, radius: 20),
              SizedBox(width: 8.w),
              _circle(size: 26.h),
            ],
          ),
        ],
      ),
    );
  }

  Widget _patientRowShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _circle(size: 42.h),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 150.w, height: 12.h),
                SizedBox(height: 8.h),
                _box(width: 180.w, height: 12.h),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _box(width: 85.w, height: 55.h, radius: 10),
        ],
      ),
    );
  }

  Widget _paymentPrescriptionShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(child: _box(height: 60.h, radius: 14)),
          SizedBox(width: 10.w),
          Expanded(child: _box(height: 80.h, radius: 14)),
        ],
      ),
    );
  }

  Widget _typeDateShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(child: _box(height: 45.h, radius: 12)),
          SizedBox(width: 10.w),
          Expanded(child: _box(height: 45.h, radius: 12)),
        ],
      ),
    );
  }

  Widget _buttonsShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Expanded(child: _box(height: 38.h, radius: 10)),
          SizedBox(width: 12.w),
          Expanded(child: _box(height: 38.h, radius: 10)),
        ],
      ),
    );
  }

  Widget _box({double? width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _circle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: _base,
        shape: BoxShape.circle,
      ),
    );
  }
}

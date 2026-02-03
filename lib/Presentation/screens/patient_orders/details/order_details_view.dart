import '../../../../index/index_main.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    // List of prescription URLs
    final List<String> prescriptionImages = [
      order.prescriptionUrl1,
      order.prescriptionUrl2,
      order.prescriptionUrl3,
      order.prescriptionUrl4,
      order.prescriptionUrl5,
    ].where((e) => e != null && e.isNotEmpty).cast<String>().toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: AppText(
            text: "تفاصيل الطلب",
            textStyle: typography.lgBold.copyWith(color: AppColors.textDisplay),
          ),
        ),

        body: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // ===============================
            // 🧑‍⚕️ Patient Info
            // ===============================
            _section(
              context,
              title: "بيانات العميل",
              children: [
                _row(context, "الطبيب", order.doctorName),
                _row(context, "الاسم", order.patientName),
                _row(context, "الهاتف", order.phone),
                _row(context, "واتساب", order.whatsApp),
                _row(context, "العنوان", order.address),
              ],
            ),

            // ===============================
            // 📄 Prescription Images
            // ===============================
            _section(
              context,
              title: "صور الروشتة",
              children: [
                if (prescriptionImages.isEmpty)
                  _emptyPrescription(context)
                else
                  _prescriptionGallery(context, prescriptionImages),
              ],
            ),

            // ===============================
            // 💰 Financial Info
            // ===============================
            _section(
              context,
              title: "الدفع والتكلفة",
              children: [
                _row(context, "قبل الخصم", "${order.totalOrder ?? 0} ج.م"),
                _row(context, "الخصم", "${order.discount ?? 0} ج.م"),
                _row(
                  context,
                  "مصاريف التوصيل",
                  "${order.deliveryFees ?? 0} ج.م",
                ),
                _row(
                  context,
                  "الإجمالي النهائي",
                  "${order.finalAmount ?? 0} ج.م",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Section Wrapper
  // ---------------------------------------------------------
  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              textStyle: context.typography.mdBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
            SizedBox(height: 12.h),
            ...children,
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Row item (Label + Value)
  // ---------------------------------------------------------
  Widget _row(BuildContext context, String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: label,
            textStyle: context.typography.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: AppText(
                text: value?.toString() ?? "—",
                textStyle: context.typography.mdMedium.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // Empty Prescription Placeholder
  // ---------------------------------------------------------
  Widget _emptyPrescription(BuildContext context) {
    return Container(
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderNeutralPrimary),
        color: AppColors.background_neutral_25,
      ),
      child: Center(
        child: AppText(
          text: "لا توجد صور للروشتة",
          textStyle: context.typography.mdMedium.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Prescription Image Gallery
  // ---------------------------------------------------------
  Widget _prescriptionGallery(BuildContext context, List<String> images) {
    return SizedBox(
      height: 160.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => Get.to(() => ImageViewer(url: images[i])),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                images[i],
                width: 120.w,
                height: 160.h,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // Date Formatter
  // ---------------------------------------------------------
  String _formatDate(int? timestamp) {
    if (timestamp == null) return "—";
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}

// ------------------------------------------------------------------
// ⭐ OPTIONAL: Simple Fullscreen Image Viewer
// ------------------------------------------------------------------
class ImageViewer extends StatelessWidget {
  final String url;

  const ImageViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(child: Image.network(url)),
    );
  }
}

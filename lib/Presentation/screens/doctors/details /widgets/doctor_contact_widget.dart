import '../../../../../index/index_main.dart';

class DoctorContactWidget extends StatelessWidget {
  final LocalUser doctor;

  const DoctorContactWidget({super.key, required this.doctor});

  // 🔹 Open phone call
  void _callPhone(String number) async {
    final uri = Uri.parse("tel:$number");
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // 🔹 Open WhatsApp
  void _openWhatsApp(String phone) async {
    final formatted = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse("https://wa.me/$formatted");
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // 🔹 Open social link
  void _openLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final d = doctor.asDoctor; // ✅ الحل

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowUpper.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: AppColors.borderNeutralPrimary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Contact Buttons
            if ((d?.phone?.isNotEmpty == true))
              Column(
                children: [
                  // 🔵 Call
                  GestureDetector(
                    onTap: () => _callPhone(d!.phone!),
                    child: Container(
                      height: 48.h,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1570EF),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1570EF).withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.call_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "اتصال",
                            style: typography.mdBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🟢 WhatsApp (نفس رقم الموبايل)
                  GestureDetector(
                    onTap: () => _openWhatsApp(d?.phone ?? ""),
                    child: Container(
                      height: 48.h,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF25D366).withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            IconsConstants.whats,
                            width: 30.w,
                            height: 30.h,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "واتساب",
                            style: typography.mdBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            _divider(),

            // 🔹 Social Links
            Text(
              "تابعنا على وسائل التواصل",
              style: typography.lgBold.copyWith(color: AppColors.textDisplay),
            ),
            SizedBox(height: 16.h),

            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (d?.facebookLink?.isNotEmpty == true)
                  _socialButton(
                    icon: Icons.facebook_rounded,
                    label: "Facebook",
                    color: const Color(0xFF1877F2),
                    onTap: () => _openLink(d!.facebookLink),
                  ),
                if (d?.instagramLink?.isNotEmpty == true)
                  _socialButton(
                    icon: Icons.camera_alt_rounded,
                    label: "Instagram",
                    color: const Color(0xFFE1306C),
                    onTap: () => _openLink(d!.instagramLink),
                  ),
                if (d?.tiktokLink?.isNotEmpty == true)
                  _socialButton(
                    icon: Icons.music_note_rounded,
                    label: "TikTok",
                    color: Colors.black,
                    onTap: () => _openLink(d!.tiktokLink),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8.r),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Container(
      height: 1,
      color: AppColors.borderNeutralPrimary.withOpacity(0.25),
    ),
  );
}

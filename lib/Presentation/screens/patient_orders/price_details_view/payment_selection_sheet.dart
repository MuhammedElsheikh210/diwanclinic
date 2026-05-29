import 'dart:io';
import '../../../../index/index_main.dart';

class PaymentSelectionSheet extends StatefulWidget {
  final String? walletNumber;
  final String? instapayNumber;
  final String? instapayLink;
  final num finalAmount;

  const PaymentSelectionSheet({
    super.key,
    required this.finalAmount,
    this.walletNumber,
    this.instapayNumber,
    this.instapayLink,
  });

  @override
  State<PaymentSelectionSheet> createState() => _PaymentSelectionSheetState();
}

class _PaymentSelectionSheetState extends State<PaymentSelectionSheet> {
  String _selected = 'cash';
  File? _screenshotFile;
  bool _isUploading = false;

  bool get _hasWallet =>
      widget.walletNumber != null && widget.walletNumber!.isNotEmpty;

  bool get _hasInstapay =>
      (widget.instapayNumber != null && widget.instapayNumber!.isNotEmpty) ||
      (widget.instapayLink != null && widget.instapayLink!.isNotEmpty);

  bool get _needsScreenshot => _selected != 'cash';

  bool get _canConfirm =>
      _selected == 'cash' || (_needsScreenshot && _screenshotFile != null);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            AppText(
              text: "اختر طريقة الدفع",
              textStyle: context.typography.lgBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
            SizedBox(height: 6.h),
            AppText(
              text: "الإجمالي: ${widget.finalAmount} ج.م",
              textStyle: context.typography.mdMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),

            // ─── Cash ───
            _PaymentOption(
              selected: _selected == 'cash',
              icon: Icons.money_outlined,
              title: "كاش",
              subtitle: "الدفع عند الاستلام",
              onTap: () => setState(() {
                _selected = 'cash';
                _screenshotFile = null;
              }),
            ),

            // ─── Wallet ───
            if (_hasWallet) ...[
              SizedBox(height: 10.h),
              _PaymentOption(
                selected: _selected == 'wallet',
                icon: Icons.account_balance_wallet_outlined,
                title: "محفظة إلكترونية",
                subtitle: "رقم التحويل: ${widget.walletNumber}",
                onTap: () => setState(() {
                  _selected = 'wallet';
                  _screenshotFile = null;
                }),
              ),
            ],

            // ─── InstaPay ───
            if (_hasInstapay) ...[
              SizedBox(height: 10.h),
              _PaymentOption(
                selected: _selected == 'instapay',
                icon: Icons.bolt_outlined,
                title: "InstaPay",
                subtitle: _buildInstapaySubtitle(),
                instapayLink: widget.instapayLink,
                onTap: () => setState(() {
                  _selected = 'instapay';
                  _screenshotFile = null;
                }),
              ),
            ],

            // ─── Screenshot Upload ───
            if (_needsScreenshot) ...[
              SizedBox(height: 20.h),
              _ScreenshotUploader(
                file: _screenshotFile,
                onPick: _pickScreenshot,
              ),
            ],

            SizedBox(height: 24.h),

            // ─── Confirm Button ───
            PrimaryTextButton(
              appButtonSize: AppButtonSize.xxLarge,
              onTap: _canConfirm ? _confirm : null,
              customBackgroundColor:
                  _canConfirm ? AppColors.primary : AppColors.grayLight,
              label: AppText(
                text: _isUploading ? "جارٍ الرفع..." : "تأكيد الدفع",
                textStyle: context.typography.mdBold.copyWith(
                  color: _canConfirm ? AppColors.white : AppColors.textSecondaryParagraph,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  String _buildInstapaySubtitle() {
    final parts = <String>[];
    if (widget.instapayNumber != null && widget.instapayNumber!.isNotEmpty) {
      parts.add("رقم: ${widget.instapayNumber}");
    }
    if (widget.instapayLink != null && widget.instapayLink!.isNotEmpty) {
      parts.add("لينك متاح للضغط");
    }
    return parts.join(" · ");
  }

  Future<void> _pickScreenshot() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _screenshotFile = File(picked.path));
    }
  }

  Future<void> _confirm() async {
    if (_isUploading) return;

    String? screenshotUrl;

    if (_screenshotFile != null) {
      setState(() => _isUploading = true);
      try {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        final ref = FirebaseStorage.instance
            .ref()
            .child("order_payment_screenshots/$fileName");
        await ref.putFile(_screenshotFile!);
        screenshotUrl = await ref.getDownloadURL();
      } catch (_) {
        setState(() => _isUploading = false);
        Loader.showError("فشل رفع السكرين شوت، حاول مرة أخرى");
        return;
      }
      setState(() => _isUploading = false);
    }

    Get.back(result: (method: _selected, screenshotUrl: screenshotUrl));
  }
}

// ─────────────────────────────────────────────
// Payment Option Card
// ─────────────────────────────────────────────
class _PaymentOption extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? instapayLink;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.instapayLink,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.07)
              : AppColors.background_neutral_25,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderNeutralPrimary,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondaryParagraph,
                size: 22,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    textStyle: context.typography.mdBold.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textDisplay,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    text: subtitle,
                    textStyle: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                  if (selected && instapayLink != null && instapayLink!.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.tryParse(instapayLink!);
                        if (uri != null) await launchUrl(uri);
                      },
                      child: AppText(
                        text: "افتح لينك الدفع",
                        textStyle: context.typography.smSemiBold.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.borderNeutralPrimary,
                  width: 2,
                ),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Screenshot Uploader
// ─────────────────────────────────────────────
class _ScreenshotUploader extends StatelessWidget {
  final File? file;
  final VoidCallback onPick;

  const _ScreenshotUploader({required this.file, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "إيصال الدفع (مطلوب)",
          textStyle: context.typography.smSemiBold.copyWith(
            color: AppColors.textDisplay,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            height: file != null ? 160.h : 90.h,
            decoration: BoxDecoration(
              color: AppColors.background_neutral_25,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: file != null
                    ? AppColors.primary
                    : AppColors.borderNeutralPrimary,
                width: file != null ? 1.5 : 1,
                style: file != null ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(file!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.textSecondaryParagraph,
                        size: 28.w,
                      ),
                      SizedBox(height: 6.h),
                      AppText(
                        text: "ارفع سكرين شوت الدفع",
                        textStyle: context.typography.smMedium.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

import '../../../index/index_main.dart';

/// Two-phase rating sheet — single DraggableScrollableSheet that expands.
///
/// Phase 1: compact (42% height) — icon + title + stars only.
/// Phase 2: full   (92% height) — full content fades in automatically.
class PatientRatingSheet {
  static Future<void> show({
    required BuildContext context,
    required ReservationModel reservation,
    required ReservationPatientViewModel viewModel,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (_) => _PatientRatingWidget(
        reservation: reservation,
        viewModel: viewModel,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _PatientRatingWidget extends StatefulWidget {
  final ReservationModel reservation;
  final ReservationPatientViewModel viewModel;

  const _PatientRatingWidget({
    required this.reservation,
    required this.viewModel,
  });

  @override
  State<_PatientRatingWidget> createState() => _PatientRatingWidgetState();
}

class _PatientRatingWidgetState extends State<_PatientRatingWidget> {
  int _rating = 0;
  bool _isExpanded = false;
  bool _isSubmitting = false;
  final Set<String> _selectedTags = {};
  final TextEditingController _commentCtrl = TextEditingController();
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();

  static const _compactSize = 0.44;
  static const _fullSize    = 0.93;

  static const _tags = [
    "جودة الكشف",
    "سهولة الحجز",
    "التعامل مع الطاقم",
    "الدقة في المواعيد",
    "وضوح التشخيص",
  ];

  static const _ratingLabels = ["", "سيء", "مقبول", "جيد", "جيد جداً", "ممتاز"];

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  // ── tap a star in phase-1 → expand to full ───────────────────
  Future<void> _onStarTap(int star) async {
    // 1. Rebuild with full content first so there's something to scroll to
    setState(() {
      _rating    = star;
      _isExpanded = true;
    });

    // 2. Give Flutter one frame to lay out the new content, then animate
    await Future.delayed(const Duration(milliseconds: 30));

    try {
      await _sheetCtrl.animateTo(
        _fullSize,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      // animateTo can throw if controller is briefly detached — ignore
    }
  }

  // ── change star while in phase-2 ─────────────────────────────
  void _onStarChange(int star) => setState(() => _rating = star);

  // ── submit ────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_isSubmitting || _rating == 0) return;
    setState(() => _isSubmitting = true);

    final user = Get.find<UserSession>().user;
    final key  = const Uuid().v4();
    final note = _selectedTags.isNotEmpty
        ? "[${_selectedTags.join(', ')}] ${_commentCtrl.text.trim()}"
        : _commentCtrl.text.trim();

    final review = DoctorReviewModel(
      path:        key,
      key:         key,
      doctorId:    widget.reservation.doctorUid   ?? "",
      patientId:   user?.uid                      ?? "",
      patientName: user?.name                     ?? "",
      comment:     note,
      rateValue:   _rating,
      reserv_id:   widget.reservation.key         ?? "",
      createdAt:   DateTime.now().millisecondsSinceEpoch,
    );

    Navigator.pop(context);
    widget.viewModel.addFeedBack(review, widget.reservation);
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller:      _sheetCtrl,
      initialChildSize: _compactSize,
      minChildSize:     _compactSize,
      maxChildSize:     _fullSize,
      snap:             true,
      snapSizes:        const [_compactSize, _fullSize],
      expand:           false,
      builder: (_, scrollCtrl) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            color: const Color(0xFFFAF5F0),
            child: ListView(
              controller: scrollCtrl,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              children: [
                _handle(),
                _closeBtn(),
                const SizedBox(height: 6),
                _icon(),
                const SizedBox(height: 14),
                _title(),
                const SizedBox(height: 20),
                _stars(),
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  _ratingLabel(),
                  // Full content fades in automatically via TweenAnimationBuilder
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOut,
                    builder: (_, v, child) =>
                        Opacity(opacity: v, child: child),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 28),
                        _commentSection(),
                        const SizedBox(height: 24),
                        _tagsSection(),
                        const SizedBox(height: 32),
                        _submitBtn(),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 28),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── sub-widgets ───────────────────────────────────────────────

  Widget _handle() => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 2),
        child: Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );

  Widget _closeBtn() => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 6),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.black45),
            ),
          ),
        ),
      );

  Widget _icon() => Center(
        child: Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_hospital_rounded,
            color: AppColors.primary,
            size: 32,
          ),
        ),
      );

  Widget _title() => Center(
        child: Text(
          "كيف كانت تجربتك معنا؟",
          style: context.typography.lgBold.copyWith(
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
      );

  Widget _stars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < _rating;
        return GestureDetector(
          onTap: _isExpanded ? () => _onStarChange(i + 1) : () => _onStarTap(i + 1),
          child: AnimatedScale(
            scale: filled ? 1.18 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.elasticOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: const Color(0xFFF5A623),
                size: 48,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _ratingLabel() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          _ratingLabels[_rating],
          key: ValueKey(_rating),
          style: context.typography.mdMedium.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
      );

  Widget _commentSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "أخبرنا المزيد",
              style:
                  context.typography.mdBold.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              maxLength: 500,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "شاركنا تجربتك وساعد الناس تختار الأفضل",
                hintStyle: context.typography.smRegular
                    .copyWith(color: Colors.black38),
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _tagsSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "ما هو أكثر شيء أحببته في كشفك؟",
              style:
                  context.typography.mdBold.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: _tags.map((tag) {
                final sel = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () => setState(() =>
                      sel ? _selectedTags.remove(tag) : _selectedTags.add(tag)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.primary : Colors.black12,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: context.typography.smMedium.copyWith(
                        color: sel ? AppColors.primary : Colors.black54,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );

  Widget _submitBtn() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isSubmitting || _rating == 0) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    "أكمل",
                    style: context.typography.mdBold.copyWith(
                        color: Colors.white, fontSize: 16),
                  ),
          ),
        ),
      );
}

import '../../../../../../../../index/index_main.dart';

class FeedbackSheet extends StatefulWidget {
  final ReservationModel reservation;
  final ReservationPatientViewModel controller;

  const FeedbackSheet({
    super.key,
    required this.reservation,
    required this.controller,
  });

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  double rating = 0;
  final TextEditingController comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.40,
      maxChildSize: 0.90,
      builder: (_, scrollController) {
        return SafeArea(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Text(
                  "تقييم الدكتور",
                  style: context.typography.xlBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "من فضلك قيّم تجربتك مع الطبيب",
                  style: context.typography.mdRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),

                const SizedBox(height: 20),

                // ⭐ Rating stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < rating;
                    return IconButton(
                      onPressed: () {
                        setState(() => rating = i + 1.0);
                      },
                      icon: Icon(
                        filled ? Icons.star : Icons.star_border_rounded,
                        color: filled ? Colors.amber : Colors.grey.shade400,
                        size: 32,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: comment,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "أضف تعليقك (اختياري)...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: PrimaryTextButton(
                    appButtonSize: AppButtonSize.xxLarge,
                    customBackgroundColor: AppColors.primary,
                    label: AppText(
                      text: "إرسال التقييم",
                      textStyle: context.typography.mdBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      if (rating == 0) {
                        Loader.showInfo("يرجى اختيار التقييم أولاً");
                        return;
                      }

                      final user = Get.find<UserSession>().user;

                      final reviewKey = const Uuid().v4().toString();
                      final doctorKey = widget.reservation.doctorUid ?? "";
                      

                      final review = DoctorReviewModel(
                        path: reviewKey,
                        key: reviewKey,
                        doctorId: doctorKey,
                        patientId: user?.uid ?? "",
                        patientName: user?.name ?? "",
                        comment: comment.text.trim(),
                        rateValue: rating.toInt(),
                        reserv_id: widget.reservation.key ?? "",
                        createdAt: DateTime.now().millisecondsSinceEpoch,
                      );

                      Navigator.pop(context);
                      print("model is ${review.toJson()}");
                      widget.controller.addFeedBack(review, widget.reservation);
                    },
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

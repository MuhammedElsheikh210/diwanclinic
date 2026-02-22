import '../../../../../../index/index_main.dart';

class HorizontalStepper extends StatefulWidget {
  final int currentStep;
  final List<String> titles;
  final List<String> subtitles;

  const HorizontalStepper({
    Key? key,
    required this.currentStep,
    required this.titles,
    required this.subtitles,
  }) : super(key: key);

  @override
  State<HorizontalStepper> createState() => _HorizontalStepperState();
}

class _HorizontalStepperState extends State<HorizontalStepper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentStep());
  }

  @override
  void didUpdateWidget(HorizontalStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _scrollToCurrentStep();
    }
  }

  void _scrollToCurrentStep() {
    double offset = 0;
    if (widget.currentStep >= 2) {
      // Scroll to the right for steps 3 or 4
      offset = (widget.currentStep - 1) * 130; // Adjust scroll offset
    } else if (widget.currentStep >= 1) {
      // Scroll to the left for steps 1 or 2
      offset = (widget.currentStep - 1) * 130; // Adjust scroll offset
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.titles.length * 2 - 1, (index) {
          /// لو index زوجي → Step
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < widget.currentStep;
            final isCurrent = stepIndex == widget.currentStep;

            return Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isCurrent || isCompleted
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : Text(
                            "${stepIndex + 1}",
                            style: context.typography.mdBold.copyWith(
                              color: isCurrent
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                  ),
                ),
              ),
            );
          }

          /// لو index فردي → Line
          final previousStep = (index - 1) ~/ 2;
          final isCompleted = previousStep < widget.currentStep;

          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }
}

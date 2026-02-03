// treatment_tracking_list_ds.dart
import '../../../../index/index_main.dart';
import 'package:flutter/material.dart';

/// Modern Treatment Tracking Screen — Design System ready
/// + extended History per medicine (cards per day)
class TreatmentTrackingListScreen extends StatefulWidget {
  const TreatmentTrackingListScreen({super.key});

  @override
  State<TreatmentTrackingListScreen> createState() =>
      _TreatmentTrackingListScreenState();
}

class _TreatmentTrackingListScreenState
    extends State<TreatmentTrackingListScreen> {
  // -----------------------
  // STATIC MOCK DATA (includes history)
  // -----------------------
  List<Map<String, dynamic>> medicines = [
    {
      "id": "m1",
      "name": "Brufen 400",
      "totalDoses": 14,
      "takenBefore": 5,
      "scheduleTimes": ["9:00 ص", "3:00 م", "9:00 م"],
      "todayTaken": [false, false, true],
      "details": "كبسولتين بعد الأكل",
      "notes": "تناول مع الماء",
      // History keyed by date (ISO-like string for demo)
      "history": {
        "2025-12-03": [
          {"time": "9:00 ص", "taken": true, "takenAt": "9:05 ص"},
          {"time": "3:00 م", "taken": false, "takenAt": null},
          {"time": "9:00 م", "taken": true, "takenAt": "9:12 م"},
        ],
        "2025-12-02": [
          {"time": "9:00 ص", "taken": true, "takenAt": "9:01 ص"},
          {"time": "3:00 م", "taken": true, "takenAt": "3:05 م"},
          {"time": "9:00 م", "taken": false, "takenAt": null},
        ],
      },
    },
    {
      "id": "m2",
      "name": "Vitamin C",
      "totalDoses": 10,
      "takenBefore": 3,
      "scheduleTimes": ["12:00 م"],
      "todayTaken": [false],
      "details": "قرص واحد يومياً",
      "notes": "يفضل بعد الوجبة",
      "history": {
        "2025-12-03": [
          {"time": "12:00 م", "taken": true, "takenAt": "12:10 م"},
        ],
        "2025-12-02": [
          {"time": "12:00 م", "taken": true, "takenAt": "12:02 م"},
        ],
      },
    },
    {
      "id": "m3",
      "name": "Zinc",
      "totalDoses": 12,
      "takenBefore": 1,
      "scheduleTimes": ["8:00 ص", "8:00 م"],
      "todayTaken": [false, false],
      "details": "قرص واحد بعد الطعام",
      "notes": "لا تتناول مع الحليب",
      "history": {
        "2025-12-03": [
          {"time": "8:00 ص", "taken": false, "takenAt": null},
          {"time": "8:00 م", "taken": false, "takenAt": null},
        ],
      },
    },
  ];

  // helper: mark next dose taken for a given medicine
  void _takeNextDose(Map<String, dynamic> med) {
    final List<dynamic> taken = List<dynamic>.from(med["todayTaken"]);
    for (int i = 0; i < taken.length; i++) {
      if (taken[i] == false) {
        setState(() {
          taken[i] = true;
          med["todayTaken"] = taken;
          // append to today's history quick demo
          _appendHistoryEntry(
            med,
            DateTime.now(),
            med["scheduleTimes"][i],
            true,
          );
        });
        return;
      }
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(AppSnackBar.info("انتهت جرعات اليوم لهذا الدواء"));
  }

  // toggle single dose
  void _toggleDose(Map<String, dynamic> med, int idx) {
    final List<dynamic> taken = List<dynamic>.from(med["todayTaken"]);
    setState(() {
      taken[idx] = !(taken[idx] as bool);
      med["todayTaken"] = taken;
      // update history demo: record toggle time when marking taken
      if (taken[idx] == true) {
        _appendHistoryEntry(
          med,
          DateTime.now(),
          med["scheduleTimes"][idx],
          true,
        );
      }
    });
  }

  /// Append an entry to history for a given date (date: DateTime)
  void _appendHistoryEntry(
    Map<String, dynamic> med,
    DateTime date,
    String time,
    bool taken,
  ) {
    final key = _formatDateKey(date);
    final history = Map<String, dynamic>.from(med["history"] ?? {});
    final list = List<Map<String, dynamic>>.from(history[key] ?? []);
    list.add({
      "time": time,
      "taken": taken,
      "takenAt": taken ? _formatTimeShort(date) : null,
    });
    history[key] = list;
    med["history"] = history;
  }

  String _formatDateKey(DateTime d) {
    // yyyy-MM-dd simple
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _formatTimeShort(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? "م" : "ص";
    final hour12 = (h % 12 == 0) ? 12 : h % 12;
    return "$hour12:$m $period";
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: AppText(
            text: "متابعة العلاج",
            textStyle: context.typography.xlBold.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
        ),
        body: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            final med = medicines[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: MedicineCardModern(
                medicine: med,
                onOpenDoses: () => _openMedicineDosesSheet(med),
                onQuickTake: () => _takeNextDose(med),
                onToggleDose: (i) => _toggleDose(med, i),
                onOpenHistory: () => _openHistorySheet(med),
              ),
            );
          },
        ),
      ),
    );
  }

  // Bottom sheet: doses list + actions
  void _openMedicineDosesSheet(Map<String, dynamic> med) {
    final List<String> times = List<String>.from(med["scheduleTimes"]);
    final List<dynamic> taken = List<dynamic>.from(med["todayTaken"]);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 16.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 18.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48.w,
                    height: 6.h,
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.grayLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                AppText(
                  text: "جرعات اليوم — ${med["name"]}",
                  textStyle: context.typography.lgBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),

                SizedBox(height: 10.h),

                // list of doses
                ...List.generate(times.length, (i) {
                  final isTaken = (taken[i] as bool);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: DoseRowDS(
                      index: i,
                      time: times[i],
                      taken: isTaken,
                      onToggle: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          final t = List<dynamic>.from(med["todayTaken"]);
                          t[i] = !t[i];
                          med["todayTaken"] = t;
                          if (t[i] == true) {
                            _appendHistoryEntry(
                              med,
                              DateTime.now(),
                              times[i],
                              true,
                            );
                          }
                        });
                      },
                    ),
                  );
                }),

                SizedBox(height: 6.h),

                AppText(
                  text: med["details"] ?? "",
                  textStyle: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),

                SizedBox(height: 14.h),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryTextButton(
                        appButtonSize: AppButtonSize.large,
                        customBackgroundColor: AppColors.white,
                        customBorder: const BorderSide(
                          color: AppColors.borderNeutralPrimary,
                          width: 1,
                        ),
                        label: AppText(
                          text: "إغلاق",
                          textStyle: context.typography.mdMedium.copyWith(
                            color: AppColors.textDisplay,
                          ),
                        ),
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: PrimaryTextButton(
                        appButtonSize: AppButtonSize.large,
                        label: AppText(
                          text: "تعليم الجرعة التالية",
                          textStyle: context.typography.mdBold.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _takeNextDose(med);
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------
  // History sheet: advanced cards per day
  // ----------------------------
  void _openHistorySheet(Map<String, dynamic> med) {
    final historyMap = Map<String, dynamic>.from(med["history"] ?? {});
    // sort dates descending
    final dates = historyMap.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // recent first

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 14.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 14.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // handle
                  Center(
                    child: Container(
                      width: 48.w,
                      height: 6.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.grayLight,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  AppText(
                    text: "سجل الجرعات — ${med["name"]}",
                    textStyle: context.typography.lgBold.copyWith(
                      color: AppColors.textDisplay,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // if empty
                  if (dates.isEmpty)
                    Expanded(
                      child: Center(
                        child: AppText(
                          text: "لا يوجد سجل بعد",
                          textStyle: context.typography.mdMedium.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: dates.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (_, idx) {
                          final dateKey = dates[idx];
                          final entries = List<Map<String, dynamic>>.from(
                            historyMap[dateKey] ?? [],
                          );
                          return _historyDayCard(context, dateKey, entries);
                        },
                      ),
                    ),

                  SizedBox(height: 12.h),

                  PrimaryTextButton(
                    appButtonSize: AppButtonSize.large,
                    customBackgroundColor: AppColors.white,
                    customBorder: const BorderSide(
                      color: AppColors.borderNeutralPrimary,
                      width: 1,
                    ),
                    label: AppText(
                      text: "إغلاق",
                      textStyle: context.typography.mdMedium.copyWith(
                        color: AppColors.textDisplay,
                      ),
                    ),
                    onTap: () => Navigator.pop(ctx),
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _historyDayCard(
    BuildContext context,
    String dateKey,
    List<Map<String, dynamic>> entries,
  ) {
    // format dateKey to readable (e.g., 2025-12-03 -> 03/12/2025)
    final parts = dateKey.split("-");
    String dateLabel = dateKey;
    if (parts.length == 3) {
      dateLabel = "${parts[2]}/${parts[1]}/${parts[0]}";
    }

    return Card(
      elevation: 0,
      color: AppColors.background_neutral_25,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: dateLabel,
              textStyle: context.typography.mdBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
            SizedBox(height: 8.h),
            Column(
              children: entries.map((e) {
                final taken = e["taken"] as bool;
                final time = e["time"] ?? "";
                final takenAt = e["takenAt"];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: taken
                          ? AppColors.successBackground
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: taken
                            ? AppColors.successForeground
                            : AppColors.borderNeutralPrimary,
                      ),
                    ),
                    child: Icon(
                      taken ? Icons.check_circle : Icons.remove_circle_outline,
                      color: taken
                          ? AppColors.successForeground
                          : AppColors.grayMedium,
                      size: 22.w,
                    ),
                  ),
                  title: AppText(
                    text: "الجرعة — $time",
                    textStyle: context.typography.mdBold.copyWith(
                      color: AppColors.textDisplay,
                    ),
                  ),
                  subtitle: AppText(
                    text: taken ? "أُخذت في ${takenAt ?? time}" : "لم تُؤخذ",
                    textStyle: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===================================================================
/// MedicineCardModern — card component (DS)
/// ===================================================================
class MedicineCardModern extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final VoidCallback onOpenDoses;
  final VoidCallback onQuickTake;
  final void Function(int doseIndex) onToggleDose;
  final VoidCallback? onOpenHistory;

  const MedicineCardModern({
    super.key,
    required this.medicine,
    required this.onOpenDoses,
    required this.onQuickTake,
    required this.onToggleDose,
    this.onOpenHistory,
  });

  int get totalDoses => (medicine["totalDoses"] as num).toInt();

  int get takenBefore => (medicine["takenBefore"] as num).toInt();

  List<String> get scheduleTimes =>
      List<String>.from(medicine["scheduleTimes"] as List<dynamic>);

  List<dynamic> get todayTaken => List<dynamic>.from(medicine["todayTaken"]);

  int get todayTakenCount => todayTaken.where((t) => t == true).length;

  int get totalTaken => takenBefore + todayTakenCount;

  double get progress => (totalTaken / totalDoses).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final name = medicine["name"] as String;
    final nextTime = _nextDoseTime();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------
          // HEADER ROW
          // ---------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication, color: AppColors.primary80),
              ),

              SizedBox(width: 12.w),

              // NAME + NEXT TIME
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: name,
                      textStyle: context.typography.mdBold.copyWith(
                        color: AppColors.textDisplay,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      text: "الجرعة التالية: $nextTime",
                      textStyle: context.typography.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ),
              ),

              // ACTION ICONS
              Row(
                children: [
                  _actionIcon(context, Icons.list_alt, onOpenDoses),
                  SizedBox(width: 6.w),
                  _actionIcon(context, Icons.history, onOpenHistory),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ---------------------------
          // PROGRESS
          // ---------------------------
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7.h,
              backgroundColor: AppColors.grayLight,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 6.h),
          AppText(
            text: "$totalTaken / $totalDoses جرعات مكتملة",
            textStyle: context.typography.xsMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),

          SizedBox(height: 14.h),

          // ---------------------------
          // FOOTER: NOTES + ACTION
          // ---------------------------
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: medicine["notes"] ?? "",
                  textStyle: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              PrimaryTextButton(
                appButtonSize: AppButtonSize.small,
                label: AppText(
                  text: "أخذت الآن",
                  textStyle: context.typography.mdBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
                onTap: onQuickTake,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(BuildContext context, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: AppColors.background_neutral_25,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderNeutralPrimary),
        ),
        child: Icon(icon, size: 20.w, color: AppColors.textDisplay),
      ),
    );
  }

  String _nextDoseTime() {
    final times = scheduleTimes;
    final taken = todayTaken;

    for (int i = 0; i < times.length; i++) {
      if (taken[i] == false) return times[i].toString();
    }
    return "انتهت جرعات اليوم";
  }
}

/// ===================================================================
/// DoseRowDS — design system dose row (used inside sheet)
/// ===================================================================
class DoseRowDS extends StatelessWidget {
  final int index;
  final String time;
  final bool taken;
  final VoidCallback onToggle;

  const DoseRowDS({
    super.key,
    required this.index,
    required this.time,
    required this.taken,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: taken ? AppColors.successBackground : AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: taken
                      ? AppColors.successForeground
                      : AppColors.borderNeutralPrimary,
                  width: 1.2,
                ),
              ),
              child: Icon(
                taken ? Icons.check : Icons.check_box_outline_blank,
                color: taken
                    ? AppColors.successForeground
                    : AppColors.grayMedium,
                size: 20.w,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: "الجرعة ${index + 1}",
                  textStyle: context.typography.mdBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
                SizedBox(height: 4.h),
                AppText(
                  text: "الوقت: $time",
                  textStyle: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          Icon(Icons.more_horiz, color: AppColors.grayMedium),
        ],
      ),
    );
  }
}

/// ===================================================================
/// Small helper SnackBar wrapper using your DS
/// ===================================================================
class AppSnackBar {
  static SnackBar info(String text) {
    return SnackBar(
      backgroundColor: AppColors.background_primary_default,
      content: AppText(
        text: text,
        textStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}

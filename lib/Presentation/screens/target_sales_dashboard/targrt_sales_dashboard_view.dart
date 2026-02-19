import 'package:diwanclinic/index/index_main.dart';
import 'package:flutter/material.dart';

class TargetDashboardScreen extends StatefulWidget {
  const TargetDashboardScreen({super.key});

  @override
  State<TargetDashboardScreen> createState() => _TargetDashboardScreenState();
}

class _TargetDashboardScreenState extends State<TargetDashboardScreen>
    with SingleTickerProviderStateMixin {
  final int monthlyTarget = 52;
  int currentDeals = 2;
  final double commissionPerDeal = 12.5;

  late AnimationController _controller;
  late Animation<double> _animation;

  List<Map<String, dynamic>> deals = [
    {
      "name": "Dr. Ahmed Hassan",
      "specialty": "Dentist",
      "date": "Today",
      "amount": 250,
    },
    {
      "name": "Dr. Sara Ali",
      "specialty": "Dermatology",
      "date": "Today",
      "amount": 300,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = Tween<double>(
      begin: 0,
      end: currentDeals / monthlyTarget,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  void addDeal() {
    setState(() {
      currentDeals++;
      deals.insert(0, {
        "name": "Dr. New Client",
        "specialty": "Pediatrics",
        "date": "Now",
        "amount": 250,
      });

      _animation = Tween<double>(
        begin: _animation.value,
        end: currentDeals / monthlyTarget,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalCommission = currentDeals * commissionPerDeal;
    double percent = (currentDeals / monthlyTarget);

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5B8DEF),
        onPressed: addDeal,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Monthly Target",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [Color(0xff4A7BFF), Color(0xff6F9BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff4A7BFF).withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      width: ScreenUtil().screenWidth,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: currentDeals / monthlyTarget,
                        ),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              /// Subtle background circle
                              Container(
                                height: 160,
                                width: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),

                              /// Clean Progress Ring
                              SizedBox(
                                height: 160,
                                width: 160,
                                child: CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.15,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),

                              /// Center Content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "$currentDeals",
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "of $monthlyTarget",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Completion %
                    Text(
                      "${(percent * 100).toStringAsFixed(0)}% Completed",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${monthlyTarget - currentDeals > 0 ? "${monthlyTarget - currentDeals} Remaining" : "Target Achieved 🎉"}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 💰 COMMISSION CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff5B8DEF), Color(0xff7EA9FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Commission",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      "${totalCommission.toStringAsFixed(0)} EGP",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📋 DEALS LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  final deal = deals[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xffE6EEFF),
                          child: Text(
                            deal["name"][3],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff5B8DEF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deal["name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                deal["specialty"],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${deal["amount"]} EGP",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              deal["date"],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;

  _CirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xffFFFFFF), Color(0xffE0E7FF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    /// Background Circle
    canvas.drawCircle(center, radius, backgroundPaint);

    /// Progress Arc
    final sweepAngle = 2 * 3.1416 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1416 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

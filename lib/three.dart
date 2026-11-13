import 'package:flutter/material.dart';
import 'health_tips.dart';
import 'history_page.dart';

class ResultPage extends StatelessWidget {
  final double bmi;
  final String result;
  final String gender;
  final String ageGroup;
  final double height;
  final double weight;
  final String datetime;

  const ResultPage({
    super.key,
    required this.bmi,
    required this.result,
    required this.gender,
    required this.ageGroup,
    required this.height,
    required this.weight,
    required this.datetime,
  });

  Color get resultColor => HealthTips.color(result);

  int get ageValue => int.tryParse(ageGroup) ?? 0;

  // ---------- Ideal weight range ----------
  double get minHealthyWeight {
    final h = height / 100;
    return 18.5 * h * h;
  }

  double get maxHealthyWeight {
    final h = height / 100;
    return 24.9 * h * h;
  }

  String get weightAdvice {
    if (result == "Normal Weight") {
      return "Your weight is within the healthy range. Great job!";
    } else if (result == "Underweight") {
      final diff = minHealthyWeight - weight;
      return "You are ${diff.toStringAsFixed(1)} kg below the healthy range.";
    } else {
      final diff = weight - maxHealthyWeight;
      return "You are ${diff.toStringAsFixed(1)} kg above the healthy range.";
    }
  }

  // ---------- Under 18 note ----------
  Widget _ageNote() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "BMI categories are designed for adults (18+). For children and teenagers, BMI is compared with age and gender percentiles, so please consult a doctor for a proper result.",
              style: TextStyle(fontSize: 12.5, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- BMI scale bar ----------
  Widget _bmiScale() {
    const double minBmi = 10;
    const double maxBmi = 40;
    final double position =
        (bmi.clamp(minBmi, maxBmi).toDouble() - minBmi) / (maxBmi - minBmi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "BMI Scale",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final markerLeft = (position * width - 12)
                .clamp(0.0, width - 24)
                .toDouble();

            return SizedBox(
              height: 38,
              child: Stack(
                children: [
                  Positioned(
                    left: markerLeft,
                    top: 0,
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 24,
                      color: resultColor,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 24,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 85,
                            child: SizedBox(
                              height: 12,
                              child: ColoredBox(color: Colors.blue),
                            ),
                          ),
                          Expanded(
                            flex: 65,
                            child: SizedBox(
                              height: 12,
                              child: ColoredBox(color: Colors.green),
                            ),
                          ),
                          Expanded(
                            flex: 50,
                            child: SizedBox(
                              height: 12,
                              child: ColoredBox(color: Colors.orange),
                            ),
                          ),
                          Expanded(
                            flex: 100,
                            child: SizedBox(
                              height: 12,
                              child: ColoredBox(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        const Row(
          children: [
            Expanded(
              flex: 85,
              child: Center(
                child: Text("Under", style: TextStyle(fontSize: 10)),
              ),
            ),
            Expanded(
              flex: 65,
              child: Center(
                child: Text("Normal", style: TextStyle(fontSize: 10)),
              ),
            ),
            Expanded(
              flex: 50,
              child: Center(
                child: Text("Over", style: TextStyle(fontSize: 10)),
              ),
            ),
            Expanded(
              flex: 100,
              child: Center(
                child: Text("Obese", style: TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Ideal weight box ----------
  Widget _idealWeightBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.track_changes, color: Colors.pinkAccent, size: 20),
              SizedBox(width: 8),
              Text(
                "Healthy Weight Range",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${minHealthyWeight.toStringAsFixed(1)} kg - ${maxHealthyWeight.toStringAsFixed(1)} kg",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "For your height of ${height.toStringAsFixed(1)} cm (BMI 18.5 - 24.9)",
            style: const TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            weightAdvice,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: resultColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Result"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 10,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    // ignore: deprecated_member_use
                    backgroundColor: resultColor.withOpacity(0.15),
                    child: Icon(
                      gender == "Male" ? Icons.man : Icons.woman,
                      size: 60,
                      color: resultColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "BMI: ${bmi.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: resultColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: resultColor),
                    ),
                    child: Text(
                      result,
                      style: TextStyle(
                        fontSize: 22,
                        color: resultColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (ageValue < 18) _ageNote(),

                  const SizedBox(height: 20),

                  _bmiScale(),

                  const SizedBox(height: 16),

                  _idealWeightBox(),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  _detailRow(Icons.person, "Gender", gender),
                  const SizedBox(height: 10),
                  _detailRow(Icons.calendar_view_day_rounded, "Age", ageGroup),
                  const SizedBox(height: 10),
                  _detailRow(
                    Icons.height,
                    "Height",
                    "${height.toStringAsFixed(1)} cm",
                  ),
                  const SizedBox(height: 10),
                  _detailRow(
                    Icons.monitor_weight,
                    "Weight",
                    "${weight.toStringAsFixed(1)} kg",
                  ),
                  const SizedBox(height: 10),
                  _detailRow(Icons.access_time, "Date & Time", datetime),

                  const SizedBox(height: 24),

                  HealthTipsCard(result: result),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text("View History"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.pinkAccent),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

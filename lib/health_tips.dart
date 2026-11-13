import 'package:flutter/material.dart';

class HealthTips {
  static Color color(String result) {
    switch (result) {
      case "Underweight":
        return Colors.blue;
      case "Normal Weight":
        return Colors.green;
      case "Overweight":
        return Colors.orange;
      case "Obese":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String heading(String result) {
    switch (result) {
      case "Underweight":
        return "Tips to Gain Weight Healthily";
      case "Normal Weight":
        return "Tips to Maintain Your Healthy Weight";
      case "Overweight":
        return "Tips to Reduce Weight";
      case "Obese":
        return "Tips to Manage and Control Weight";
      default:
        return "Health Tips";
    }
  }

  static List<String> tips(String result) {
    switch (result) {
      case "Underweight":
        return [
          "Eat 5-6 small meals every day and avoid skipping meals.",
          "Include protein-rich foods such as eggs, paneer, dal, nuts and milk.",
          "Add healthy high-calorie foods like bananas, peanut butter and dry fruits.",
          "Do light strength training to build muscle.",
          "Get enough sleep (7-8 hours) and keep stress levels low.",
        ];
      case "Normal Weight":
        return [
          "Continue your balanced diet with vegetables, fruits and whole grains.",
          "Do at least 150 minutes of moderate exercise (walking, cycling) every week.",
          "Drink 2.5-3 litres of water every day.",
          "Avoid junk food, sugary drinks and overeating.",
          "Check your BMI once a month to keep track.",
        ];
      case "Overweight":
        return [
          "Do 30-45 minutes of walking, jogging or cycling daily.",
          "Reduce fried foods, sweets and cold drinks.",
          "Eat more fiber-rich foods such as vegetables, fruits and millets.",
          "Control your portion sizes and eat slowly.",
          "Avoid eating late at night and get proper sleep.",
        ];
      case "Obese":
        return [
          "Consult a doctor or a dietitian to get a proper plan.",
          "Start with light walking and increase the duration slowly.",
          "Cut down heavily on oil, sugar, maida and processed foods.",
          "Give priority to vegetables, fruits and protein foods every day.",
          "Get regular check-ups for blood pressure, sugar and cholesterol.",
        ];
      default:
        return [];
    }
  }
}

/// Reusable tips card (used in ResultPage and History page)
class HealthTipsCard extends StatelessWidget {
  final String result;

  const HealthTipsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = HealthTips.color(result);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  HealthTips.heading(result),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...HealthTips.tips(result).map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 14, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Note: These are general health tips only. Please consult a doctor for personal medical advice.",
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

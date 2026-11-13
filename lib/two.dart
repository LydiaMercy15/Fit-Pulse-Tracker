import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'three.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? selectedGender;

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> calculateBMI() async {
    if (selectedGender == null) {
      _showMessage("Please select Gender");
      return;
    }

    int age = int.tryParse(ageController.text.trim()) ?? 0;
    double height = double.tryParse(heightController.text.trim()) ?? 0;
    double weight = double.tryParse(weightController.text.trim()) ?? 0;

    // ---------- Range validation ----------
    if (age < 1 || age > 120) {
      _showMessage("Please enter a valid Age (1 - 120)");
      return;
    }

    if (height < 50 || height > 250) {
      _showMessage("Height must be between 50 and 250 cm");
      return;
    }

    if (weight < 10 || weight > 300) {
      _showMessage("Weight must be between 10 and 300 kg");
      return;
    }

    double bmi = weight / ((height / 100) * (height / 100));

    String result;
    if (bmi < 18.5) {
      result = "Underweight";
    } else if (bmi < 25) {
      result = "Normal Weight";
    } else if (bmi < 30) {
      result = "Overweight";
    } else {
      result = "Obese";
    }

    final now = DateTime.now();
    final datetime =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final box = Hive.box('bmi_history');

    await box.add({
      'bmi': bmi,
      'result': result,
      'gender': selectedGender!,
      'age_group': age.toString(),
      'height': height,
      'weight': weight,
      'datetime': datetime,
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          bmi: bmi,
          result: result,
          gender: selectedGender!,
          ageGroup: age.toString(),
          height: height,
          weight: weight,
          datetime: datetime,
        ),
      ),
    );
  }

  void clearData() {
    heightController.clear();
    weightController.clear();
    ageController.clear();
    setState(() {
      selectedGender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (value) {
                  setState(() => selectedGender = value);
                },
              ),

              const SizedBox(height: 20),

              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: const InputDecoration(
                  labelText: "Age (1 - 120)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: heightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,3}\.?\d{0,1}'),
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: "Height (cm) (50 - 250)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,3}\.?\d{0,1}'),
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: "Weight (kg) (10 - 300)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await calculateBMI();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Calculate BMI",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: clearData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Clear", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

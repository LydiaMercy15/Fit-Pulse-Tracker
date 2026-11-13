import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'health_tips.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _clearAllHistory(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History"),
        content: const Text(
          "All BMI history records will be deleted. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Hive.box('bmi_history').clear();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("History cleared!")));
    }
  }

  IconData _getGenderIcon(String? gender) {
    if (gender == "Male") return Icons.male;
    if (gender == "Female") return Icons.female;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('bmi_history');

    return ValueListenableBuilder<Box>(
      valueListenable: box.listenable(),
      builder: (context, Box b, _) {
        // oldest -> newest, with Hive key (chart ku + delete ku)
        final entries = b.keys
            .map(
              (k) => MapEntry<dynamic, Map<String, dynamic>>(
                k,
                Map<String, dynamic>.from(b.get(k) as Map),
              ),
            )
            .toList();

        // newest -> oldest (list ku)
        final newestFirst = entries.reversed.toList();

        // chart ku only data maps
        final dataOnly = entries.map((e) => e.value).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text("BMI History (${entries.length} records)"),
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            actions: [
              if (entries.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: "Clear All",
                  onPressed: () => _clearAllHistory(context),
                ),
            ],
          ),
          body: entries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No Records Found",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _TrendCard(entries: dataOnly),
                    const SizedBox(height: 16),
                    const Text(
                      "Past Records",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Tap a record to see health tips  •  Swipe left to delete",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    ...newestFirst.map(
                      (e) => _dismissibleRecord(context, e.key, e.value),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ---------- Swipe to delete wrapper ----------
  Widget _dismissibleRecord(
    BuildContext context,
    dynamic hiveKey,
    Map<String, dynamic> item,
  ) {
    return Dismissible(
      key: ValueKey(hiveKey),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      onDismissed: (_) {
        final messenger = ScaffoldMessenger.of(context);
        final backup = Map<String, dynamic>.from(item);
        final box = Hive.box('bmi_history');

        box.delete(hiveKey);

        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text("Record deleted"),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: "UNDO",
                onPressed: () {
                  // same key la thirumba save pannina, same position la varum
                  box.put(hiveKey, backup);
                },
              ),
            ),
          );
      },
      child: _recordCard(context, item),
    );
  }

  // ---------- One record card ----------
  Widget _recordCard(BuildContext context, Map<String, dynamic> item) {
    final String result = (item['result'] ?? '').toString();
    final resultColor = HealthTips.color(result);
    final genderIcon = _getGenderIcon(item['gender']?.toString());

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // ignore: deprecated_member_use
          color: resultColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(context, item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(genderIcon, color: Colors.pinkAccent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "BMI: ${double.tryParse(item['bmi'].toString())?.toStringAsFixed(2) ?? item['bmi']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: resultColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: resultColor),
                    ),
                    child: Text(
                      result,
                      style: TextStyle(
                        color: resultColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _infoTile(
                      Icons.person,
                      "Gender",
                      (item['gender'] ?? '-').toString(),
                    ),
                  ),
                  Expanded(
                    child: _infoTile(
                      Icons.calendar_view_day_rounded,
                      "Age",
                      (item['age_group'] ?? '-').toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _infoTile(
                      Icons.height,
                      "Height",
                      "${double.tryParse(item['height'].toString())?.toStringAsFixed(1) ?? item['height']} cm",
                    ),
                  ),
                  Expanded(
                    child: _infoTile(
                      Icons.monitor_weight,
                      "Weight",
                      "${double.tryParse(item['weight'].toString())?.toStringAsFixed(1) ?? item['weight']} kg",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (item['datetime'] ?? '').toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: resultColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Tips",
                        style: TextStyle(
                          fontSize: 12,
                          color: resultColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Bottom sheet with details + tips ----------
  void _showDetails(BuildContext context, Map<String, dynamic> item) {
    final double bmi = double.tryParse(item['bmi'].toString()) ?? 0;
    final String result = (item['result'] ?? '').toString();
    final color = HealthTips.color(result);
    final double height = double.tryParse(item['height'].toString()) ?? 0;
    final double weight = double.tryParse(item['weight'].toString()) ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "BMI: ${bmi.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        result,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sheetRow("Gender", (item['gender'] ?? '-').toString()),
                  _sheetRow("Age", (item['age_group'] ?? '-').toString()),
                  _sheetRow("Height", "${height.toStringAsFixed(1)} cm"),
                  _sheetRow("Weight", "${weight.toStringAsFixed(1)} kg"),
                  _sheetRow("Date & Time", (item['datetime'] ?? '').toString()),
                  const SizedBox(height: 20),
                  HealthTipsCard(result: result),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.pinkAccent),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

// ======================= TREND CHART =======================

class _TrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> entries;

  const _TrendCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    // last 10 records only (oldest -> newest)
    final recent = entries.length > 10
        ? entries.sublist(entries.length - 10)
        : entries;
    final values = recent
        .map((e) => double.tryParse(e['bmi'].toString()) ?? 0)
        .toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: Colors.pinkAccent),
                SizedBox(width: 8),
                Text(
                  "BMI Progress",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Last ${values.length} record${values.length == 1 ? '' : 's'}",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(painter: _TrendPainter(values)),
            ),
            if (values.length < 2)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Add more records to see your progress line.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;

  _TrendPainter(this.values);

  static const double minY = 10;
  static const double maxY = 40;

  Color _colorForBmi(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _drawLabel(Canvas canvas, String text, double centerY) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(0, centerY - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 32;
    const double rightPad = 8;
    const double topPad = 8;
    const double bottomPad = 8;

    final double chartW = size.width - leftPad - rightPad;
    final double chartH = size.height - topPad - bottomPad;

    double yFor(double v) {
      final clamped = v.clamp(minY, maxY).toDouble();
      return topPad + chartH * (1 - (clamped - minY) / (maxY - minY));
    }

    // reference lines (18.5, 25, 30)
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (final ref in [18.5, 25.0, 30.0]) {
      final y = yFor(ref);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        linePaint,
      );
      _drawLabel(canvas, ref.toString(), y);
    }

    if (values.isEmpty) return;

    // points
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? leftPad + chartW / 2
          : leftPad + chartW * i / (values.length - 1);
      points.add(Offset(x, yFor(values[i])));
    }

    // line
    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      final pathPaint = Paint()
        ..color = Colors.pinkAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, pathPaint);
    }

    // dots (category color)
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 6, Paint()..color = Colors.white);
      canvas.drawCircle(
        points[i],
        4.5,
        Paint()..color = _colorForBmi(values[i]),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) => true;
}

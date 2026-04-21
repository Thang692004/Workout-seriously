import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_scaffold.dart';
import '../models/data_exercises.dart';
import '../controller/data_exercise_controller.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final String uid;

  const HomeScreen({super.key, required this.uid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataExerciseController _controller = DataExerciseController();
  List<DataExercises> workouts = [];
  List<String> exerciseNames = [];
  String selected = 'Tất cả';
  final List<Color> _lineColors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.getAllExercise(widget.uid);
    if (!mounted) return;
    setState(() {
      workouts = _controller.exercises;
      exerciseNames = _controller.exerciseNames;
      _generateColors();
      isLoading = false;
    });
  }
  // Chọn màu cho lines
  void _generateColors() {
    final rand = Random();
    _lineColors.clear();
    for (int i = 0; i < exerciseNames.length; i++) {
      _lineColors.add(Color.fromARGB(
        255,
        rand.nextInt(156) + 100,
        rand.nextInt(156) + 100,
        rand.nextInt(156) + 100,
      ));
    }
  }

  double _getMaxY() {
    double max = 0;
    for (final name in exerciseNames) {
      for (final spot in _getSpots(name)) {
        if (spot.y > max) max = spot.y;
      }
    }
    return max;
  }

  // Tạo list FlSpot cho từng môn tập
  List<FlSpot> _getSpots(String exerciseName) {
    if (workouts.isEmpty) return []; // ← Thêm dòng này
    return workouts.asMap().entries.map((e) {
      final value = e.value.exercises?[exerciseName]?.toDouble() ?? 0;
      return FlSpot(e.key.toDouble(), value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Báo cáo",
      child: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : workouts.isEmpty
          ? Center(
        child: Text( "Chưa có dữ liệu", style: TextStyle(color: Colors.white70),),)
          :  Column(
          children:[
            // Lựa chọn bảng dữ liệu
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButton<String>(
                  value: selected,
                  dropdownColor: Color(0xFF1E1E2E),
                  style: TextStyle(color: Colors.white),
                  underline: SizedBox(), // ← Bỏ gạch chân
                  borderRadius: BorderRadius.circular(12),
                  menuMaxHeight: 300,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  items: ['Tất cả', ...exerciseNames].map((name) => DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  )).toList(),
                  onChanged: (val) => setState(() => selected = val!),
                ),
              ),
            ),


            // Đồ thị
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (selected == 'Tất cả')
                      _buildAllChartCard()
                    else
                      _buildChartCard(selected),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ]

        ),
    );
  }

  Widget _buildChartCard(String exerciseName) {
    final spots = _getSpots(exerciseName);

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1E2E), // ← Nền tối đặc, không trong suốt
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exerciseName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.white12, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= workouts.length) return SizedBox();
                        final d = workouts[idx].day;
                        return Text(
                          '${d.day}/${d.month}',
                          style: TextStyle(color: Colors.white54, fontSize: 9),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.greenAccent,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 3,
                        color: Colors.greenAccent,
                        strokeColor: Colors.white,
                        strokeWidth: 1,
                      ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget riêng cho "Tất cả" - nhiều đường, label ở chấm cuối
  Widget _buildAllChartCard() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double chartWidth = max(screenWidth, workouts.length * 60.0); // ← Rộng theo số ngày

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tất cả',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // ← Bọc bằng SingleChildScrollView để vuốt ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: 300,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: _getMaxY() + 10,
                  clipData: FlClipData.none(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: Colors.white12, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (_, __) => SizedBox(),
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= workouts.length) return SizedBox();
                          final d = workouts[idx].day;
                          return Text(
                            '${d.day}/${d.month}',
                            style: TextStyle(color: Colors.white54, fontSize: 9),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: exerciseNames.asMap().entries.map((e) {
                    final color = _lineColors[e.key];
                    final spots = _getSpots(e.value);
                    return LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, index) {
                          final isLast = index == spots.length - 1;
                          return FlDotCirclePainter(
                            radius: isLast ? 4 : 2,
                            color: color,
                            strokeColor: Colors.white,
                            strokeWidth: isLast ? 1.5 : 0.5,
                          );
                        },
                      ),
                      showingIndicators: spots.isEmpty ? [] : [spots.length - 1],
                    );
                  }).toList(),

                  // ← Hiện tên ở chấm cuối, ẩn đường thẳng
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            exerciseNames[spot.barIndex],
                            TextStyle(
                              color: _lineColors[spot.barIndex],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((_) => TouchedSpotIndicatorData(
                        FlLine(color: Colors.transparent), // ← Ẩn đường thẳng
                        FlDotData(show: false),
                      )).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          // ── LEGEND ──
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: exerciseNames.asMap().entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _lineColors[e.key],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    e.value,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
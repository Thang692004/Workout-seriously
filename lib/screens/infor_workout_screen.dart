import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../models/data_exercises.dart';
import '../services/data_exercises_service.dart';
import '../controller/data_exercise_controller.dart';

class InforWorkoutScreen extends StatefulWidget {
  final String uid;

  const InforWorkoutScreen({super.key, required this.uid});

  @override
  State<InforWorkoutScreen> createState() => _InforWorkoutScreenState();
}

class _InforWorkoutScreenState extends State<InforWorkoutScreen> {
  DataExercises? workout;
  bool isLoading = true;
  final DataExerciseController _controller = DataExerciseController();
  List<DataExercises> workouts = [];
  List<String> exerciseNames = [];

  // Giá trị để sửa dữ liệu
  String? selectedExercise;
  DataExercises? selectedWorkout;

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
      isLoading = false;
      selectedWorkout = null;
    });
  }

  void _onRowTap(DataExercises tappedWorkout) {
    setState(() {
      if (selectedWorkout == tappedWorkout) {
        selectedWorkout = null;
      } else
        selectedWorkout = tappedWorkout;
    });
  }

  Future<void> _showAddDialog() async {
    // Dùng ValueNotifier để reload dialog khi thêm môn tập mới
    final exerciseNamesNotifier = ValueNotifier<List<String>>(
      List.from(exerciseNames),
    );

    await showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<List<String>>(
        valueListenable: exerciseNamesNotifier,
        builder: (context, currentNames, _) {
          final Map<String, TextEditingController> controllers = {
            for (var name in currentNames) name: TextEditingController(),
          };

          return AlertDialog(
            title: Text('Thêm dữ liệu buổi tập'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...currentNames.map((name) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextField(
                        controller: controllers[name],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: name,
                          border: OutlineInputBorder(),
                          suffixText: 'reps',
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Thêm môn tập'),
                    onPressed: () async {
                      final newNames = await _showAddExerciseSubDialog(context);
                      if (newNames != null && newNames.isNotEmpty) {
                        // Lưu môn tập mới vào Firestore
                        for (final name in newNames) {
                          await DataExercisesService().addExercise(
                            widget.uid,
                            name,
                          );
                        }
                        // Cập nhật lại danh sách để rebuild dialog
                        exerciseNamesNotifier.value = [
                          ...currentNames,
                          ...newNames,
                        ];
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final Map<String, num> newExercises = {
                    for (var name in currentNames)
                      name: num.tryParse(controllers[name]!.text) ?? 0,
                  };
                  await DataExercisesService().addDataExercises(
                    widget.uid,
                    newExercises,
                  );
                  Navigator.pop(context);
                  await _loadData();
                },
                child: Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Sub-dialog: nhập số lượng → sinh ra bấy nhiêu ô tên → trả về danh sách tên
  Future<List<String>?> _showAddExerciseSubDialog(
    BuildContext parentContext,
  ) async {
    final countController = TextEditingController();
    List<TextEditingController> nameControllers = [];

    return showDialog<List<String>>(
      context: parentContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Thêm môn tập mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ô nhập số lượng
                  TextField(
                    controller: countController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số lượng môn tập muốn thêm',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          final count = int.tryParse(countController.text) ?? 0;
                          setState(() {
                            nameControllers = List.generate(
                              count,
                              (_) => TextEditingController(),
                            );
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) {
                      final count = int.tryParse(countController.text) ?? 0;
                      setState(() {
                        nameControllers = List.generate(
                          count,
                          (_) => TextEditingController(),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Sinh ra bấy nhiêu ô tên môn tập
                  ...nameControllers.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: 'Tên môn tập ${entry.key + 1}',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  final names = nameControllers
                      .map((c) => c.text.trim())
                      .where((name) => name.isNotEmpty)
                      .toList();
                  Navigator.pop(context, names);
                },
                child: Text('Thêm'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Sửa thông tin buổi tập
  Future<void> _showEditDialog(DataExercises workoutToEdit) async {
    final Map<String, TextEditingController> controllers = {
      for (var name in exerciseNames)
        name: TextEditingController(
          text: workoutToEdit.exercises?[name]?.toString() ?? '0',
        ),
    };

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chỉnh sửa buổi tập'),
            const SizedBox(height: 4),
            // Hiển thị ngày của buổi tập đang sửa (chỉ đọc, không cho sửa)
            Text(
              'Ngày: ${workoutToEdit.day.day}/${workoutToEdit.day.month}/${workoutToEdit.day.year}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sinh ra 1 ô nhập liệu cho mỗi môn tập
              ...exerciseNames.map((name) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: controllers[name],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: name,
                      border: OutlineInputBorder(),
                      suffixText: 'reps',
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          // Nút Hủy → đóng dialog, không lưu gì
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),

          // Nút Lưu → gọi service cập nhật Firestore, rồi reload
          ElevatedButton(
            onPressed: () async {
              // Thu thập dữ liệu mới từ các ô nhập liệu
              final Map<String, num> updatedExercises = {
                for (var name in exerciseNames)
                  name: num.tryParse(controllers[name]!.text) ?? 0,
              };

              await DataExercisesService().fixDataExercises(
                widget.uid,
                workoutToEdit.id,
                updatedExercises,
              );
              Navigator.pop(context);

              // Reload lại dữ liệu và tự động bỏ chọn dòng
              await _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0C447C),
              foregroundColor: Colors.white,
            ),
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Dữ liệu buổi tập",
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildTable(),
    );
  }

  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                // 👈 thêm scroll dọc
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: {
                    0: FixedColumnWidth(50), // STT
                    1: FixedColumnWidth(100), // Ngày
                    // môn tập từ index 2 trở đi
                    for (int i = 0; i < exerciseNames.length; i++)
                      i + 2: FixedColumnWidth(75),
                  },
                  children: [
                    _headerRow(exerciseNames),

                    if (workouts.isEmpty)
                      TableRow(
                        children: [
                          cell('-', false, Colors.black),
                          cell('-', false, Colors.black),
                          for (int i = 0; i < exerciseNames.length; i++)
                            cell('-', false, Colors.black),
                        ],
                      )
                    else
                      for (int i = 0; i < workouts.length; i++)
                        _dataRow(
                          workouts[i],
                          i + 1,
                          exerciseNames,
                          isSelected: selectedWorkout == workouts[i],
                          onTap: () => _onRowTap(workouts[i]),
                        ),
                  ],
                ),
              ),
            ),
          ),

          // Thêm dữ liệu
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2, // nhỏ hơn
                  child: ElevatedButton.icon(
                    onPressed: selectedWorkout == null
                        ? null
                        : () async {
                      await DataExercisesService().deleteDataExercises(
                        widget.uid,
                        selectedWorkout!.id,
                      );
                      await _loadData();
                    },
                    icon: Icon(Icons.delete_outline, size: 18),
                    label: Text("Xoá"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 45),
                      backgroundColor: Color(0xFFE53935),
                      foregroundColor: Color(0xFFFFFFFF),
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // width thay vì height trong Row

                Expanded(
                  flex: 2, // nhỏ hơn
                  child: ElevatedButton.icon(
                    onPressed: selectedWorkout == null
                        ? null
                        : () => _showEditDialog(selectedWorkout!),
                    icon: Icon(Icons.edit_outlined, size: 18),
                    label: Text("Sửa"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 45),
                      backgroundColor: Color(0xFFFFE082),
                      foregroundColor: Color(0xFF0C447C),
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  flex: 3, // to nhất
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddDialog(),
                    icon: Icon(Icons.add, size: 20),
                    label: Text("Thêm buổi tập"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Color(0xFF0C447C),
                      foregroundColor: Color(0xFFE6F1FB),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget cell(String text, bool bold, Color color) {
  return Padding(
    padding: EdgeInsets.all(10),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
}

TableRow _headerRow(List<String> exercises) {
  return TableRow(
    decoration: BoxDecoration(color: Color(0xFF0C447C)), // header xanh đậm
    children: [
      cell("STT", true, Color(0xFFE6F1FB)),
      cell("Ngày", true, Color(0xFFE6F1FB)),
      ...exercises.map((name) => cell(name, true, Color(0xFFE6F1FB))),
    ],
  );
}

TableRow _dataRow(
  DataExercises workouts,
  int stt,
  List<String> exercises, {
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final rowColor = isSelected ? Color(0xFFFFF9C4) : Colors.white;

  return TableRow(
    decoration: BoxDecoration(color: rowColor),
    children: [
      GestureDetector(
        onTap: onTap, // ← nhận tap ở đây
        child: cell(stt.toString(), false, Color(0xFF378ADD)),
      ),

      GestureDetector(
        onTap: onTap,
        child: cell(
          '${workouts.day.day}/${workouts.day.month}/${workouts.day.year}',
          false,
          Color(0xFF185FA5), // Ngày xanh nhạt hơn
        ),
      ),
      for (String name in exercises)
        GestureDetector(
          onTap: onTap,
          child: cell(
            workouts.exercises?[name]?.toString() ?? '0',
            false,
            Color(0xFF185FA5),
          ),
        ),
    ],
  );
}

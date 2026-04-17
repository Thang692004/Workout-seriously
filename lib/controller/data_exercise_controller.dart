import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/data_exercises_service.dart';
import '../models/data_exercises.dart';
import '../services/auth_service.dart';

class DataExerciseController {
  final uid = AuthService().uid;
  List<DataExercises> exercises = [];
  List<String> exerciseNames = [];

  Future<void> getAllExercise(String uid) async {
    // Lấy lịch sử buổi tập từ subcollection
    exercises = await DataExercisesService().getAllExercises(uid);

    // Lấy danh sách môn tập từ workouts/{uid} — nguồn chuẩn
    exerciseNames = await DataExercisesService().getExerciseNames(uid);

    // Nếu chưa có môn nào → dùng mặc định
    if (exerciseNames.isEmpty) {
      exerciseNames = ['Flank', 'Pull up', 'Push up', 'Squat'];
    }
  }
}
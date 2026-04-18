import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/data_exercises.dart';

class DataExercisesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _historyRef(String uid) =>  _db.collection('workouts').doc(uid).collection('history');

  // ĐỌC tất cả buổi tập
  Future<List<DataExercises>> getAllExercises(String uid) async {
    final snapshot = await _historyRef(uid).orderBy('day').get();
    return snapshot.docs.map((doc) {
      return DataExercises.fromMap( uid, doc.id ,doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // LẤY danh sách tên môn tập — gộp từ tất cả history
  Future<List<String>> getExerciseNames(String uid) async {
    final snapshot = await _historyRef(uid).get();
    Set<String> names = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('exercises')) {
        names.addAll(Map<String, dynamic>.from(data['exercises']).keys);
      }
    }
    if (names.isEmpty) {
      return ['Flank', 'Pull up', 'Push up', 'Squat']; // mặc định
    }
    return names.toList();
  }

  // THÊM buổi tập mới vào history
  Future<void> addDataExercises(String uid, Map<String, num> exercises) async {
    final docRef = _historyRef(uid).doc(); // Firestore tạo id random tại đây

    final exercise = DataExercises(
      uid: uid,
      id: docRef.id,
      day: DateTime.now(),
      exercises: exercises,
    );

    await docRef.set(exercise.toMap());
  }

  // THÊM môn tập mới → cập nhật vào TẤT CẢ document trong history
  Future<void> addExercise(String uid, String exerciseName) async {
    final snapshot = await _historyRef(uid).get();

    if (snapshot.docs.isEmpty) {
      // Chưa có buổi tập nào → tạo buổi đầu tiên với môn mới
      await _historyRef(uid).add({
        'day': Timestamp.now(),
        'exercises': {exerciseName: 0},
      });
      return;
    }

    // Kiểm tra môn đã tồn tại chưa
    final firstData = snapshot.docs.first.data() as Map<String, dynamic>;
    final existing = Map<String, dynamic>.from(firstData['exercises'] ?? {});
    if (existing.containsKey(exerciseName)) {
      throw Exception('Môn tập "$exerciseName" đã tồn tại!');
    }

    // Thêm vào tất cả document với giá trị 0
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'exercises.$exerciseName': 0,
      });
    }
    await batch.commit();
  }

  // SỬA reps của 1 buổi tập đã lưu
  Future<void> fixDataExercises( String uid, String sessionId, Map<String, num> exercises, ) async {
    await _historyRef(uid).doc(sessionId).update({ 'exercises': exercises, });
  }

  // ĐỔI TÊN môn tập → cập nhật tất cả history
  Future<void> renameExercise(String uid, String oldName, String newName) async {
    final snapshot = await _historyRef(uid).get();
    if (snapshot.docs.isEmpty) return;

    final firstData = snapshot.docs.first.data() as Map<String, dynamic>;
    final existing = Map<String, dynamic>.from(firstData['exercises'] ?? {});

    if (!existing.containsKey(oldName)) {
      throw Exception('Môn tập "$oldName" không tồn tại!');
    }
    if (existing.containsKey(newName)) {
      throw Exception('Môn tập "$newName" đã tồn tại!');
    }

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final exercises = Map<String, dynamic>.from(data['exercises'] ?? {});
      final oldValue = exercises[oldName] ?? 0;
      batch.update(doc.reference, {
        'exercises.$newName': oldValue,
        'exercises.$newName': oldValue,
        'exercises.$oldName': FieldValue.delete(),
      });
    }
    await batch.commit();
  }

  // XÓA môn tập → xóa khỏi tất cả history
  Future<void> deleteExerciseFromAllDocs(String uid, String exerciseName) async {
    final snapshot = await _historyRef(uid).get();
    if (snapshot.docs.isEmpty) return;

    final firstData = snapshot.docs.first.data() as Map<String, dynamic>;
    final existing = Map<String, dynamic>.from(firstData['exercises'] ?? {});

    if (!existing.containsKey(exerciseName)) {
      throw Exception('Môn tập "$exerciseName" không tồn tại!');
    }

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'exercises.$exerciseName': FieldValue.delete(),
      });
    }
    await batch.commit();
  }

  // Xóa dữ liệu tập luyện
  Future<void> deleteDataExercises(String uid, String sessionId) async{
    await _historyRef(uid).doc(sessionId).delete();
  }
}
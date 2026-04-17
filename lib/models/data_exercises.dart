import 'package:cloud_firestore/cloud_firestore.dart';

class DataExercises {
  final String uid;
  final String id;
  final DateTime day;
  final Map<String,num> exercises;

  DataExercises({
    required this.uid,
    required this.id,
    required this.day,
    required this.exercises,
});

  factory DataExercises.fromMap(String uid, String id, Map<String, dynamic> data){
    return DataExercises(
        uid : uid,
        id : id,
        day: (data['day'] as Timestamp).toDate(),
        exercises: Map<String,num>.from(data['exercises'] ?? {}),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'day' : Timestamp.fromDate(day),
      'exercises': exercises,
    };
  }
}
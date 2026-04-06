import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Users.dart';

class UserService {

  // Đọc thông tin từ FireBase
  Future<UserModel?> getUserByUid(String uid) async{
    try{
      final read = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if(read.exists){
        return UserModel.fromMap(uid, read.data()!);
      }
      return null;
    } catch (e) {
      print("Lỗi đọc user: $e");
      return null;
    }
  }
}
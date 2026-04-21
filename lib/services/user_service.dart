import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Users.dart';
import 'auth_service.dart';

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

  // Cập nhật thông tin cá nhân
  Future<UserModel?> updateProfileUser(UserModel updated) async{
    try {
      final id = AuthService().uid;
      if(id == null) return null;

      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'name':    updated.name,
        'phone':   updated.phone,
        'born':    updated.born,
        'gender':  updated.gender,
        'address': updated.address,
        'favoriteExercise': updated.favoriteExercise,
        'bio':     updated.bio,
      });
      return updated;
    }catch (e){
      if (e.toString().contains('network')) {
        throw Exception('Không có kết nối mạng');
      } else if (e.toString().contains('permission')) {
        throw Exception('Không có quyền cập nhật');
      } else {
        throw Exception('Cập nhật thất bại: $e');
      }
    }
  }
}
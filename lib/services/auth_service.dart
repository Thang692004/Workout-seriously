import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Users.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  UserModel? currentUser;

  // Lấy giá trị uid
  String? get uid => auth.currentUser?.uid;
  User? get user => auth.currentUser;

  Future<UserModel?> loadUserProfile() async{
    final firebaseUser = auth.currentUser;
    if(firebaseUser == null) return null;

    final userModel = await UserService().getUserByUid(firebaseUser.uid);
    currentUser = userModel;
    return userModel;
  }

  // Đăng nhập bằng Email + password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Dùng hàm có sẵn luôn!
      return await loadUserProfile();

    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Đăng nhập bằng Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUsers = await GoogleSignIn().signIn();
      if (googleUsers == null) {
        print(">>> User cancelled sign in");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUsers.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await auth.signInWithCredential(credential);
      final firebaseUser = result.user;
      if (firebaseUser == null) return null;

      // Kiểm tra user đã có trong Firestore chưa
      final existing = await UserService().getUserByUid(firebaseUser.uid);
      if (existing == null) {
        // Chưa có → tạo mới
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
          'name': firebaseUser.displayName ?? '',
          'email': firebaseUser.email ?? '',
          'phone': '',
          'born': '',
          'createAt': DateTime.now(),
        });
      }

      return await loadUserProfile();

    } catch (e, stackTrace) {
      print(">>> Google login error TYPE: ${e.runtimeType}");
      print(">>> Google login error: $e");
      return null;
    }
  }

  //Đăng ký bằng tài khoản (email + password)
  Future<User?> registerWithEmail(
  {
    required String email,
    required String password,
    required String name,
    required String phone,
    required String born,
  }) async {
    try {

      //Lưu tài khoản đăng ký vào Auth
      final result = await auth.createUserWithEmailAndPassword(email: email, password: password);

      final user = result.user;
      if(user != null)
        {
          // Lưu  thông tin cá nhân của người dùng vào FireStore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name' : name,
            'phone': phone,
            'born' : born,
            'email': email,
            'createAt': DateTime.now(),

          });
          print("name: $name");
          print("phone: $phone");
          print("born: $born");
          print("email: $email");
        return user;
        }

      return null;
      } on FirebaseAuthException catch (e) {
        throw e;
    }
  }

  // Xóa thông tin khi đăng xuất
  Future<void> signOut() async {
    currentUser = null; // ← xóa
    await auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Lấy ảnh của user
  String? getAvataUrl(){
    final user = auth.currentUser;
    if(user == null) return null;

    for(var info in user.providerData) {
      if (info.providerId == 'google.com') return info.photoURL;
    }

    return null;
  }
}
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //Các giá trị cần input
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController born = TextEditingController();
  final TextEditingController phone = TextEditingController();

  bool isLoading = false;
  bool isPassword = true;
  bool isConfirmPassword = true;
  String? _validate() {
    //Các lỗi

    if (name.text.isEmpty) return 'Vui lòng nhập tên!';
    if (email.text.isEmpty) return 'Vui lòng nhập email!';
    if (phone.text.isEmpty) return 'Vui lòng nhập số điện thoại!';
    if (!RegExp(r'^[0-9]{10}').hasMatch(phone.text))
      return 'Số điện thoại phải là 10 chữ số!';
    if (born.text.isEmpty) return 'Vui lòng chọn ngày sinh!';

    if (password.text.isEmpty) return 'Vui lòng nhập mật khẩu!';
    if (password.text.length < 8) return 'Mật khẩu phải có ít nhất 6 ký tự!';
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password.text)) {
      return 'Mật khẩu phải có ít nhất 1 chữ HOA!';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(password.text)) {
      return 'Mật khẩu phải có ít nhất 1 chữ số!';
    }
    if (!RegExp(r'(?=.*[!@#\$%^&*])').hasMatch(password.text)) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt!';
    }

    if (confirmPassword.text != password.text)
      return 'Mật khẩu xác nhận không khớp!';

    return null;
  }

  // Hiển thị lỗi
  Future<void> _handleRegister() async {

    final error = _validate();

    if (error != null) {
      // Hiện banner đỏ ở trên cùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white), // icon ❌
              const SizedBox(width: 8),
              Text(error), // nội dung lỗi
            ],
          ),
          backgroundColor: Colors.red,       // nền đỏ
          behavior: SnackBarBehavior.floating, // nổi lên
          margin: const EdgeInsets.all(16),   // cách mép màn hình
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // bo góc
          ),
          duration: const Duration(seconds: 3), // tự mất sau 3 giây
        ),
      );
      return; // dừng lại
    }

    setState(() => isLoading = true);

    try{
      final user = await AuthService().registerWithEmail(
          email: email.text.trim(),
          password: password.text.trim(),
          name: name.text.trim(),
          phone: phone.text.trim(),
          born: born.text.trim());

      if (user != null && mounted) {
        // Đăng ký thành công → hiện thông báo xanh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Đăng ký thành công!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebase báo lỗi → hiện snackbar đỏ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text( _getFirebaseError(e.code)), // dịch mã lỗi
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false); // tắt loading dù thành công hay lỗi
    }
  }

  String _getFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Email này đã được đăng ký!';
      case 'invalid-email':        return 'Email không hợp lệ!';
      case 'weak-password':        return 'Mật khẩu quá yếu!';
      default:                     return 'Đăng ký thất bại, thử lại!';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // background tràn lên trên
      appBar: AppBar(
        backgroundColor: Colors.transparent, // trong suốt
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          //Overlay tối
          Container(color: Colors.black.withOpacity(0.6)),

          // Nội dung
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //title
                  const Text(
                    "Create your account !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 24),

                  //Nhập tên tài khoản
                  TextField(
                    controller: name,
                    style: const TextStyle(color: Colors.white),
                    // Trang tri
                    decoration: InputDecoration(
                      hintText: "Tên đang nhập",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  //Nhập email
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    // Trang tri
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  //Nhập số điện thoại
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    // Trang tri
                    decoration: InputDecoration(
                      hintText: "Số điên thoại",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  //Ngày sinh
                  TextField(
                    controller: born,
                    style: const TextStyle(color: Colors.white),
                    // Trang tri
                    decoration: InputDecoration(
                      hintText: "Ngày sinh (DD/MM/YYYY)",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white54,
                      ),
                    ),
                    onTap: () async {
                      // Khi bấm vào ô → hiện bảng chọn ngày
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000), // mặc định năm 2000
                        firstDate: DateTime(1900), // ngày nhỏ nhất có thể chọn
                        lastDate: DateTime.now(), // ngày lớn nhất = hôm nay
                      );

                      if (picked != null) {
                        // Nếu người dùng chọn ngày → điền vào ô
                        setState(() {
                          born.text =
                              "${picked.day}/${picked.month}/${picked.year}"; // định dạng DD/MM/YYYY
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  //Nhập mật khẩu
                  TextField(
                    controller: password,
                    obscureText: isPassword,
                    style: const TextStyle(color: Colors.white),
                    // Trang tri
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() => isPassword = !isPassword);
                        }, icon: Icon(
                          isPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ))
                    ),
                  ),

                  const SizedBox(height: 24),

                  //Nhập lại mật khẩu
                  TextField(
                    controller: confirmPassword,
                    obscureText: isConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    // Trang tri
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() => isConfirmPassword = !isConfirmPassword);
                      }, icon: Icon(
                        isConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ))
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00CFFF), // ← màu luôn hiện
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : _handleRegister, // ← dùng _isLoading
                      child: isLoading                               // ← dùng _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5, // ← mỏng hơn cho đẹp
                        ),
                      )
                          : const Text(
                        "REGISTER",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  /// Nút quay về Login
                  TextButton(
                    // TextButton = nút không có nền, chỉ có chữ
                    onPressed: () => Navigator.pop(context),
                    // Navigator.pop = quay lại màn hình trước đó (LoginScreen)
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.white70), // trắng mờ 70%
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/infor_workout_screen.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 220,
      child: Container(
        color: Colors.black,
        child: ListView(
          children: [

            // Title
            const Padding(
              padding: EdgeInsets.only(top: 60, bottom: 20, left: 20),
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            const Divider(color: Colors.white24),

            // Báo cáo
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                "Báo cáo",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                final uid = AuthService().uid;

                Navigator.pop(context);

                if (uid == null || uid.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bạn chưa đăng nhập")),
                  );
                  return;
                }

                // Tránh stack chồng
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  HomeScreen(uid: uid),
                  ),
                );
              },
            ),

            // Dữ liệu tập luyện
            ListTile(
              leading: const Icon(Icons.data_saver_on, color: Colors.white),
              title: const Text(
                "Dữ liệu tập luyện",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                final uid = AuthService().uid; // lấy realtime

                Navigator.pop(context);

                // Check login
                if (uid == null || uid.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Bạn chưa đăng nhập"),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InforWorkoutScreen(uid: uid),
                  ),
                );
              },
            ),

            // Nút đăng xuất
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context); // đóng drawer trước

                await AuthService().signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(), // đổi thành tên màn hình login của bạn
                  ),
                      (route) => false, // xóa hết stack, không back lại được
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
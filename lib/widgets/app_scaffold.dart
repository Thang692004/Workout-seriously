import 'package:flutter/material.dart';
import 'dart:ui';
import 'menu.dart';
import '../models/Users.dart';
import '../screens/profile_screeen.dart';
import '../services/auth_service.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottomNav;
  final bool showDrawer;
  final String title;
  final UserModel? user;

  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
    this.bottomNav,
    this.showDrawer = false,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer:  Menu(),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset("assets/images/background.png", fit: BoxFit.cover),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),

          // Child + title — nằm dưới top bar
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title hiện ở mọi màn hình
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, bottom: 8),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(child: child),
                ],
              ),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: 12,
                    right: 12,
                    bottom: 10,
                  ),
                  child: SizedBox(
                    height: 45,
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              "assets/images/Logo.png",
                              height: 2000,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileScreeen(user: user),
                              ),
                            );
                          },
                          child: Builder(
                            builder: (context) {
                              final String? avatarUrl = AuthService().getAvataUrl();

                              return CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.grey,
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl) // Google → ảnh Google
                                    : null,
                                child: avatarUrl == null
                                    ? Icon(Icons.person, size: 14, color: Colors.white) // Email → icon
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNav,
    );
  }
}
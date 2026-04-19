import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../models/Users.dart';
import '../services/auth_service.dart';

class ProfileScreeen extends StatefulWidget {
  UserModel? user;

  ProfileScreeen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _profileUserSceen();
}

class _profileUserSceen extends State<ProfileScreeen> {

  bool _isEditing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bornCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.user?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.user?.phone ?? '');
    _bornCtrl  = TextEditingController(text: widget.user?.born ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bornCtrl.dispose();
    super.dispose();
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
          SizedBox(height: 4),
          TextField(
            controller: ctrl,
            enabled: _isEditing,
            style: TextStyle(fontSize: 14, color: Colors.white70),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
              disabledBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = AuthService().getAvataUrl();

    return AppScaffold(
      title: "Hồ sơ cá nhân",
      child: SingleChildScrollView(
        child: Column(
          children: [

            // Avatar
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 100,
                height: 100,
                child: ClipOval(
                  child: Builder(
                    builder: (context) {
                      if (avatarUrl == null) {
                        return Image.asset('assets/images/user.webp', fit: BoxFit.cover);
                      } else {
                        return Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Image.asset('assets/images/user.webp', fit: BoxFit.cover),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Chức năng đang được phát triển '),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text('Thay đổi ảnh đại diện', style: TextStyle(color: Colors.white70)),
                ),
              ),
            ),
            SizedBox(height: 20),

            //  Thông tin cá nhân
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildField('HỌ VÀ TÊN', _nameCtrl),
                  Divider(height: 1, color: Colors.white12),

                  // Email không cho sửa
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EMAIL', style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
                        SizedBox(height: 4),
                        Text(widget.user?.email ?? '', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.white12),

                  _buildField('SỐ ĐIỆN THOẠI', _phoneCtrl),
                  Divider(height: 1, color: Colors.white12),
                  _buildField('NGÀY SINH', _bornCtrl),
                ],
              ),
            ),

            //  Nút Sửa / Lưu / Hủy
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _isEditing
                  ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white24),
                      ),
                      onPressed: () => setState(() => _isEditing = false),
                      child: Text('Hủy'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      onPressed: () {
                        // TODO: gọi Firestore cập nhật
                        setState(() => _isEditing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cập nhật thành công!')),
                        );
                      },
                      child: Text('Lưu lại', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
                  : SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white24),
                  ),
                  onPressed: () => setState(() => _isEditing = true),
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Chỉnh sửa thông tin'),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_scaffold.dart';
import '../models/Users.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class ProfileScreeen extends StatefulWidget {
  UserModel? user;
  ProfileScreeen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _profileUserSceen();
}

class _profileUserSceen extends State<ProfileScreeen> {
  bool _isEditing = false;
  bool _isSaving  = false;
  bool _isLoading = true;

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bornCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _favoriteExerciseCtrl;
  late TextEditingController _bioCtrl;

  String _selectedGender = '';
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameCtrl             = TextEditingController();
    _phoneCtrl            = TextEditingController();
    _bornCtrl             = TextEditingController();
    _addressCtrl          = TextEditingController();
    _favoriteExerciseCtrl = TextEditingController();
    _bioCtrl              = TextEditingController();
    _loadFreshUser();
  }

  Future<void> _loadFreshUser() async {
    final fresh = await AuthService().loadUserProfile();
    if (mounted) {
      setState(() {
        widget.user                = fresh;
        _nameCtrl.text             = fresh?.name             ?? '';
        _phoneCtrl.text            = fresh?.phone            ?? '';
        _bornCtrl.text             = fresh?.born             ?? '';
        _selectedGender            = fresh?.gender           ?? '';
        _addressCtrl.text          = fresh?.address          ?? '';
        _favoriteExerciseCtrl.text = fresh?.favoriteExercise ?? '';
        _bioCtrl.text              = fresh?.bio              ?? '';
        _isLoading                 = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bornCtrl.dispose();
    _addressCtrl.dispose();
    _favoriteExerciseCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // ── Validate số điện thoại ──
  String? _validatePhone(String value) {
    if (value.isEmpty) return null;
    if (value.length != 10) return 'Số điện thoại phải đủ 10 chữ số';
    if (!value.startsWith('0')) return 'Số điện thoại phải bắt đầu bằng 0';
    return null;
  }

  // ── Chọn ngày sinh bằng DatePicker ──
  Future<void> _pickDate() async {
    DateTime initialDate = DateTime(2000);
    if (_bornCtrl.text.isNotEmpty) {
      try {
        final parts = _bornCtrl.text.split('/');
        initialDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary:   Colors.deepPurple,
              onPrimary: Colors.white,
              surface:   Color(0xFF1A1A1A),
              onSurface: Colors.white70,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _bornCtrl.text =
        '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  // ── Lưu lên Firebase ──
  Future<void> _saveProfile() async {
    // Validate trước khi lưu
    final phoneErr = _validatePhone(_phoneCtrl.text.trim());
    if (phoneErr != null) {
      setState(() => _phoneError = phoneErr);
      return;
    }

    setState(() {
      _isSaving   = true;
      _phoneError = null;
    });

    final updated = UserModel(
      uid:             widget.user!.uid,
      email:           widget.user!.email,
      name:            _nameCtrl.text.trim(),
      phone:           _phoneCtrl.text.trim(),
      born:            _bornCtrl.text.trim(),
      gender:          _selectedGender,
      address:         _addressCtrl.text.trim(),
      favoriteExercise: _favoriteExerciseCtrl.text.trim(),
      bio:             _bioCtrl.text.trim(),
    );

    try {
      await UserService().updateProfileUser(updated);
      await _loadFreshUser();
      setState(() {
        _isEditing = false;
        _isSaving  = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  // ── Field thường ──
  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            readOnly:   !_isEditing,
            maxLines:   maxLines,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
            decoration: InputDecoration(
              isDense:        true,
              contentPadding: EdgeInsets.zero,
              border:         InputBorder.none,
              enabledBorder: _isEditing
                  ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple))
                  : InputBorder.none,
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field số điện thoại với validation ──
  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SỐ ĐIỆN THOẠI',
              style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          TextField(
            controller:  _phoneCtrl,
            readOnly:    !_isEditing,
            keyboardType: TextInputType.phone,
            maxLength:   10,
            // Chỉ cho nhập số
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 14, color: Colors.white70),
            onChanged: (val) {
              setState(() => _phoneError = _validatePhone(val));
            },
            decoration: InputDecoration(
              isDense:        true,
              contentPadding: EdgeInsets.zero,
              counterText:    '',  // ẩn counter "0/10"
              border:         InputBorder.none,
              enabledBorder: _isEditing
                  ? UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _phoneError != null ? Colors.red : Colors.deepPurple))
                  : InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: _phoneError != null ? Colors.red : Colors.deepPurple)),
              errorText: _isEditing ? _phoneError : null,
              errorStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field ngày sinh với DatePicker ──
  Widget _buildBornField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NGÀY SINH',
              style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _isEditing ? _pickDate : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _bornCtrl.text.isEmpty ? (_isEditing ? 'Chọn ngày sinh' : '') : _bornCtrl.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: _bornCtrl.text.isEmpty ? Colors.white24 : Colors.white70,
                    ),
                  ),
                ),
                if (_isEditing)
                  const Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple),
              ],
            ),
          ),
          if (_isEditing)
            const Divider(color: Colors.deepPurple, height: 8, thickness: 1),
        ],
      ),
    );
  }

  // ── Field giới tính với Dropdown ──
  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GIỚI TÍNH',
              style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          _isEditing
              ? DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:        _selectedGender.isEmpty ? null : _selectedGender,
              hint:         const Text('Chọn giới tính',
                  style: TextStyle(fontSize: 14, color: Colors.white24)),
              isExpanded:   true,
              dropdownColor: const Color(0xFF2A2A2A),
              isDense:      true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              items: ['Nam', 'Nữ'].map((g) => DropdownMenuItem(
                value: g,
                child: Text(g),
              )).toList(),
              onChanged: (val) => setState(() => _selectedGender = val ?? ''),
            ),
          )
              : Text(
            _selectedGender.isEmpty ? '' : _selectedGender,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          if (_isEditing)
            const Divider(color: Colors.deepPurple, height: 8, thickness: 1),
        ],
      ),
    );
  }

  // ── Email field ──
  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EMAIL',
              style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(widget.user?.email ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = AuthService().getAvataUrl();

    if (_isLoading) {
      return AppScaffold(
        title: 'Hồ sơ cá nhân',
        child: const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    return AppScaffold(
      title: 'Hồ sơ cá nhân',
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Avatar ──
            Center(
              child: SizedBox(
                width: 100, height: 100,
                child: ClipOval(
                  child: avatarUrl == null
                      ? Image.asset('assets/images/user.webp', fit: BoxFit.cover)
                      : Image.network(
                    avatarUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Image.asset('assets/images/user.webp', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color:        const Color(0xFF1A1A1A),
                border:       Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang được phát triển')),
                ),
                child: const Text('Thay đổi ảnh đại diện',
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
            const SizedBox(height: 20),

            // ── Khối thông tin ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:        const Color(0xFF1A1A1A),
                border:       Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildField('HỌ VÀ TÊN',          _nameCtrl),
                  const Divider(height: 1, color: Colors.white12),
                  _buildEmailField(),
                  const Divider(height: 1, color: Colors.white12),
                  _buildPhoneField(),       // ← có validation
                  const Divider(height: 1, color: Colors.white12),
                  _buildBornField(),        // ← DatePicker
                  const Divider(height: 1, color: Colors.white12),
                  _buildGenderField(),      // ← Dropdown
                  const Divider(height: 1, color: Colors.white12),
                  _buildField('ĐỊA CHỈ',              _addressCtrl),
                  const Divider(height: 1, color: Colors.white12),
                  _buildField('BỘ MÔN YÊU THÍCH',   _favoriteExerciseCtrl),
                  const Divider(height: 1, color: Colors.white12),
                  _buildField('GIỚI THIỆU BẢN THÂN', _bioCtrl, maxLines: 3),
                ],
              ),
            ),

            // ── Nút Sửa / Lưu / Hủy ──
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isEditing
                  ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () => setState(() {
                        _isEditing  = false;
                        _phoneError = null;
                      }),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple),
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Lưu lại',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
                  : SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  onPressed: () => setState(() => _isEditing = true),
                  icon:  const Icon(Icons.edit, size: 16),
                  label: const Text('Chỉnh sửa thông tin'),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
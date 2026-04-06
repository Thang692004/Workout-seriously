class UserModel{
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String born;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.born,
});

  // Lấy giá trị từ FireBase
  factory UserModel.fromMap(String uid, Map<String, dynamic> map){
    return UserModel(
        uid: uid,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        born: map['born'] ?? '',);
  }

  // Gias trị gửi lên Firebase
  Map<String, dynamic> toMap()
  {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'born': born,
    };
  }
}
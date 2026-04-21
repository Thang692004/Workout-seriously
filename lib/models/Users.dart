class UserModel{
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String born;

  // Thêm trường dữ liệu mới khi người dùng đăng ký tài khoản thành công
  final String gender;
  final String address;
  final String favoriteExercise;
  final String bio;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.born,

    this.gender  = '',
    this.address = '',
    this.bio     = '',
    this.favoriteExercise = '',
});

  // Lấy giá trị từ FireBase
  factory UserModel.fromMap(String uid, Map<String, dynamic> map){
    return UserModel(
        uid: uid,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        born: map['born'] ?? '',
        gender: map['gender'] ?? '',
        address: map['address'] ?? '',
        favoriteExercise: map['favoriteExercise'] ?? '',
        bio: map['bio'] ?? '',
    );

  }

  // Gias trị gửi lên Firebase
  Map<String, dynamic> toMap()
  {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'born': born,
      'gender': gender,
      'address': address,
      'favoriteExercise': favoriteExercise,
      'bio' : bio,
    };
  }
}
  # 📱 TapLuyen App

TapLuyen là ứng dụng mobile được xây dựng bằng Flutter giúp người dùng quản lý lịch tập gym, theo dõi tiến trình và cải thiện hiệu quả luyện tập.

---

## 🚀 Demo






## ✨ Features

* 🔐 Đăng nhập / đăng ký (Firebase Auth)
* 📅 Quản lý lịch tập
* 🏋️ Theo dõi bài tập
* 📊 Hiển thị tiến trình luyện tập bằng biểu đồ
* 💾 Lưu dữ liệu trên Cloud Firestore


## 🛠️ Tech Stack

* Flutter
* Firebase Authentication
* Cloud Firestore
* State Management (Provider / Riverpod)

## ⚙️ Getting Started


### 1. Cài dependencies

 firebase_core: ^2.30.0
  firebase_auth: ^4.17.0
  google_sign_in: ^6.2.1
  cloud_firestore: ^4.17.5
  provider: ^6.1.2
  flutter:
    sdk: flutter
  fl_chart: ^0.70.2

### 3. Chạy app

```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── models/
├── screens/
├── services/
├── widgets/
```

---

## 📌 Future Improvements

* Thêm chức năng nhắc lịch tập
* Đồng bộ dữ liệu realtime


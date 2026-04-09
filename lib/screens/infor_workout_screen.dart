import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class InforWorkoutScreen extends StatelessWidget {
  const InforWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Dữ liệu buổi tập",
      child: TextField(),
    );
  }

}
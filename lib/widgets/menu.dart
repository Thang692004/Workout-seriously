import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/infor_workout_screen.dart';
class Menu extends StatefulWidget{

  const Menu({super.key});

  @override
  State<StatefulWidget> createState()  => _MenuState();
}

class _MenuState extends State<Menu>{
  @override
  Widget build(BuildContext context){
    return Drawer(
        width: 220,
      child: Container(
        color: Colors.black,
        height: double.infinity,
        child: ListView(
          children: [

            Padding(
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
            Divider(color: Colors.white24),
            // Trang chu
            ListTile(
              leading: Icon(Icons.home, color: Colors.white,),
              title:  Text("Trang chủ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen()));
              },
            ),

            // Dữ liệu tập luyện
            ListTile(
              leading: Icon(Icons.data_saver_on, color: Colors.white,),
              title:  Text("Dữ liệu tập luyện", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => InforWorkoutScreen()));
              },
            )
          ],
        ),
      )
    );
  }
}
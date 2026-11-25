
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:test_application/pages/home.dart';



void main() async {

    runApp(MyApp());
  
}


class MyApp extends StatefulWidget {

  const MyApp({Key? key,}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {




  @override
  void initState() {
    // TODO: implement initState
   
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
 
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,   
    
   
    home: HomePage()

    );
  }
}

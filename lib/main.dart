import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_app/home_screen.dart';
import 'package:task_app/login_screen.dart';

void main()async {
WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainApp());

}
class MainApp extends StatelessWidget {
  const MainApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor=Color(0xFF00F58D);


    return MaterialApp(
     debugShowCheckedModeBanner: false,
     home: HomePage(),
     theme: ThemeData(primaryColor: primaryColor,
     brightness: Brightness.light
     ),
     darkTheme: ThemeData(brightness: Brightness.dark,
     primaryColor: primaryColor),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

final FirebaseAuth _auth=FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, AsyncSnapshot<User> snapshot) {
        if(snapshot.hasData){
          if(snapshot.data != null){
            // return with out login
            return HomeScreen();
          }else{
            // return  login
            return LoginScreen();
          }
        }else{
          return LoginScreen();
        }
      },
    ),
    );
  }
}




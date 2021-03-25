import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_app/Signin_using_phone.dart';
import 'package:task_app/email_pass_signup.dart';



class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

final TextEditingController _emailController=TextEditingController();
final TextEditingController _passwordController=TextEditingController();

final FirebaseAuth _auth=FirebaseAuth.instance;

final FirebaseFirestore _db=FirebaseFirestore.instance;

final GoogleSignIn _googleSignIn=GoogleSignIn();

final Color primaryColor=Color(0xFF00F58D);
final Color secondaryColor=Color(0xFF006572);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(
          bottom: 80,
        ),
        child: Column(children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              top: 80,
            ),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  blurRadius: 30,
                  color: Color(0x44000000),
                  offset: Offset(10, 10),
                  spreadRadius: 0)
            ]),
            child: Image(
              image: AssetImage("assets/logo_round.png"),
              width: 200,
              height: 200,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top:20,),
            child: Text("Login",
            style: TextStyle(fontSize: 30,),)
            ),
             Container(
               padding:EdgeInsets.all(10.0) ,
               margin: EdgeInsets.only(top:40,),
               child: TextField(
                 controller:_emailController,
                 decoration: InputDecoration(
                 border: OutlineInputBorder(),
                 labelText: "Email",
                 hintText: "Write Email Here"
               ),
               keyboardType: TextInputType.emailAddress,
               ),          
      ),
             Container(
               padding:EdgeInsets.all(10.0) ,
               margin: EdgeInsets.only(top:10,),
               child: TextField(
                 controller: _passwordController,
                 decoration: InputDecoration(
                 border: OutlineInputBorder(),
                 labelText: "Password",
                 hintText: "Write Password Here"
               ),
               obscureText: true,
               ),          
      ),
     InkWell(
       child: Container(
         decoration: BoxDecoration(
           gradient:LinearGradient(colors: [
           primaryColor,
           secondaryColor
         ]),
         borderRadius: BorderRadius.circular(8.0)
         ),
         width: MediaQuery.of(context).size.width,
         margin: EdgeInsets.symmetric(horizontal:30,vertical:20),
         padding: EdgeInsets.symmetric(horizontal:30,vertical:20),
         child: Center(child: Text("Login With Email",style: TextStyle(color: Colors.white),)),
       ),
       onTap:(){
         _signIn();
       },),
       
       FlatButton(onPressed: (){
         Navigator.push(context, MaterialPageRoute(builder: (context)=>EmailPassSignupScreen()));
       }, child: Text("Signup Using Email")),

       Container(
         margin: EdgeInsets.only(top:30,),
         child: Wrap(children:<Widget>[
           
           FlatButton.icon(
             onPressed: (){
               _signInusingGoogle();
             },
             icon: Icon(FontAwesomeIcons.google,color: Colors.red,),
             label: Text("Sign-In using Gmail",style: TextStyle(color: Colors.red),),
           ),
           FlatButton.icon(
             onPressed: (){
               Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInUsingPhone()));
             },
             icon: Icon(Icons.phone,color: Colors.blue,),
             label: Text("Sign-In using Phone",style: TextStyle(color: Colors.blue)),
           ),
         ]),
       )

        ]),
      ),
    );
  }
  void _signIn() async{   
String email=_emailController.text.trim();
String password=_passwordController.text.trim();
if(email.isNotEmpty && password.isNotEmpty){
_auth.signInWithEmailAndPassword(email: email, password: password).then((user){

   _db.collection("users").doc(user.user.uid).set({
         "email":email,
         "lastseen":DateTime.now(),
         
       });


showDialog(context: context, builder: (ctx){
   return AlertDialog(
      shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Success"),
      content: Text("SignIn Succesfully"),
      actions: [
         FlatButton(onPressed: (){
          Navigator.of(ctx).pop();
        }, child: Text("Ok")),
      ],
    );
  });
})
.catchError((e){
  showDialog(context: context, builder: (ctx){
     return AlertDialog(
      shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Error"),
      content: Text("${e.message}"),
      actions: [
        FlatButton(onPressed: (){
          Navigator.of(ctx).pop();
        }, child: Text("Cancel")),
         FlatButton(onPressed: (){
          Navigator.of(ctx).pop();
        }, child: Text("Ok")),
      ],
    );
  });
});
}else{
showDialog(context: context, builder: (ctx){
 return AlertDialog(
  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),),
  title: Text("Error"),
  content: Text("Please Provide Email and Password"),
  actions: [
    FlatButton(onPressed: (){
      Navigator.of(ctx).pop();
    }, child: Text("Cancel")),
    FlatButton(onPressed: (){
      _emailController.text="";
      _passwordController.text="";
      Navigator.of(ctx).pop();
    }, child: Text("Ok")),
  ],
);
});
}
  }

  void _signInusingGoogle() async{
    try{
  final GoogleSignInAccount googleUser=await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth=await googleUser.authentication;

   final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken:googleAuth.accessToken,
    idToken:googleAuth.idToken,
  );

  final User user=(await _auth.signInWithCredential(credential)).user;
  print("signed in" + user.displayName);

  if (user!=null){
    _db.collection("users").doc(user.uid).set({
     "displayName":user.displayName,
     "email":user.email,
     "photUrl":user.photoURL,
     "lastseen":DateTime.now(),
    });
  }
    }catch(e){
        
        showDialog(context: context, builder: (ctx){
     return AlertDialog(
      shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Error"),
      content: Text("${e.message}"),
      actions: [
        FlatButton(onPressed: (){
          Navigator.of(ctx).pop();
        }, child: Text("Cancel")),
         FlatButton(onPressed: (){
          Navigator.of(ctx).pop();
        }, child: Text("Ok")),
      ],
    );
  });

    }
  }

}

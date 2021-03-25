import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailPassSignupScreen extends StatefulWidget {
  EmailPassSignupScreen({Key key}) : super(key: key);
 


  @override
  _EmailPassSignupScreenState createState() => _EmailPassSignupScreenState();
}

class _EmailPassSignupScreenState extends State<EmailPassSignupScreen> {
     
     final TextEditingController _emailController=TextEditingController();
     final TextEditingController _passwordController=TextEditingController();
     
     final FirebaseAuth _auth=FirebaseAuth.instance;

     final FirebaseFirestore _db=FirebaseFirestore.instance;

     final Color primaryColor=Color(0xFF00F58D);
     final Color secondaryColor=Color(0xFF006572);

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(title: Text("Email Sign up"),),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children:[
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
         child: Center(child: Text("Sign-Up Using Email",style: TextStyle(color: Colors.white),)),
       ),
       onTap:(){
         _signUp();
       },),
       
            ]
          )
          ,),
      ),
    );
  }
  
  void _signUp(){
     
     final String emailTxt=_emailController.text.trim();
     final String passwordTxt=_passwordController.text.trim();

     if(emailTxt.isNotEmpty && passwordTxt.isNotEmpty){
      _auth.createUserWithEmailAndPassword(email: emailTxt, password: passwordTxt).then((user) {
       
       _db.collection("users").doc(user.user.uid).set({
         "email":emailTxt,
         "lastseen":DateTime.now(),
       });

        showDialog(context: context, builder: (ctx){
 return AlertDialog(
  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),),
  title: Text("Succes"),
  content: Text("Sign up Process done,now you can sign in."),
  actions: [
    FlatButton(onPressed: (){
      Navigator.of(context).pop();
    }, child: Text("ok")),
  ],
);
});
      })
      .catchError((e){
           showDialog(context: context, builder: (ctx){
 return AlertDialog(
  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),),
  title: Text("Error"),
  content: Text("${e.message}"),
  actions: [
    FlatButton(onPressed: (){
      Navigator.of(ctx).pop();
    }, child: Text("ok")),
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
    }, child: Text("ok")),
  ],
);
});
     }

  }

}
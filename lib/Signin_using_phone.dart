import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignInUsingPhone extends StatefulWidget {
  SignInUsingPhone({Key key}) : super(key: key);

  @override
  _SignInUsingPhoneState createState() => _SignInUsingPhoneState();
}

class _SignInUsingPhoneState extends State<SignInUsingPhone> {

   final FirebaseAuth _auth=FirebaseAuth.instance;
   final FirebaseFirestore _db =FirebaseFirestore.instance;
   String _message;
   String _verificationID;
   bool _isSMSsent = false ;
   final TextEditingController _smsController=TextEditingController();

   PhoneNumber _phoneNumber;

final Color primaryColor=Color(0xFF00F58D);
final Color secondaryColor=Color(0xFF006572);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text("SignIn Using Phone"),),
       body: SingleChildScrollView(
         child: AnimatedContainer(
           duration: Duration(milliseconds:300),
         width: MediaQuery.of(context).size.width,
         margin: EdgeInsets.only(top:20),
         child: Column(
           children:[
             Container(margin: EdgeInsets.symmetric(vertical:10,horizontal:20),
             child: InternationalPhoneNumberInput(
               onInputChanged:(phoneNumberTxt){
                 _phoneNumber=phoneNumberTxt;
               },
               inputBorder: OutlineInputBorder(),
               
                ),
             ),
               
               _isSMSsent==true ?
               Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: _smsController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "OTP HERE",
                    labelText: "OTP"
                  ),
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                ),
               ):
               Container(),

      _isSMSsent==false ?
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
         child: Center(child: Text("Send OTP",style: TextStyle(color: Colors.white),)),
       ),
       onTap:(){
         setState(() {
            _isSMSsent=true;
         });
      _verifyPhoneNumber();
       },
       )
       :    InkWell(
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
         child: Center(child: Text("Verify OTP",style: TextStyle(color: Colors.white),)),
       ),
       onTap:(){
         _signInWithPhoneNumber();
       }
       )

           ]
         ),
       ),),
    );
  }
  void _verifyPhoneNumber() async{
    setState(() {
      _message="";
    });
    final PhoneVerificationCompleted verificationCompleted=(AuthCredential phoneAuthCredential){
     _auth.signInWithCredential(phoneAuthCredential);
     setState(() {
       _message="Received Phone AUTH Credential: $phoneAuthCredential";
     });
    };
    final PhoneVerificationFailed verificationFailed=(FirebaseAuthException authException){
      setState(() {
        _message="Phone Number Verification Failed. code: ${authException.code}. Message: ${authException.message}";
      });
    };
    final PhoneCodeSent codeSent = 
      (String verificationId,[int forceResendingToken ]
    ) async {
      _verificationID=verificationId;
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout=(
      String verificationId){
        _verificationID=verificationId;
      };
      await _auth.verifyPhoneNumber(phoneNumber: _phoneNumber.phoneNumber,
      timeout: const Duration(seconds:120),
       verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed, 
        codeSent: codeSent, 
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }
  void _signInWithPhoneNumber() async {
    final AuthCredential credential=PhoneAuthProvider.credential(verificationId:_verificationID,
    smsCode: _smsController.text
    );
    final User user=(await _auth.signInWithCredential(credential)).user;
    final User currentUser = await _auth.currentUser;
    assert(user.uid==currentUser.uid);
    setState(() {
      if(user !=null){
        _db.collection("users").doc(user.uid).set({
            "phonenumber":user.phoneNumber,
            "lastseen":DateTime.now(),
        });
        _message ="Successfully Signed in, uid:"+user.uid;
      }else{
        _message ="sign in failed";
      }
    });
  }
}
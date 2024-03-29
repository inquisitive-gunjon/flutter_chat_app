import 'dart:developer';
import 'dart:io';

import 'package:chat_app/view/screens/auth/otp_verification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../api/apis.dart';
import '../../../helper/dialogs.dart';
import '../../../main.dart';
import '../home_screen.dart';

//login screen -- implements google sign in or sign up feature for app
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _phoneNumber = '';

  void _submitForm(){
    if (_formKey.currentState!.validate()) {
       APIs.sendOtp(_phoneNumberController.text, context);
      // Form is valid, you can handle phone number submission here

      log('Phone number submitted: $_phoneNumberController.text');
    }
  }

  String? _validatePhoneNumber(String value) {
    // Validate Bangladesh phone number
    String pattern = r'^\+8801[3-9]\d{8}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid Bangladesh phone number';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }


  // handles google login button click
  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }

  //sign out function
  // _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    // mq = MediaQuery.of(context).size;

    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to E-Chat'),
      ),

      //body
      body: Stack(children: [
        //app logo
        AnimatedPositioned(
            top: mq.height * .05,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            bottom: mq.height * .6,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/e_chat.png')),

        //google login button
        Positioned(
            bottom: mq.height * .3,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .2,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Image.asset("images/phone.png",height: 30.h,width: 30.w,fit: BoxFit.contain,),
                      labelText: 'Phone Number',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff8C8AFF), // Customize the color if needed
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue, // Customize the color if needed
                        ),
                      ),
                    ),
                    validator:(value) => _validatePhoneNumber(value!),
                    // onSaved: (value) => _phoneNumber = value!,
                  ),
                  SizedBox(height: 20.h,),
                  ElevatedButton(
                    onPressed:_submitForm,
                    // onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OtpVerificationPage())),
                    child: Text("Send Otp",style: TextStyle(fontSize: 16.sp),),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(197.w, 42.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0.sp), // Adjust the radius as needed
                      ),
                    ),
                  )
                ],
              ),
            )),
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8C8AFF),
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleBtnClick();
                },

                //google icon
                icon: Image.asset('images/google.png', height: mq.height * .03),

                //login with google label
                label: RichText(
                  text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(text: 'Login with '),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                ))),
      ]),
    );
  }
}

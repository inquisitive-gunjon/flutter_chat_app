import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:chat_app/view/screens/auth/otp_verification_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   height: 100,
            //   width: double.infinity,
            //   color: Colors.red,
            // ),
            Align(
              alignment: Alignment.center,
                child: Image.asset("assets/images/e_chat.png",height: 118.h,width: 216.w,fit: BoxFit.contain,)
            ),
            SizedBox(height: 50.h,),
            TextFormField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: Image.asset("assets/images/phone.png",height: 30.h,width: 30.w,fit: BoxFit.contain,),
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
            ),
            SizedBox(height: 20.h,),
            ElevatedButton(
                onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OtpVerificationPage())),
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
      ),
    );
  }
}

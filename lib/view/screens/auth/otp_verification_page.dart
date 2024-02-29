

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// import 'package:chat_app/view/chat/chat_list_box.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({Key? key}) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {

  final TextEditingController _pinEditingController = TextEditingController();
  Timer? _resendTimer;
  int _resendDuration = 180; // 3 minutes in seconds
  bool _isResendButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void startResendTimer() {
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendDuration > 0) {
          _resendDuration--;
        } else {
          _isResendButtonEnabled = true;
          _resendTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void resendOtp() {
    // Add logic to resend OTP here
    // For example, you can reset the timer and disable the button again
    setState(() {
      _resendDuration = 180;
      _isResendButtonEnabled = false;
    });

    startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xff8C8AFF),
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //   height: 100,
                //   width: double.infinity,
                //   color: Colors.red,
                // ),
                Align(
                    alignment: Alignment.center,
                    child: Image.asset("images/e_chat.png",height: 100.h,width: 200.w,fit: BoxFit.contain,)
                ),
                SizedBox(height: 5.h,),
                Align(
                    alignment: Alignment.center,
                    child: Image.asset("images/correct.png",height: 100.h,width: 100.w,fit: BoxFit.contain,)
                ),
                SizedBox(height: 30.h,),
                Text("Please try again if the code is not received or has expired",style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xff000000)
                ),),
                SizedBox(height: 5.h,),
                AutofillGroup(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: PinInputTextField(
                        pinLength: 4,
                        keyboardType: TextInputType.number,
                        controller: _pinEditingController,
                        decoration: BoxLooseDecoration(
                          strokeColorBuilder: PinListenColorBuilder(Colors.blue,Colors.blue),
                          radius: Radius.circular(8),
                        ),
                        onChanged: (pin) {
                          // Handle OTP changes
                        },
                        onSubmit: (pin) {
                          // Handle OTP submission
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h,),
                _isResendButtonEnabled
                    ? ElevatedButton(
                      onPressed: () {
                        resendOtp();
                      },
                      child: Text('Resend OTP',style: TextStyle(fontSize: 16.sp,color: Color(0xff545D69)),),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xffDADEE3),
                    fixedSize: Size(258.w, 42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0.sp), // Adjust the radius as needed
                    ),
                  ),
                    )
                    : Align(alignment: Alignment.center,child: Text('Resend OTP in $_resendDuration seconds')),
                SizedBox(height: 20.h,),
                ElevatedButton(
                  onPressed: ()=>null,
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatInbox())),
                  child: Text("Next",style: TextStyle(fontSize: 16.sp),),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(258.w, 42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0.sp), // Adjust the radius as needed
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

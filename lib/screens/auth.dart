import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_code_picker/country_code_picker.dart';

class Auth extends StatefulWidget {
  @override
  State createState() => new AuthState();
}

class AuthState extends State<Auth> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Use the @formatter:off comment to disable formating for this block of code
  /// due to weird behavior when auto formatted

  // @formatter:off
  Future<String> _message = Future<String>.value("Welcome to NG Polls");
  // @formatter:on

  String verificationId;
  final String testSmsCode = '123456';
  final String testPhoneNumber = "+234 803 052 0715";

  var phoneNumber = "";
  var e164phoneNumber = "";

  final TextEditingController _phoneController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildMessageField(),
              buildPhoneTextField(),
              buildSignInButton()
            ],
//      child: new Text("Welcome")
          ),
        ));
  }


  Widget buildMessageField() =>
      new Container(
        alignment: new Alignment(0.0, 0.0),
        margin: const EdgeInsets.only(bottom: 64.0),
        child: FutureBuilder<String>(
            future: _message,
            builder: (_, AsyncSnapshot<String> snapshot) {
              return Text(snapshot.data ?? '',
                  style: TextStyle(color: Color.fromARGB(255, 0, 155, 0)));
            }),
      );

  Widget buildPhoneTextField() =>
      new Container(
          alignment: new Alignment(0.5, 0.5),
          height: 36.0,
          margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
//        decoration: new BoxDecoration(
//            borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
//            border: new Border.all(color: Colors.grey)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CountryCodePicker(
                onChanged: _onCountryChange,
                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                initialSelection: 'NG',
                favorite: ['+234', 'NG'],
              ),
              new Flexible(
                  child: new TextFormField(
                      controller: _phoneController,
                      onSaved: (val) => phoneNumber = val,
                      decoration: new InputDecoration.collapsed(
                          hintText: "Phone Number"),
                      keyboardType: TextInputType.phone,
                      validator: (val) =>
                      val.length < 11 || val.length > 14
                          ? "Invalid Phone Number"
                          : null
                  )),
            ],
          )
      );

  Widget buildSignInButton() =>
      new Padding(
          padding: new EdgeInsets.all(8.0),
          child: new RaisedButton(
              color: new Color(0xff64B5F6),
              onPressed: _confirmAuth,
              child: new Text(
                "Continue with Phone Number",
                style: new TextStyle(color: new Color(0xffffffff)),
              )));

  void _onCountryChange(CElement cElement) {
    print("New Country selected: " + cElement.toString());
    e164phoneNumber = cElement.dialCode + phoneNumber.replaceFirst(new RegExp(r'0'), '');
    print("E.164 Format phone number: "+e164phoneNumber);
  }

  void _confirmAuth() {
    String p = r'^\\+?[1-9]\\d{1,14}$';
    var phone = _phoneController.text.trim();
//    RegExp exp = new RegExp(p);
//    if (!exp.hasMatch(phone)) {
//      AlertDialog dialog = new AlertDialog(
//        title: new Text("Error!!"),
//        content: new Text("Phone number is not valid!"),
//        actions: <Widget>[
//          new FlatButton(
//              onPressed: () => Navigator.pop(context), child: const Text('OK'))
//        ],
//      );
//      showDialog(
//          context: context,
//          barrierDismissible: true,
//          builder: (context) => dialog);
//      return;
//    }
    _testVerifyPhoneNumber(phone);
  }


  Future<void> _testVerifyPhoneNumber(String phone) async {
    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {
      setState(() {
        // @formatter:off
        _message = Future < String>.value('signInWithPhoneNumber auto succeeded :$user');
        // @formatter:on
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        //@formatter:off
        _message = Future < String>.value('Phone numbber verification failed. Code:${authException.code}.Message:${
        authException.message}');
        //@formatter:on
        });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      _phoneController.text = testSmsCode;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      _phoneController.text = testSmsCode;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<String> _testSignInWithPhoneNumber(String smsCode) async {
    final FirebaseUser user = await _auth.signInWithPhoneNumber(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    _phoneController.text = '';
    return 'signInWithPhoneNumber succeeded: $user';
  }

}

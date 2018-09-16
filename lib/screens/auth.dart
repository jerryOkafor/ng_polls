import 'package:flutter/material.dart';
import 'package:ng_polls/base/loading_state.dart';

class Auth extends StatefulWidget {
  @override
  State createState() => new AuthState();
}

class AuthState extends State<Auth> {
  final TextEditingController _phoneController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[buildPhoneTextField(), buildSignInButton()],
//      child: new Text("Welcome")
          ),
        ));
  }


  Widget buildPhoneTextField() => new Container(
        alignment: new Alignment(0.5, 0.5),
        height: 36.0,
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
            border: new Border.all(color: Colors.grey)),
        child: new TextField(
          controller: _phoneController,
          decoration: new InputDecoration.collapsed(hintText: "Email"),
          keyboardType: TextInputType.phone,
        ),
      );

  Widget buildSignInButton() => new Padding(
      padding: new EdgeInsets.all(8.0),
      child: new RaisedButton(
          color: new Color(0xff64B5F6),
          onPressed: _confirmAuth,
          child: new Text(
            "Continue with Phone Number",
            style: new TextStyle(color: new Color(0xffffffff)),
          )));

  void _confirmAuth() {
    String p = r'/^\+(?:[0-9] ?){6,14}[0-9]$/';
    var email = _phoneController.text.trim();
    RegExp exp = new RegExp(p);
    if (!exp.hasMatch(email)) {
      AlertDialog dialog = new AlertDialog(
        title: new Text("Error!!"),
        content: new Text("Phone number is not valide!"),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => dialog);
      return;
    }
  }

}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app4/Widget/bezierContainer.dart';
import 'package:flutter_app4/login/register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

/// Entrypoint example for various sign-in flows with Firebase.
class SignInPage extends StatefulWidget {
  /// The page title.
  final String title = 'Sign In & Out';

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String validatePassword(String value) {
    if (value.isEmpty) {
      return "* Required";
    } else if (value.length < 8) {
      return "Password should be atleast 8 characters";
    } else if (value.length > 15) {
      return "Password should not be greater than 15 characters";
    } else
      return null;
  }

  //Controllers for e-mail and password textfields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailPasswordDimenticata = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -MediaQuery.of(context).size.height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer(),
              ),
              Center(
                //padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            width: 200,
                            height: 200,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: Image.asset('assets/icona_dawey.png')),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 0, bottom: 10),
                        child: SignInButton(
                          Buttons.GoogleDark,
                          onPressed: () {
                            _signInWithGoogle();
                          },
                        ),
                      ),
/*                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 0, bottom: 10),
                        child: SignInButton(
                          Buttons.Apple,
                          mini: true,
                          onPressed: () {},
                        ),
                      ),*/
                      Form(
                        autovalidateMode: AutovalidateMode.always,
                        key: formkey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'Email',
                                      hintText:
                                          'Enter valid email id as abc@gmail.com'),
                                  validator: MultiValidator([
                                    RequiredValidator(errorText: "* Required"),
                                    EmailValidator(
                                        errorText: "Enter valid email id"),
                                  ])),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 15, bottom: 0),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(20.0),
                                      ),
                                    ),
                                    labelText: 'Password',
                                    hintText: 'Enter secure password'),
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(errorText: "* Required"),
                                    MinLengthValidator(8,
                                        errorText:
                                            "Password should be atleast 8 characters"),
                                    PatternValidator(r'(?=.*?[0-9])',
                                        errorText:
                                            'passwords must have at least one number')
                                  ],
                                ),
                                //validatePassword,        //Function to check validation
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _displayTextInputDialog(context);
                              },
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                    color: Colors.lightGreen, fontSize: 15),
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 250,
                              decoration: BoxDecoration(
                                  color: Colors.lightGreen,
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextButton(
                                onPressed: () async {
                                  if (formkey.currentState.validate()) {
                                    await _signInWithEmailAndPassword();
                                    print("Validated");
                                  } else {
                                    print("Not Validated");
                                  }
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: TextButton(
                                onPressed: () =>
                                    _pushPage(context, RegisterPage()),
                                child: Text('New User? Create Account'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => null)
        .catchError((error) => null);
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.email} signed in'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
      ));
    }
  }

  //Example code of how to sign in with Google.
  Future<void> _signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final GoogleAuthCredential googleAuthCredential =
            GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth
            .signInWithCredential(googleAuthCredential)
            .then((value) => addUser(value));
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sign In ${userCredential.user.uid} with Google'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
      ));
    }
  }

  Future<UserCredential> addUser(value) async {
    // Call the user's CollectionReference to add a new user
    final docSnapshot =
        await firestore.collection("users").doc(value.user.uid).get();

    if (!docSnapshot.exists) {
      await firestore.collection("users").doc(value.user.uid).set({
        "uid": value.user.uid,
        "email": value.user.email,
        "username": value.user.displayName,
        "creazione": FieldValue.serverTimestamp(),
        "tags_interesse": [],
        "universita": "",
        "grafico": {},
        "attiva_filtri": true,
      }).then((_) {
        print("success!");
      });
    }
    ;
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return new CupertinoAlertDialog(
          title: new Text('Reset Password'),
          content: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  "Inserisci il tuo indirizzo e segui le indicazioni sulla email."),
              SizedBox(
                height: 20,
              ),
              CupertinoTextField(
                controller: _emailPasswordDimenticata,
                keyboardType: TextInputType.emailAddress,
                placeholder: "Inserisci la email Email",
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Invia"),
              onPressed: () async {
                await _auth
                    .sendPasswordResetEmail(
                        email: _emailPasswordDimenticata.text)
                    .then(
                      (value) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Email inviata'),
                        ),
                      ),
                    )
                    .catchError(
                      (error) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.message),
                        ),
                      ),
                    );

                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text("Chiudi"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}

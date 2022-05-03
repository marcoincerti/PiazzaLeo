import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app4/Widget/bezierContainer.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

/// Entrypoint example for registering via Email/Password.
class RegisterPage extends StatefulWidget {
  /// The page title.
  final String title = 'Registrazione';

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  bool _success;
  String _userEmail = '';
  String password;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: AppBar().preferredSize,
        child: Container(
          child: AppBar(
            title: Text("Registrazione"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))),
            elevation: 8,
            backgroundColor: Colors.lightGreen,
          ),
        ),
      ),
      body: GestureDetector(
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
                            width: 150,
                            height: 150,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: Image.asset('assets/icona_dawey.png')),
                          ),
                        ),
                      ),
                      Form(
                        autovalidateMode: AutovalidateMode.always,
                        key: formkey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 0, bottom: 15),
                              child: TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(20.0),
                                      ),
                                    ),
                                    labelText: 'Username',
                                    hintText: 'Mario_rossi'),
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(errorText: "* Required"),
                                  ],
                                ),
                              ),
                            ),
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
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(errorText: "* Required"),
                                    EmailValidator(
                                        errorText: "Enter valid email id"),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 15, bottom: 0),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                onChanged: (val) => password = val,
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
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 15, bottom: 0),
                              child: TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(20.0),
                                      ),
                                    ),
                                    labelText: 'Confirm Password',
                                    hintText: 'Confirm secure password'),
                                validator: (val) => MatchValidator(
                                        errorText: 'passwords do not match')
                                    .validateMatch(val, password),
                              ),
                            ),
                            SizedBox(
                              width: 50.0,
                              height: 50.0,
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
                                    await _register();
                                    print("Validated");
                                  } else {
                                    print("Not Validated");
                                  }
                                },
                                child: Text(
                                  'Registrati',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                              height: 20.0,
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

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code for registration.
  Future<void> _register() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      final User user = userCredential.user;

      user.updateProfile(displayName: _nameController.text);
      user.sendEmailVerification();

      if (user != null) {
        await addUser(user);
        setState(() {
          _success = true;
          _userEmail = user.email;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.email} signed in'),
            ),
          );
        });
        Navigator.pop(context);
      } else {
        _success = false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The password provided is too weak.'),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The account already exists for that email.'),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<UserCredential> addUser(value) async {
    // Call the user's CollectionReference to add a new user
    final docSnapshot =
        await firestore.collection("users").doc(value.uid).get();

    if (!docSnapshot.exists) {
      await firestore.collection("users").doc(value.uid).set({
        "uid": value.uid,
        "email": value.email,
        "username": _nameController.text,
        "creazione": FieldValue.serverTimestamp(),
        "tags_interesse": [],
        "universita": "",
        "grafico": {},
        "attiva_filtri": true,
      }).then((_) {
        print("success!");
      });
    }
  }
}

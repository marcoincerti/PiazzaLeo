import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app4/Widget/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:form_field_validator/form_field_validator.dart';


class accountPersona extends StatefulWidget {
  @override
  _accountPersonaState createState() => _accountPersonaState();
}

class _accountPersonaState extends State<accountPersona> {
  Stream tags;

  Map<String, dynamic> grafico = {"demo": 50, "demo ": 25, "demo  ": 25, "demo   ": 25};

  final auth = FirebaseAuth.instance;
  User user;
  int touchedIndex;

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController _nomeUtente = TextEditingController();
  final TextEditingController _emailUtente = TextEditingController();

  @override
  void initState() {
    user = auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0))),
              elevation: 8,
              backgroundColor: Colors.lightBlue,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            padding: EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Text(
                              user.displayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25.0),
                            )),
                        Container(
                            margin: EdgeInsets.only(bottom: 16.0),
                            padding: EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Text(
                              user.email,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  height: 150,
                                  width: 150,
                                  child: PieChart(
                                    PieChartData(
                                        pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                                          setState(() {
                                            final desiredTouch =
                                                pieTouchResponse.touchInput is! PointerExitEvent && pieTouchResponse.touchInput is! PointerUpEvent;
                                            if (desiredTouch && pieTouchResponse.touchedSection != null) {
                                              touchedIndex = pieTouchResponse.touchedSection.touchedSectionIndex;
                                            } else {
                                              touchedIndex = -1;
                                            }
                                          });
                                        }),
                                        borderData: FlBorderData(
                                          show: false,
                                        ),
                                        sectionsSpace: 0,
                                        centerSpaceRadius: 10,
                                        sections: showingSections()),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('I tuoi interessi:'),
                                    Indicator(
                                      color: const Color(0xff0293ee),
                                      text: grafico.keys.elementAt(grafico.length - 1),
                                      isSquare: false,
                                      size: touchedIndex == 0 ? 18 : 16,
                                      textColor: touchedIndex == 0 ? Colors.black : Colors.grey,
                                    ),
                                    grafico.length >= 2 ?
                                    Indicator(
                                      color: const Color(0xfff8b250),
                                      text: grafico.keys.elementAt(grafico.length - 2),
                                      isSquare: false,
                                      size: touchedIndex == 1 ? 18 : 16,
                                      textColor: touchedIndex == 1 ? Colors.black : Colors.grey,
                                    ) : SizedBox(
                                      height: 0,
                                    ),
                                    grafico.length >= 3
                                        ? Indicator(
                                            color: const Color(0xff845bef),
                                            text: grafico.keys.elementAt(grafico.length - 3),
                                            isSquare: false,
                                            size: touchedIndex == 2 ? 18 : 16,
                                            textColor: touchedIndex == 2 ? Colors.black : Colors.grey,
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                    grafico.length >= 4
                                        ? Indicator(
                                            color: const Color(0xff13d38e),
                                            text: grafico.keys.elementAt(grafico.length - 4),
                                            isSquare: false,
                                            size: touchedIndex == 3 ? 18 : 16,
                                            textColor: touchedIndex == 3 ? Colors.black : Colors.grey,
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20.0),
                  child: Text(
                    "Puoi cambiare le tue informazioni e poi salvarle",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  key: formkey,
                  child: Column(children: <Widget>[
                    Container(
                      child: Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xD9e3f2fd),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                'Nome utente:',
                                style: TextStyle(color: Colors.black, fontSize: 20),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                              constraints: const BoxConstraints(minWidth: double.infinity),
                              child: TextFormField(
                                controller: _nomeUtente,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: user.displayName,
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(errorText: "* Required"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xD9e3f2fd),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                'Indirizzo email:',
                                style: TextStyle(color: Colors.black, fontSize: 20),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                              constraints: const BoxConstraints(minWidth: double.infinity),
                              child: TextFormField(
                                controller: _emailUtente,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: user.email,
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(errorText: "* Required"),
                                    EmailValidator(errorText: "Enter valid email id"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
                Container(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xD9e3f2fd),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'Identificatore utente:',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(minWidth: double.infinity),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.lightBlue),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              user.uid,
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xD9e3f2fd),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'Puoi cambiare la tua password:',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                          constraints: const BoxConstraints(minWidth: double.infinity),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.lightBlue),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextButton(
                            onPressed: () {
                              _displayTextInputDialog(context);
                            },
                            child: Text(
                              "*********",
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 30.0, right: 20.0, bottom: 20.0),
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.currentUser.delete();
                              await deleteUser();
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'requires-recent-login') {
                                print('The user must reauthenticate before this operation can be executed.');
                              }
                            }
                          },
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              "Cancella account",
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 30.0, bottom: 20.0),
                          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              _signOut();
                            },
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                "Esci",
                                style: TextStyle(color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((value) => value.data().containsKey('grafico')
        ? setState(() {
            grafico = value.data()['grafico'];
          })
        : null);

    var mapEntries = grafico.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    grafico
      ..clear()
      ..addEntries(mapEntries);
    grafico.removeWhere((key, value) => value == 0);
    grafico.isEmpty ? grafico = {"demo": 50, "demo ": 25, "demo  ": 25, "demo   ": 25} : null;
    int numero = 4;
    grafico.length < 4 ? numero = grafico.length : null;

    int totale = 0;
    grafico.forEach((key, value) { totale = totale + value;});

    return List.generate(numero, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: grafico.values.elementAt(grafico.length - 1).toDouble(),
            title: ((grafico.values.elementAt(grafico.length - 1).toDouble()*100)/totale).toStringAsFixed(1),
            radius: radius,
            titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: grafico.values.elementAt(grafico.length - 2).toDouble(),
            title: ((grafico.values.elementAt(grafico.length - 2).toDouble()*100)/totale).toStringAsFixed(1),
            radius: radius,
            titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: grafico.values.elementAt(grafico.length - 3).toDouble(),
            title: ((grafico.values.elementAt(grafico.length - 3).toDouble()*100)/totale).toStringAsFixed(1),
            radius: radius,
            titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: grafico.values.elementAt(grafico.length - 4).toDouble(),
            title: ((grafico.values.elementAt(grafico.length - 4).toDouble()*100)/totale).toStringAsFixed(1),
            radius: radius,
            titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        default:
          return null;
      }
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  Future<void> deleteUser() {
    //return usersDoc.doc(user.uid).delete().then((value) => print("User Deleted")).catchError((error) => print("Failed to delete user: $error"));
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  "Verrà inviata una email dove ci sarà un link dove potrai cambiare la tua password. ATTENZIONE verrai fatto uscire dalla applicazione."),
              SizedBox(
                height: 20,
              ),
              Text(
                user.email,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: Text('CANCEL'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: Text(
                'OK',
              ),
              onPressed: () async {
                await auth.sendPasswordResetEmail(email: user.email).then((value) => auth.signOut()).catchError((error) => null);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Email inviata'),
                ));

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

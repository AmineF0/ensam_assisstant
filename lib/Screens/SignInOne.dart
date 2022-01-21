import 'package:ensam_assisstant/Tools/backgroundFetch.dart';
import 'package:flutter/material.dart';
import 'package:ensam_assisstant/Tools/browser.dart';
import 'package:ensam_assisstant/Tools/request.dart';
import 'package:ars_progress_dialog/dialog.dart';

import '../main.dart';


class SignInOne extends StatefulWidget {
  @override
  _SignInOneState createState() => _SignInOneState();
}

class _SignInOneState extends State<SignInOne> {
  bool value = false, errorVis=false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void showWidget(){
    setState(() {
      errorVis = true ;
    });
  }
  void hideWidget(){
    setState(() {
      errorVis = false ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('Assets/ENSAM-meknes-compus.jpg'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter
            )
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:0),
                  child: Center(
                    child: Text('SIGN IN',
                      style: TextStyle(
                          fontFamily: 'SFUIDisplay',
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
                  child: Container(
                    color: Color(0xfff5f5f5),
                    child: TextFormField(
                      controller: emailController,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'SFUIDisplay'
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.person_outline),
                        labelStyle: TextStyle(
                          fontSize: 15
                        )
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Color(0xfff5f5f5),
                  child: TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SFUIDisplay'
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      labelStyle: TextStyle(
                          fontSize: 15
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:20),
                  child: Center(
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value: this.value,
                                activeColor: Color(0xff0065a3),
                                checkColor: Color(0xffffffff),
                                onChanged: (bool? value) {
                                  setState(() {
                                    this.value = value!;
                                  });
                                },
                              ),
                              Text(
                                'Stay signed',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'SFUIDisplay',
                                    fontSize: 15
                                ),
                              ),
                            ],
                          ),
                        ]
                      ),
                  ),
                ),
                Visibility(
                  visible: errorVis,
                  child: Center(
                    child: Text('Something went wrong, check the credentials or try later.',
                      style: TextStyle(
                          fontFamily: 'SFUIDisplay',
                          fontSize: 13,
                          fontWeight: FontWeight.bold

                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: MaterialButton(
                    onPressed: () async {
                      hideWidget();
                      ArsProgressDialog progressDialog = ArsProgressDialog(context, blur: 2, backgroundColor: Color(0x33000000), animationDuration: Duration(milliseconds: 1));

                      progressDialog.show(); // show dialog

                      String email = emailController.text;
                      String password = passwordController.text;

                      var rs = await checkCred(email,password,value);
                      if(rs) {
                        await data.load();
                        initBgFetch();
                        Navigator.replace(context,oldRoute: ModalRoute.of(context)!,
                            newRoute: MaterialPageRoute(builder: (BuildContext context) => new Home()));
                      }
                      else showWidget();
                      progressDialog.dismiss(); //close dialog
                    },
                    child: Text('SUBMIT',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'SFUIDisplay',
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    color: Color(0xff0065a3),
                    elevation: 0,
                    minWidth: 400,
                    height: 50,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Center(
                  child: TextButton(
                    onPressed: (){forgotMDP();},
                      child: Text('Forgot your password?',
                      style: TextStyle(
                        fontFamily: 'SFUIDisplay',
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Center(
                   child: TextButton(
                     onPressed: (){signUp();},
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account?",
                              style: TextStyle(
                                fontFamily: 'SFUIDisplay',
                                color: Colors.black,
                                fontSize: 15,
                              )
                            ),
                            TextSpan(
                              text: " Sign up",
                              style: TextStyle(
                                fontFamily: 'SFUIDisplay',
                                color: Color(0xff0065a3),
                                fontSize: 15,
                              )
                            )
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
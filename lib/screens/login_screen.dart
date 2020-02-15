import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_gram_beta/screens/complete_reg_screen.dart';
import 'package:home_gram_beta/screens/home_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Registration_Screen.dart';
import 'package:home_gram_beta/enums/connectivity_status.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({this.auth});
  final BaseAuth auth;
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email;
  String _password;
  int phoneNo;
  bool isLoading = false;
  bool iconToggle = false;

  final formKey = GlobalKey<FormState>();
  SharedPreferences prefs;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      print('The email is $_email, and password is $_password');
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit(BuildContext context) async {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    prefs = await SharedPreferences.getInstance();
    if (connectionStatus == ConnectivityStatus.HasConnection) {
      if (validateAndSave()) {
        try {
          setState(() {
            isLoading = true;
          });
          final result =
              await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('userId: $result');
          if (result.user != null) {
            setState(() {
              isLoading = false;
            });
            String photoUrlFromSignIn = prefs.getString('photoUrlFromSignIn');
            String nameFromSignIn = prefs.getString('nameFromSignIn');
            int phoneNoFromSignIn = prefs.getInt('phoneNoFromSignIn');
            String roleFromSignIn = prefs.getString('roleFromSignIn');

            await prefs.setString('uid', result.user.uid);
            await prefs.setString('email', result.user.email);
            await prefs.setString('photoUrl',
                result.user.photoUrl == null ? '' : photoUrlFromSignIn);
            await prefs.setString('displayName', nameFromSignIn);
            await prefs.setString('role', roleFromSignIn);
            await prefs.setInt('phoneNo', phoneNoFromSignIn);

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomeScreen(
                      auth: widget.auth,
                    )));
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: e.toString(),
              gravity: ToastGravity.TOP,
              toastLength: Toast.LENGTH_LONG);
        }
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text('You appear to be offline, Try connecting to a network!')));
    }
  }

  signInWithGoogle(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    try {
      final result = await widget.auth.googleSignUp();
      if (result.user != null) {
        setState(() {
          isLoading = false;
        });
        await prefs.setString('uid', result.user.uid);
        await prefs.setString('email', result.user.email);
        print(result.user.email);
        await prefs.setString('photoUrl',
            result.user.photoUrl == null ? '' : result.user.photoUrl);
        await prefs.setString('displayName', result.user.displayName);

        Fluttertoast.showToast(
            msg: 'Sign In Successful',
            gravity: ToastGravity.TOP,
            toastLength: Toast.LENGTH_LONG);
        prefs.getString('obtainedRole') == null
            ? Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CompleteRegScreen(
                      auth: Auth(),
                    )))
            : Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomeScreen(
                      auth: Auth(),
                    )));
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: e.toString(),
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow.shade50,
        body: Builder(builder: (context) {
          return Center(
            child: SingleChildScrollView(
                child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                            child: Icon(
                          Icons.face,
                          color: themeColor,
                          size: 60.0,
                        )),
                        SizedBox(height: 50.0),
                        Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Email can\'t be empty';
                                  } else if (!value.contains('@')) {
                                    return 'Enter a valid Email Address';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  setState(() {
                                    _email = value;
                                  });
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  suffixIcon:
                                      Icon(MaterialCommunityIcons.email),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
                                  hintText: 'someone@something.com',
                                  hintStyle:
                                      TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Password can\'t be empty';
                                    } else if (value.length < 8) {
                                      return 'Password too short';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    setState(() {
                                      _password = value;
                                    });
                                  },
                                  obscureText: iconToggle ? false : true,
                                  decoration: InputDecoration(
                                    suffixIcon: iconToggle == false
                                        ? IconButton(
                                            icon: Icon(
                                                MaterialCommunityIcons.eye_off),
                                            onPressed: () {
                                              setState(() {
                                                iconToggle = true;
                                              });
                                            },
                                          )
                                        : IconButton(
                                            icon: Icon(
                                                MaterialCommunityIcons.eye),
                                            onPressed: () {
                                              setState(() {
                                                iconToggle = false;
                                              });
                                            },
                                          ),
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0),
                                    hintText: '**********',
                                    hintStyle:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  )),
                              SizedBox(
                                height: 20.0,
                              ),
                              ButtonTheme(
                                height: 50,
                                child: RaisedButton(
                                  onPressed: () => validateAndSubmit(context),
                                  textColor: Colors.black54,
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0),
                                  ),
                                  color: themeColor,
                                  disabledColor: Colors.yellow.shade100,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 1.0,
                              width: 130.0,
                              color: Colors.black26,
                            ),
                            SizedBox(
                              width: 3.0,
                            ),
                            Text(
                              'OR',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 3.0,
                            ),
                            Container(
                              height: 1.0,
                              width: 130.0,
                              color: Colors.black26,
                            )
                          ],
                        ),
                        ButtonTheme(
                          height: 50,
                          child: RaisedButton(
                            onPressed: () => signInWithGoogle(context),
                            textColor: Colors.white,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(MaterialCommunityIcons.google_plus),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'LOG IN WITH GOOGLE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0),
                                  ),
                                ]),
                            color: Color(0xfff18973),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Dont have an Account?',
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.black38),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RegistrationScreen(
                                          auth: widget.auth,
                                        )));
                              },
                              child: Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                    color: themeColor,
                                    fontWeight: FontWeight.w900),
                              ),
                            )
                          ],
                        )
                      ]),
                ),
                Positioned(
                  child: isLoading
                      ? Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                          ),
                          color: Colors.white.withOpacity(0.8),
                        )
                      : Container(),
                )
              ],
            )),
          );
        }));
  }
}

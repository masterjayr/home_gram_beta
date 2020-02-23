import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_gram_beta/screens/complete_reg_screen.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_gram_beta/enums/connectivity_status.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({this.auth});
  final BaseAuth auth;
  @override
  _RegistrationScreenState createState() =>
      _RegistrationScreenState(auth: auth);
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  _RegistrationScreenState({this.auth});
  final BaseAuth auth;
  String _email;
  String _password;
  int _radioValue = -1;
  bool iconToggle = false;
  String role;

  bool isLoading = false;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      print('The email is $_email, and password is $_password, role is $role');
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
        if (role != null) {
          try {
            setState(() {
              isLoading = true;
            });
            final result = await widget.auth
                .createUserWithEmailAndPassword(_email, _password, role);
            print('userId: $result');
            if (result.user != null) {
              setState(() {
                isLoading = false;
              });
              String roleFromSignIn = prefs.getString('roleFromSignIn');
              await prefs.setString('uid', result.user.uid);
              await prefs.setString('email', result.user.email);
              await prefs.setString('role', roleFromSignIn);

              Fluttertoast.showToast(
                  msg: 'Sign In Successful',
                  gravity: ToastGravity.TOP,
                  toastLength: Toast.LENGTH_LONG);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CompleteRegScreen(
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
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
              content:
                  Text('Choose a role please :) Either landlord or tenant')));
        }
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text('You appear to be offline, Try connecting to a network!')));
    }
  }

  _handleRadioValueChange(value) {
    setState(() {
      _radioValue = value;
      print(role);
      switch (_radioValue) {
        case -1:
          role = null;
          break;
        case 0:
          role = 'landlord';
          break;
        case 1:
          role = 'tenant';
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print(role);
  }

  final formKey = GlobalKey<FormState>();
  SharedPreferences prefs;

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
                        child: Image.asset('assets/home_gram_icon.png'), height: 90,),
                    // SizedBox(height: 10.0),
                    // Text(
                    //   "LET'S GET STARTED",
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold, fontSize: 15.0),
                    //   textAlign: TextAlign.center,
                    // ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
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
                            decoration: InputDecoration(
                              suffixIcon: Icon(MaterialCommunityIcons.email),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15.0),
                              hintText: 'someone@something.com',
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
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
                                        icon: Icon(MaterialCommunityIcons.eye),
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
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Radio(
                                value: 0,
                                groupValue: _radioValue,
                                onChanged: _handleRadioValueChange,
                                activeColor: themeColor,
                              ),
                              Text(
                                'LandLord',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Radio(
                                value: 1,
                                groupValue: _radioValue,
                                onChanged: _handleRadioValueChange,
                                activeColor: themeColor,
                              ),
                              Text(
                                'Tenant',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ButtonTheme(
                      height: 50,
                      child: RaisedButton(
                        onPressed: () => validateAndSubmit(context),
                        textColor: Colors.white,
                        child: Text(
                          'PROCEED',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15.0),
                        ),
                        color: primaryColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Already Have an Account?',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.black38),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                      auth: widget.auth,
                                    )));
                          },
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                                color: themeColor, fontWeight: FontWeight.w900),
                          ),
                        )
                      ],
                    )
                  ],
                ),
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
          )));
        }));
  }
}

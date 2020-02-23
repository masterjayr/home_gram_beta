import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_gram_beta/screens/home_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_gram_beta/enums/connectivity_status.dart';
import 'package:provider/provider.dart';

class CompleteRegScreen extends StatefulWidget {
  CompleteRegScreen({this.email, this.role, this.auth});
  final String email;
  final String role;
  final BaseAuth auth;
  @override
  _CompleteRegScreenState createState() => _CompleteRegScreenState();
}

class _CompleteRegScreenState extends State<CompleteRegScreen> {
  File _image;
  int phoneNum;
  String name;
  bool isLoading = false;
  SharedPreferences prefs;
  String obtainedRole;
  int _radioValue = -1;
  String determinantRole;
  String roleFromSignUp;

  final formKey = GlobalKey<FormState>();

  _handleRadioValueChange(value) {
    setState(() {
      _radioValue = value;
      print(determinantRole);
      switch (_radioValue) {
        case -1:
          determinantRole = null;
          break;
        case 0:
          determinantRole = 'landlord';
          break;
        case 1:
          determinantRole = 'tenant';
          break;
      }
    });
  }

  void validateAndSubmit(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == ConnectivityStatus.HasConnection) {
      if (validateAndSave()) {
        if (determinantRole != null && obtainedRole != null) {
          try {
            setState(() {
              isLoading = true;
            });
            final result = await widget.auth
                .completeReg(name, phoneNum, _image, determinantRole);
            print('userId: $result');
            if (result != null) {
              setState(() {
                isLoading = false;
              });
              String photoUrlFromSignIn = prefs.getString('photoUrlFromSignIn');
              String nameFromSignIn = prefs.getString('nameFromSignIn');
              int phoneNoFromSignIn = prefs.getInt('phoneNoFromSignIn');

              await prefs.setString('photoUrl', photoUrlFromSignIn);
              await prefs.setString('displayName', nameFromSignIn);
              await prefs.setInt('phoneNo', phoneNoFromSignIn);

              print(
                  'photoUrl from shared preferences ${prefs.getString('photoUrl')}');
              print(
                  'name from shared preferences ${prefs.getString('displayName')}');
              print(
                  'phoneNo from shared preferences ${prefs.getInt('phoneNo')}');

              Fluttertoast.showToast(
                  msg: 'Sign In Successful',
                  gravity: ToastGravity.TOP,
                  toastLength: Toast.LENGTH_LONG);
              Navigator.of(context).push(MaterialPageRoute(
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

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      print(
          'The email is ${widget.email},name is $name, role is ${widget.role}');
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future getImage(BuildContext context) async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = image;
      print('Image pathe: $_image');
    });
  }

  _getInitialDetails() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      obtainedRole = prefs.getString('obtainedRole');
    });
  }

  @override
  void initState() {
    super.initState();
    _getInitialDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow.shade50,
        body: Builder(builder: (context) {
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FittedBox(
                      child: Text(
                        'You are only a step away from completing your registration\nChoose a profile picture and provide the required information to continue',
                        style: TextStyle(
                            fontSize: 70,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProfileAvatar(
                          '',
                          child: _image == null
                              ? Image.asset('assets/emptypic.png',
                                  fit: BoxFit.cover)
                              : Image.file(_image, fit: BoxFit.cover),
                          borderColor: Colors.grey,
                          borderWidth: 5,
                          elevation: 2,
                          radius: 80,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt),
                            iconSize: 30,
                            onPressed: () {
                              getImage(context);
                            },
                          ),
                        )
                      ],
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            initialValue: prefs.getString('displayName'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Name can\'t be empty';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              setState(() {
                                name = value;
                              });
                            },
                            decoration: InputDecoration(
                              suffixIcon: Icon(Fontisto.person),
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15.0),
                              hintText: 'Achukwuleke Kosiso',
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Phone No can\'t be empty';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              setState(() {
                                phoneNum = num.tryParse(value);
                              });
                            },
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              suffixIcon: Icon(MaterialCommunityIcons.phone),
                              labelText: 'Phone No',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15.0),
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          obtainedRole == null
                              ? Row(
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
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ButtonTheme(
                      height: 40,
                      child: RaisedButton(
                        onPressed: () => validateAndSubmit(context),
                        textColor: Colors.black54,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15.0),
                        ),
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}

import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_gram_beta/services/user.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_gram_beta/widgets/network_sensitivity.dart';
import 'package:home_gram_beta/widgets/app_bar_widget.dart';
class ProfileScreen extends StatefulWidget {
  ProfileScreen({this.user});
  final User user;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File _image;
  String downloadUrl;
  SharedPreferences prefs;
  String photoUrl;
  String name;
  String phoneNo;
  String role;
  String email;
  bool isLoading = false;
  GlobalKey<ScaffoldState> _scaffoldKey;

  void getInitDetail() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('displayName');
      phoneNo = prefs.getInt('phoneNo').toString();
      role = prefs.getString('role');
      photoUrl = prefs.getString('photoUrl');
      email = prefs.getString('email');
    });
  }

  Future uploadPic1(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('photoUrl', null);
    String filePathName = basename(_image.path);
    try {
      String url = await widget.user.uploadPicture(filePathName, _image);
      if (url != null) {
        setState(() {
          downloadUrl = url;
          isLoading = false;
        });
        await prefs.setString('photoUrl', downloadUrl);
        print('Obtained download Url: $downloadUrl');
        Fluttertoast.showToast(
            msg: 'Upload Successful',
            gravity: ToastGravity.TOP,
            toastLength: Toast.LENGTH_SHORT);
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'Upload Unsuccessful',
            gravity: ToastGravity.TOP,
            toastLength: Toast.LENGTH_LONG);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      String err = e.toString();
      Fluttertoast.showToast(
          msg: 'Upload Unsuccessful, $err',
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_LONG);
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
    uploadPic1(context);
  }

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    getInitDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.yellow.shade50,
        appBar: MyAppBar.customAppBar(_scaffoldKey, 'Profile'),
        body: NetworkSensitive(
                  child: Stack(
            children: <Widget>[
              Builder(
                builder: (context) => Container(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Align(
                                alignment: Alignment.center,
                                child: photoUrl == null
                                    ? CircularProfileAvatar(
                                        '',
                                        child: Image.asset('assets/emptypic.png', fit: BoxFit.cover,),
                                        borderColor: Colors.grey,
                                        borderWidth: 5,
                                        elevation: 2,
                                        radius: 120,
                                      )
                                    : CircularProfileAvatar(
                                        '',
                                        child: Image.network(photoUrl,
                                            fit: BoxFit.cover),
                                        borderColor: Colors.grey,
                                        borderWidth: 5,
                                        elevation: 2,
                                        radius: 120,
                                      )),
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
                        SizedBox(
                          height: 20,
                        ),

                        //! Rows
                        //First Row
                        customizedRow('Name', Fontisto.person),
                        Divider(),
                        SizedBox(
                          height: 20,
                        ),
                        //Next Row
                        customizedRow('Role', FontAwesome.user),
                        //Next Row
                        Divider(),
                        SizedBox(
                          height: 20,
                        ),
                        customizedRow('Email', MaterialCommunityIcons.email),
                        Divider(),
                        // Next Row
                        SizedBox(
                          height: 20,
                        ),
                        customizedRow('Phone No', Fontisto.phone),
                        Divider(),
                        SizedBox(
                          height: 20,
                        ),
                        //Submit and Cancel Buttons
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                child: isLoading
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      )
                    : Container(),
              )
            ],
          ),
        ));
  }

  //customized Row
  Row customizedRow(String detail, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              color: themeColor,
            ),
            Padding(
              padding: EdgeInsets.only(left: 40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$detail',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: buildText(detail))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Icon(
              Icons.edit,
              color: primaryColor,
            ),
          ),
        )
      ],
    );
  }

  buildText(String detail) {
    switch (detail) {
      case 'Name':
        return Text(
          '$name',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 18,
          ),
        );
        break;
      case 'Email':
        return Text(
          '$email',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 18,
          ),
        );
        break;
      case 'Role':
        return Text(
          '$role',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 18,
          ),
        );
        break;
      case 'Phone No':
        return Text(
          '$phoneNo',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 18,
          ),
        );
        break;
    }
  }
}

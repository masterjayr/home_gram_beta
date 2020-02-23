import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:home_gram_beta/enums/connectivity_status.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:home_gram_beta/widgets/drawer_tile_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const kGoogleApiKey = "AIzaSyBOpNS-z4fmAzb4XENYk15I2Ed_hpgPIlE";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class SearchHomeScreen extends StatefulWidget {
  final BaseAuth auth = Auth();
  @override
  _SearchHomeScreenState createState() => _SearchHomeScreenState();
}

class _SearchHomeScreenState extends State<SearchHomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  SharedPreferences prefs;
  TextEditingController _addressController = new TextEditingController();
  LatLng cords;
  bool localIsLoading = false;
  bool isLoading = false;
  String location;
  String noOfRooms;
  final formKey = GlobalKey<FormState>();
  var hestimate;
  bool textIsLoading = false;
  String _currentSelectedValue;

  var _noOfRooms = [
    "1",
    "2",
    "3",
  ];

  void runHestimate(BuildContext context) async {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == ConnectivityStatus.HasConnection) {
      if (location != null && _currentSelectedValue != null) {
        print('location: $location');
        print('noOfRooms: $_currentSelectedValue');
        try {
          setState(() {
            localIsLoading = true;
          });
          var url = 'https://home-gram-api.herokuapp.com/predict_home_price';
          var response = await http.post(url,
              body: {'location': location, 'noOfRooms': _currentSelectedValue});
          if (response.statusCode == 200) {
            setState(() {
              localIsLoading = false;
              textIsLoading = true;
              print('Response status: ${response.statusCode}');
              print('Response body: ${response.body}');
              var data = json.decode(response.body);
              print(data.runtimeType);
              hestimate = data['estimated_price'];
            });
          }
        } catch (e) {
          print('${e.toString()}');
        }
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Please Enter Address and Number of Rooms')));
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              'You appear to be offline, Please check your connection :)')));
    }
  }

  getAutoCompletion() async {
    try {
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApiKey,
          components: [Component(Component.country, "ng")]);
      displayPrediction(p);
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'An error Occured $e',
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> displayPrediction(Prediction p) async {
    try {
      if (p != null) {
        PlacesDetailsResponse detail =
            await _places.getDetailsByPlaceId(p.placeId);
        var placeId = p.placeId;
        double lat = detail.result.geometry.location.lat;
        double lng = detail.result.geometry.location.lng;
        print(lat);
        print(lng);
        setState(() {
          cords = LatLng(lat, lng);
        });
        List<Address> address =
            await Geocoder.local.findAddressesFromQuery(p.description);
        _addressController.text = p.description;
        setState(() {
          location = p.description;
        });
        print(address);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void handleSignOut(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('photoUrl');
    prefs.remove('displayName');
    prefs.remove('role');
    prefs.remove('phoneNo');
    Fluttertoast.showToast(
        msg: 'Logging Out',
        gravity: ToastGravity.TOP,
        toastLength: Toast.LENGTH_SHORT);
    await widget.auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen(auth: widget.auth)),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: customizedDrawer(context),
      body: Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                leading: InkWell(
                  onTap: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 3),
                    child: Container(
                      width: 30,
                      height: 25,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        MaterialCommunityIcons.menu,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/house_image.jpg',
                    fit: BoxFit.cover,
                  ),
                  centerTitle: true,
                  title: FittedBox(
                    child: Text(
                      'Search',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  collapseMode: CollapseMode.parallax,
                ),
                pinned: true,
                floating: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Please Enter the following Preferred house Requirements ',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          customTextAreas('Address', Fontisto.map_marker,
                              getAutoCompletion, _addressController),
                          SizedBox(
                            height: 15,
                          ),
                          FormField<String>(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Number of rooms can\'t be empty';
                              } else {
                                return null;
                              }
                            },
                            builder: (FormFieldState<String> state) {
                              return InputDecorator(
                                decoration: InputDecoration(
                                    labelText: 'Number of rooms',
                                    errorStyle: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16.0),
                                    hintText: 'Select Number of Rooms',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0))),
                                isEmpty: _currentSelectedValue == '',
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _currentSelectedValue,
                                    isDense: true,
                                    onChanged: (String newValue) {
                                      setState(() {
                                        _currentSelectedValue = newValue;
                                        state.didChange(newValue);
                                      });
                                    },
                                    items: _noOfRooms.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Click the bottom below to get the Hestimate (House estimated price)',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ButtonTheme(
                      height: 50,
                      child: RaisedButton(
                        onPressed: () {
                          runHestimate(context);
                        },
                        textColor: Colors.white,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Fontisto.dollar),
                              SizedBox(
                                width: 5,
                              ),
                              localIsLoading
                                  ? Text(
                                      'Running...',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0),
                                    )
                                  : Text(
                                      'Run Hestimate',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0),
                                    ),
                              SizedBox(
                                width: 15,
                              ),
                              localIsLoading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ))
                                  : Container()
                            ]),
                        color: Color(0xfff18973),
                      ),
                    ),
                  ),
                  textIsLoading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Hestimate price: N$hestimate',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ButtonTheme(
                      height: 50,
                      child: RaisedButton(
                        onPressed: () => {},
                        textColor: Colors.blueGrey,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Fontisto.search),
                              SizedBox(
                                width: 5,
                              ),
                              localIsLoading
                                  ? Text(
                                      'Searching...',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0),
                                    )
                                  : Text(
                                      'Search Homegram',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0),
                                    ),
                              SizedBox(
                                width: 15,
                              ),
                              localIsLoading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blueGrey,
                                    ))
                                  : Container()
                            ]),
                        color: themeColor,
                      ),
                    ),
                  )
                ]),
              )
            ],
          );
        },
      ),
    );
  }

  Widget customTextAreas(String labelText, IconData icon, Function onPressed,
      TextEditingController controller) {
    return TextFormField(
        controller: controller,
        onTap: onPressed,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value.isEmpty) {
            return 'Address can\'t be empty';
          } else {
            return null;
          }
        },
        onSaved: (value) {
          setState(() {
            // _password = value;
          });
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(width: 1.0)),
          suffixIcon: Icon(icon),
          labelText: '$labelText',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          hintStyle: TextStyle(fontStyle: FontStyle.italic),
        ));
  }

  Drawer customizedDrawer(BuildContext context) {
    return Drawer(
        child: ListView(children: <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text(''),
        accountEmail: Text(''),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.brown,
          child: Text('E'),
        ),
        decoration: BoxDecoration(color: themeColor),
      ),
      DrawerTiles('Home', MdiIcons.home, false, () {
        Navigator.of(context).pushReplacementNamed('/home');
      }),
      DrawerTiles('Profile', MdiIcons.faceProfile, false, () {
        Navigator.of(context).pushReplacementNamed('/profile');
      }),
      DrawerTiles('Add Home', Fontisto.plus_a, false, () {
        Navigator.of(context).pushReplacementNamed('/addHome');
      }),
      DrawerTiles('Manage Homes', Fontisto.nursing_home, false, () {
        Navigator.of(context).pushReplacementNamed('/myHomes');
      }),
      DrawerTiles('About', MdiIcons.details, false, () {
        Navigator.of(context).pushReplacementNamed('/about');
      }),
      DrawerTiles('Settings', MdiIcons.settings, false, () {
        Navigator.of(context).pushReplacementNamed('/settings');
      }),
      DrawerTiles('Logout', MdiIcons.exitToApp, false, () {
        handleSignOut(context);
      }),
    ]));
  }
}

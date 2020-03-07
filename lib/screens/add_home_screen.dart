import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/services/user.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:home_gram_beta/widgets/drawer_tile_widget.dart';
import 'package:home_gram_beta/widgets/loader.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:home_gram_beta/enums/connectivity_status.dart';
import 'package:provider/provider.dart';
import 'package:home_gram_beta/widgets/app_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kGoogleApiKey = "AIzaSyBOpNS-z4fmAzb4XENYk15I2Ed_hpgPIlE";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);


class AddHomeScreen extends StatefulWidget {
  AddHomeScreen({this.user});
  final User user;
  final BaseAuth auth = Auth();

  @override
  _AddHomeScreenState createState() => _AddHomeScreenState();
}

class _AddHomeScreenState extends State<AddHomeScreen> {
  TextEditingController _addressController = new TextEditingController();
  List<Asset> images = List<Asset>();
  String error = 'No Error Detected';
  List imageData;
  bool isLoading = false;
  LatLng cords;
  GlobalKey<ScaffoldState> _scaffoldKey;
  SharedPreferences prefs;
  String email;
  String displayName;
  String _currentValue;
  String roleForTab;
  var _noOfRooms = [
    "1",
    "2",
    "3",
  ];

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _getInitialDetails();
  }

  buildGridView() {
    if (images.length != 0) {
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          );
        }),
      );
    } else {
      return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(color: greyColor2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('No Image selected. Click the button Above to select Images')
          ],
        ),
      );
    }
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Home Rental Pictures",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;
    setState(() {
      images = resultList;
      error = error;
    });
  }

  String address;
  int noOfRooms;
  int price;

  final formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate() && images.length != 0) {
      print(
          'The address is $address, and no of Rooms is $noOfRooms, and price is $price');
      form.save();
      return true;
    } else {
      Fluttertoast.showToast(
          msg:
              'No Image Selected. Please Click the button Above to select Images.',
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_LONG);
      return false;
    }
  }

  _getInitialDetails() async {
    prefs =await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      displayName = prefs.getString('displayName');  
      roleForTab = prefs.getString('role');
    });
  }

  validateAndSubmit(BuildContext context) async {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    setState(() {
      isLoading = true;
    });
    if (validateAndSave() && connectionStatus == ConnectivityStatus.HasConnection) {
      setState(() {
        noOfRooms = num.tryParse(_currentValue);
      });
      try {
        List<StorageTaskSnapshot> taskSnapshot = await widget.user
            .postHouseDetail(address, noOfRooms, price, images, cords);
        if (taskSnapshot.length != 0) {
          setState(() {
            isLoading = false;
            Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/myHomes');
          });
          Fluttertoast.showToast(
              msg: 'Home Rental Successfully Posted',
              gravity: ToastGravity.TOP,
              toastLength: Toast.LENGTH_SHORT);
        } else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: 'Action Unsuccessful, Try Again',
              gravity: ToastGravity.TOP,
              toastLength: Toast.LENGTH_LONG);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'An error Occured $e',
            gravity: ToastGravity.TOP,
            toastLength: Toast.LENGTH_LONG);
      }
    }else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text('You appear to be offline, Try connecting to a network!')));

    }
  }

  getAutoCompletion() async {
    try{
      Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      components: [Component(Component.country, "ng")]
    );
    displayPrediction(p);
    }catch(e){
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
        print(address);
      }
    } catch (e) {
      print(e.toString());
    }
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
        backgroundColor: Colors.yellow.shade50,
        appBar: MyAppBar.customAppBar(_scaffoldKey, 'AddHome', context),
        drawer: customizedDrawer(context),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: MaterialButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Select Images',
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Fontisto.camera, color: primaryColor),
                      ],
                    ),
                    color: themeColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    height: 40,
                    onPressed: loadAssets,
                  ),
                ),
                Expanded(
                  child: buildGridView(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'House Address can\'t be empty';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  address = value;
                                });
                              },
                              controller: _addressController,
                              decoration: InputDecoration(
                                suffixIcon:
                                    Icon(MaterialCommunityIcons.map_marker),
                                labelText: 'Home Address',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0),
                                hintStyle:
                                    TextStyle(fontStyle: FontStyle.italic),
                              ),
                              onTap: () {
                                getAutoCompletion();
                              },
                              
                            ),
                            SizedBox(
                              height: 20,
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
                                  isEmpty: _currentValue == '',
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _currentValue,
                                      isDense: true,
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _currentValue = newValue;
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
                            // TextFormField(
                            //   validator: (value) {
                            //     if (value.isEmpty) {
                            //       return 'Number of Rooms can\'t be empty';
                            //     }
                            //     return null;
                            //   },
                            //   onSaved: (value) {
                            //     setState(() {
                            //       noOfRooms = num.tryParse(value);
                            //     });
                            //   },
                            //   keyboardType: TextInputType.number,
                            //   inputFormatters: <TextInputFormatter>[
                            //     WhitelistingTextInputFormatter.digitsOnly
                            //   ],
                            //   decoration: InputDecoration(
                            //     suffixIcon: Icon(Icons.format_list_numbered),
                            //     labelText: 'No of Rooms',
                            //     labelStyle: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 15.0),
                            //     hintStyle:
                            //         TextStyle(fontStyle: FontStyle.italic),
                            //   ),
                            // ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Price can\'t be empty';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  price = num.tryParse(value);
                                });
                              },
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: <TextInputFormatter>[
                                BlacklistingTextInputFormatter(
                                    new RegExp('[\\-|\\ ]'))
                              ],
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.monetization_on),
                                labelText: 'Price',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0),
                                hintStyle:
                                    TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            MaterialButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Post Home Rental',
                                    style: TextStyle(color: greyColor2),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Fontisto.plus_a,
                                    color: greyColor2,
                                  )
                                ],
                              ),
                              color: primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
                              height: 40,
                              onPressed: () => validateAndSubmit(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              child: isLoading
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Loader(),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        ));
  }

  Drawer customizedDrawer(BuildContext context) {
    
    return Drawer(
        child: ListView(children: <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text('$displayName'),
        accountEmail: Text('$email'),
        currentAccountPicture: CircleAvatar(
          backgroundImage: NetworkImage('${prefs.getString('photoUrl')}'),
        ),
        decoration: BoxDecoration(color: themeColor),
      ),
      DrawerTiles('Home', MdiIcons.home, false, () {
        Navigator.of(context).pushReplacementNamed('/home');
      }),
      DrawerTiles('Profile', MdiIcons.faceProfile, false, () {
        Navigator.of(context).pushReplacementNamed('/profile');
      }),
      DrawerTiles('Search Home', MdiIcons.searchWeb, false, () {
        Navigator.of(context).pushReplacementNamed('/searchHome');
      }),
      roleForTab == 'landlord' ?DrawerTiles('Add Home', Fontisto.plus_a, false, () {
        Navigator.of(context).pushReplacementNamed('/addHome');
      }) : Container(),
      roleForTab == 'landlord' ? DrawerTiles('Manage Homes', Fontisto.nursing_home, false, () {
        Navigator.of(context).pushReplacementNamed('/myHomes');
      }) : Container(),
      
      DrawerTiles('About', Icons.description, false, () {
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

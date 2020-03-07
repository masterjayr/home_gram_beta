import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/services/user.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:home_gram_beta/widgets/drawer_tile_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomeScreen extends StatefulWidget {
  final UserActivity user = UserActivity();
  final Auth auth = Auth();
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  List<DocumentSnapshot> allMyHomes = List<DocumentSnapshot>();
  GlobalKey<ScaffoldState> _scaffoldKey;
  SharedPreferences prefs;
  String roleForTab;

  _getInitialDetails() async {
    try {
      prefs = await SharedPreferences.getInstance();
      roleForTab = prefs.getString('role');
      List<DocumentSnapshot> homes = await widget.user.getAllUserHomes();
      if (homes != null) {
        setState(() {
          allMyHomes = homes;
        });
      } else {
        Fluttertoast.showToast(msg: 'There was an error!');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
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
  void initState() {
    super.initState();
    _getInitialDetails();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: customizedDrawer(context),
        appBar: AppBar(
          title: Text('Manage My Homes'),
        ),
        body: allMyHomes.length != 0
            ? ListView.builder(
                itemCount: allMyHomes.length,
                itemBuilder: (context, index) {
                  return allHomes(context, allMyHomes[index].data);
                },
              )
            : Container(
                child: Center(
                  child: Text('You don\'t have any Homes'),
                ),
              ));
  }

  Widget _imageCarousel(context, List<NetworkImage> carouselImages) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Carousel(
        boxFit: BoxFit.cover,
        images: carouselImages,
        autoplay: false,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(microseconds: 1000),
        dotSize: 6,
        indicatorBgPadding: 2,
      ),
    );
  }

  Widget allHomes(BuildContext context, Map<String, dynamic> aHome) {
    List<NetworkImage> images = List<NetworkImage>();
    for (int i = 0; i < aHome['uploadedImages'].length; i++) {
      setState(() {
        images.add(NetworkImage(aHome['uploadedImages'][i]));
      });
    }
    return Column(
      children: <Widget>[
        _imageCarousel(context, images),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'N${aHome['price'].toString()}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black),
            ),
            Icon(
              MaterialCommunityIcons.share,
              color: primaryColor,
            )
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'N${aHome['address'].toString()}',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.blueGrey),
              ),
              // ButtonTheme(
              //   child: OutlineButton(
              //     child: Text('Check Availability'),
              //     onPressed: () {
              //       Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomeDetailScreen(house: aHome,)));
              //     },
              //     color: themeColor,

              //   ),
              // )
            ])
      ],
    );
  }

  Drawer customizedDrawer(BuildContext context) {
    return Drawer(
        child: ListView(children: <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text('${prefs.getString('displayName')}'),
        accountEmail: Text('${prefs.getString('email')}'),
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
      roleForTab == 'landlord'
          ? DrawerTiles('Add Home', Fontisto.plus_a, false, () {
              Navigator.of(context).pushReplacementNamed('/addHome');
            })
          : Container(),
      roleForTab == 'landlord'
          ? DrawerTiles('Manage Homes', Fontisto.nursing_home, false, () {
              Navigator.of(context).pushReplacementNamed('/myHomes');
            })
          : Container(),
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

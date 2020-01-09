import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_gram_beta/screens/Registration_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<AuthResult> createUserWithEmailAndPassword(String email, String password, String name, int phoneNo, String role);
  Future<String> currentUser();
  Future<Null> signOut();
  Future<AuthResult> googleSignUp();
}

class Auth implements BaseAuth {
  SharedPreferences prefs;
  final fbInstance = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Stream<String> get onAuthStateChanged {
    return fbInstance.onAuthStateChanged.map((user)=> user?.uid);
  }

  //! Base Auth Implementations
  // implementing signIn
  @override
  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
          AuthResult result = await fbInstance.signInWithEmailAndPassword(
          email: email, password: password);
          final QuerySnapshot snap = await Firestore.instance.collection('users').where('uid', isEqualTo: result.user.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = snap.documents;
        for(int i =0; i<documents.length; i++){
          print(documents[i]);
        }
        if(documents.length !=0){
          prefs = await SharedPreferences.getInstance();
          await prefs.setString('photoUrlFromSignIn', documents[0]['photoUrl']);
          await prefs.setString('nameFromSignIn', documents[0]['displayName']);
          await prefs.setInt('phoneNoFromSignIn', documents[0]['phoneNo']);
          await prefs.setString('roleFromSignIn', documents[0]['role']);

        }
        return result;
  }

  // implementing signUp
  Future<AuthResult> createUserWithEmailAndPassword(
      String email, String password, String name, int phoneNo, String role) async {
      AuthResult result = await fbInstance.createUserWithEmailAndPassword(
        email: email, password: password);
        await Firestore.instance.collection('users').document(result.user.uid).setData({
            'email': result.user.email,
            'uid': result.user.uid,
            'displayName' : name,
            'photoUrl' : null,
            'phoneNo' : phoneNo,
            'role' : role
          });
        final QuerySnapshot snap = await Firestore.instance.collection('users').where('id', isEqualTo: result.user.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = snap.documents;
        if(documents.length !=0){
          prefs = await SharedPreferences.getInstance();
          await prefs.setString('photoUrlFromSignIn', documents[0]['photoUrl']);
          await prefs.setString('nameFromSignIn', documents[0]['displayName']);
        }
        return result;
  }

  Future<String> currentUser() async{
    FirebaseUser user = await fbInstance.currentUser();
    return user.uid;
  }

  Future<AuthResult> googleSignUp() async {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      AuthResult authResult = await fbInstance.signInWithCredential(credential);

      if(authResult.user != null){
        final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: authResult.user.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if(documents.length == 0){
          Firestore.instance.collection('users').document(authResult.user.uid).setData({
            'email': authResult.user.email,
            'uid' : authResult.user.uid,
            'photoUrl': authResult.user.photoUrl,
            'displayname' : authResult.user.displayName
          });
        }
      }
      print('authResult uid $authResult.user.uid');
      return authResult;
  }

  Future<Null> signOut() async {
      await fbInstance.signOut();
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
  }
}

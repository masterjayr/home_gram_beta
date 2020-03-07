import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<AuthResult> createUserWithEmailAndPassword(
      String email, String password, String role);
  Future<DocumentSnapshot> completeReg(String name, int phoneNo, [File profilePic,
      String role]);
  Future<String> currentUser();
  Future<Null> signOut();
  Future<AuthResult> googleSignUp();
}

class Auth implements BaseAuth {
  SharedPreferences prefs;
  final fbInstance = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final firebaseStorageRef = FirebaseStorage.instance;
  final firestoreRef = Firestore.instance;
  String defaultPicture = 'https://firebasestorage.googleapis.com/v0/b/homegrambeta.appspot.com/o/defaultPicture%2Femptypic.png?alt=media&token=4828ce56-9216-48a5-bee9-1e61be7c83a4';
  @override
  Stream<String> get onAuthStateChanged {
    return fbInstance.onAuthStateChanged.map((user) => user?.uid);
  }

  //! Base Auth Implementations
  // implementing signIn
  @override
  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
    AuthResult result = await fbInstance.signInWithEmailAndPassword(
        email: email, password: password);
    final QuerySnapshot snap = await Firestore.instance
        .collection('users')
        .where('uid', isEqualTo: result.user.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = snap.documents;
    for (int i = 0; i < documents.length; i++) {
      print(documents[i]);
    }
    if (documents.length != 0) {
      prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'photoUrlFromSignIn', documents[0].data['photoUrl']);
      await prefs.setString('nameFromSignIn', documents[0].data['displayName']);
      await prefs.setInt('phoneNoFromSignIn', documents[0].data['phoneNo']);
      await prefs.setString('roleFromSignIn', documents[0].data['role']);
    }
    return result;
  }

  // implementing signUp
  Future<AuthResult> createUserWithEmailAndPassword(
      String email, String password, String role) async {
    AuthResult result = await fbInstance.createUserWithEmailAndPassword(
        email: email, password: password);
    await Firestore.instance
        .collection('users')
        .document(result.user.uid)
        .setData({
      'email': result.user.email,
      'uid': result.user.uid,
      'displayName': null,
      'photoUrl': null,
      'phoneNo': defaultPicture,
      'role': role
    });
    // final QuerySnapshot snap = await Firestore.instance.collection('users').where('uid', isEqualTo: result.user.uid)
    //     .getDocuments();
    // final List<DocumentSnapshot> documents = snap.documents;
    // if(documents.length !=0){
    //   prefs = await SharedPreferences.getInstance();
    //   await prefs.setString('roleFromSignIn', documents[0].data['role']);
    // }
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('obtainedRole', role);
    return result;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await fbInstance.currentUser();
    return user.uid;
  }

  Future<AuthResult> googleSignUp() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    AuthResult authResult = await fbInstance.signInWithCredential(credential);
    authResult = authResult;
    print('authResult: ${authResult.user.uid}');
    
    if (authResult.user != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('uid', isEqualTo: authResult.user.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        prefs = await SharedPreferences.getInstance();
        await prefs.setString('obtainedRole', null);
        await Firestore.instance
            .collection('users')
            .document(authResult.user.uid)
            .setData({
          'email': authResult.user.email,
          'uid': authResult.user.uid,
          'photoUrl': authResult.user.photoUrl,
          'displayname': authResult.user.displayName,
          'phoneNo': authResult.user.phoneNumber,
          'role': null
        });
      } else {
        print('obtainedRole from google sign up: ${documents[0].data['role']}');
          prefs = await SharedPreferences.getInstance();
          await prefs.setString('obtainedRole', documents[0].data['role']);
        print('error causing document: ${documents[0].data}');
        await prefs.setString(
            'nameFromSignIn', documents[0].data['displayname']);
        await prefs.setString(
            'photoUrlFromSignIn', documents[0].data['photoUrl']);
        await prefs.setInt('phoneNoFromSignIn', documents[0].data['phoneNo']);
        await prefs.setString('roleFromSignIn', documents[0].data['role']);
      }
    }

    print('authResult uid ${authResult.user.uid}');
    return authResult;
  }

  Future<Null> signOut() async {
    await fbInstance.signOut();
    // await _googleSignIn.disconnect();
    // await _googleSignIn.signOut();
  }

  @override
  Future<DocumentSnapshot> completeReg(String name, int phoneNo, [File profilePic,
      String role]) async {
        FirebaseUser user = await fbInstance.currentUser();
        String downloadUrl;
    if(profilePic != null){
      String fileName = basename(profilePic.path);
    StorageReference storageRef = firebaseStorageRef
        .ref()
        .child('Profile Images')
        .child(user.uid)
        .child(fileName);
    StorageUploadTask uploadTask = storageRef.putFile(profilePic);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print('task Snapshot, $taskSnapshot');
    downloadUrl = await storageRef.getDownloadURL();
    
    }
    
    if(profilePic == null) {
      await firestoreRef.collection('users').document(user.uid).updateData(
            {'displayName': name, 'photoUrl': defaultPicture, 'phoneNo': phoneNo});
    }else if(role == null){
      await firestoreRef.collection('users').document(user.uid).updateData(
            {'displayName': name, 'photoUrl': downloadUrl, 'phoneNo': phoneNo});
    }else {
      await firestoreRef.collection('users').document(user.uid).updateData({
            'displayName': name,
            'photoUrl': downloadUrl,
            'phoneNo': phoneNo,
            'role': role
          });
    }
    final QuerySnapshot snap = await Firestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = snap.documents;
    print('this is from complete signin method documents ${documents[0].data}');
    if (documents.length != 0) {
      prefs = await SharedPreferences.getInstance();
      await prefs.setString('nameFromSignIn', documents[0].data['displayName']);
      await prefs.setString(
          'photoUrlFromSignIn', documents[0].data['photoUrl']);
      await prefs.setInt('phoneNoFromSignIn', documents[0].data['phoneNo']);
      await prefs.setString('roleFromSignIn', documents[0].data['role']);
    }
   return documents[0];
  }
}

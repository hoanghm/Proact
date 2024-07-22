import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/firestore.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:gemini_proact_flutter/model/database/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

final logger = Logger('login_signup');

enum AuthExceptionCode implements Comparable<AuthExceptionCode> {
  invalidCredential(value: 'invalid-credential'),
  invalidEmail(value: 'invalid-email'),
  weakPassword(value: 'weak-password'),
  accountExists(value: 'email-already-in-use'),
  unknown(value: 'unknown');

  const AuthExceptionCode({required this.value});

  final String value;

  @override
  int compareTo(AuthExceptionCode other) {
    return value.compareTo(other.value);
  }

  @override
  String toString() {
    return value;
  }
}

class AuthException implements Exception {
  final String message;
  final Exception cause;
  final AuthExceptionCode code;

  AuthException({
    required this.message,
    required this.cause,
    this.code = AuthExceptionCode.unknown
  });

  @override
  String toString() {
    return '$message [$code] $cause';
  }
}

/// Sign out existing user account
Future<void> signOutUser() async {
  await FirebaseAuth.instance.signOut();
}

// Sign out unverified user account
Future<void> signOutUnverifiedAccount() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user!= null && !user.emailVerified) {
    await FirebaseAuth.instance.signOut();
  }
}

/// Log into existing user account with email and password.
Future<void> loginWithEmail(String email, String password) async {
  logger.info('log into existing user in FirebaseAuth');
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
    
    logger.info('user login passed');
  }
  on FirebaseAuthException catch (e) {
    if (e.code == AuthExceptionCode.invalidCredential.value) {
      throw AuthException(
        message: 'Email or password is incorrect.', 
        cause: e, 
        code: AuthExceptionCode.invalidCredential
      );
    }
    else if (e.code == AuthExceptionCode.invalidEmail.value) {
      throw AuthException(
        message: 'Acount for given email not found.',
        cause: e,
        code: AuthExceptionCode.invalidEmail
      );
    }
    else {
      throw AuthException(
        message: 'Login failed.',
        cause: e
      );
    }
  }
}

/// Registers a person signing in for the first time via Google Sign in
Future<ProactUser> registerGoogleUser() async {
  try {
    User user = FirebaseAuth.instance.currentUser!;
    ProactUser newUser = ProactUser(
      email: user.email!, 
      interests: [], 
      occupation: "", 
      others: [], 
      username: user.displayName ?? "", 
      onboarded: false, 
      location: ""
    );
    await usersRef 
      .doc(user.uid)
      .set(newUser);
    return newUser;
  } catch (err) {
    throw ErrorDescription('$err');
  }
}

/// Register new user account with email and password.
Future<void> registerWithEmail(String email, String password) async {
  logger.info('create new user in FirebaseAuth');
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, 
      password: password,
    );
    String userId = userCredential.user!.uid;

    // Create new User on Cloud Firestore
    await usersRef
      .doc(userId)
      .set(
      ProactUser(
        email: email, 
        interests: [], 
        occupation: "", 
        others: [], 
        questionnaire: [],
        username: "",
        onboarded: false, 
        location: "",
        projects: []
      )
    );

    logger.info('user signup passed');
  }
  on FirebaseAuthException catch (e) {
    if (e.code == AuthExceptionCode.invalidEmail.value) {
      throw AuthException(
        message: 'Invalid email.',
        cause: e,
        code: AuthExceptionCode.invalidEmail
      );
    }
    else if (e.code == AuthExceptionCode.weakPassword.value) {
      throw AuthException(
        message: 'Weak password.',
        cause: e,
        code: AuthExceptionCode.weakPassword
      );
    }
    else if (e.code == AuthExceptionCode.accountExists.value) {
      throw AuthException(
        message: 'Account already exists for given email.',
        cause: e,
        code: AuthExceptionCode.accountExists
      );
    }
    else {
      throw AuthException(
        message: 'Register failed at auth.', 
        cause: e
      );
    }
    
  }
  on FirebaseException catch (e) {
    throw AuthException(
      message: 'Register failed.', 
      cause: e
    );
  }
}

/// Reset user password (via sending email) 
Future<void> forgotPassword({required String email}) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
  on FirebaseAuthException catch (e) {
    throw AuthException(
      message: 'Unable to send password reset email.', 
      cause: e
    );
  }
}

/// Send verification email
Future<void> sendVerificationEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user!= null && !user.emailVerified) {
    // await user.sendEmailVerification(
    //   ActionCodeSettings(
    //     url: 'https://www.yourapp.com/?email=${user.email}',
    //     handleCodeInApp: true,
    //     iOSBundleId: 'com.example.geminiProactFlutter',
    //     androidPackageName: 'com.proact',
    //     androidInstallApp: true,
    //     androidMinimumVersion: '12',
    //   ),
    // );
    await user.sendEmailVerification();
  }
}

/// ASd


/// Sign into Google
Future<UserCredential> signInWithGoogle() async {
  GoogleSignIn googleSignIn = GoogleSignIn();
  
  // Sign out user so user can choose which google account (normally caches most recent signin account)
  await googleSignIn.signOut();

  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  
  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

/// 
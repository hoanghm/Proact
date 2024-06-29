import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:gemini_proact_flutter/model/database/user.dart';

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

/// Register new user account with email and password.
Future<void> registerWithEmail(String email, String password) async {
  logger.info('create new user in FirebaseAuth');
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    String userId = userCredential.user!.uid;

    // Create new User on Cloud Firestore
    await FirebaseFirestore.instance
    .collection(UserTable.name)
    .add({
      UserAttribute.email.toString(): email, 
      UserAttribute.vaultedId.toString(): userId
    });

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
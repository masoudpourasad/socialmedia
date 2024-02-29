import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/screens/mainscreen.dart';
import 'package:socialmedia/services/auth_service.dart';
import 'package:socialmedia/utils/validation.dart';

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String? email, password;
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();
  AuthService auth = AuthService();

  login(context) async {
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar(
          'Please fix the errors in red before submitting.', context);
    } else {
      loading = true;
      notifyListeners();
      try {
        bool success = await auth.loginUser(
          email: email,
          password: password,
        );
        if (kDebugMode) {
          print(success);
        }
        if (success) {
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (_) => const TabScreen()));
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        if (kDebugMode) {
          print(e);
        }

        showInSnackBar(auth.handleFirebaseAuthError(e.toString()), context);
      }
      loading = false;
      notifyListeners();
    }
  }

  forgotPassword(context) async {
    loading = true;
    notifyListeners();
    FormState form = formKey.currentState!;
    form.save();
    if (kDebugMode) {
      print(Validations.validateEmail(email));
    }
    if (Validations.validateEmail(email) != null) {
      showInSnackBar(
          'Please input a valid email to reset your password.', context);
    } else {
      try {
        await auth.forgotPassword(email!);
        showInSnackBar(
            'Please check your email for instructions '
            'to reset your password',
            context);
      } catch (e) {
        showInSnackBar(e.toString(), context);
      }
    }
    loading = false;
    notifyListeners();
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}

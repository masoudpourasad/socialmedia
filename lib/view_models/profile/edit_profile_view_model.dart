import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia/models/user.dart';
import 'package:socialmedia/services/user_service.dart';
import 'package:socialmedia/utils/constants.dart';

class EditProfileViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  UserService userService = UserService();
  final picker = ImagePicker();
  UserModel? user;
  String? country;
  String? username;
  String? bio;
  File? image;
  String? imgLink;
  CroppedFile? croppedFile;
  XFile? pickedFile;

  setUser(UserModel val) {
    user = val;
    notifyListeners();
  }

  setImage(UserModel user) {
    imgLink = user.photoUrl;
  }

  setCountry(String val) {
    if (kDebugMode) {
      print('SetCountry $val');
    }
    country = val;
    notifyListeners();
  }

  setBio(String val) {
    if (kDebugMode) {
      print('SetBio $val');
    }
    bio = val;
    notifyListeners();
  }

  setUsername(String val) {
    if (kDebugMode) {
      print('SetUsername $val');
    }
    username = val;
    notifyListeners();
  }

  Future<void> editProfile(context) async {
    FormState? form = formKey.currentState;

    if (form != null) {
      loading = true;
      form.save();
      if (!form.validate()) {
        validate = true;
        notifyListeners();
        showInSnackBar(
            'Please fix the errors in red before submitting.', context);
      } else {
        try {
          loading = true;
          notifyListeners();

          if (image != null) {
            pickedFile = XFile(image!.path);
            croppedFile = await ImageCropper().cropImage(
              sourcePath: pickedFile!.path,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
              uiSettings: [
                AndroidUiSettings(
                  toolbarTitle: 'Crop Image',
                  toolbarColor: Constants.lightAccent,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: false,
                ),
                IOSUiSettings(
                  minimumAspectRatio: 1.0,
                ),
              ],
            );

            imgLink = null;
            if (croppedFile != null) {
              imgLink = croppedFile!.path;
            }
          }

          bool success = await userService.updateProfile(
            image: croppedFile != null ? File(croppedFile!.path) : null,
            username: username,
            bio: bio,
            country: country,
          );

          if (kDebugMode) {
            print(success);
          }

          if (success) {
            clear();
            Navigator.pop(context);
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
          showInSnackBar('Error updating profile', context);
        } finally {
          loading = false;
          notifyListeners();
        }
      }
    }
  }

  Future<void> pickImage({bool camera = false, context}) async {
    loading = true;
    notifyListeners();
    try {
      XFile? pickedFile = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile != null) {
        croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Constants.lightAccent,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        imgLink = null;
        if (croppedFile != null) {
          imgLink = croppedFile!.path;
        }
      } else {
        if (scaffoldKey.currentContext != null) {
          showInSnackBar('Cancelled', scaffoldKey.currentContext!);
        }
      }
    } catch (e) {
      if (scaffoldKey.currentContext != null) {
        showInSnackBar('Error picking image', scaffoldKey.currentContext!);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  clear() {
    image = null;
    notifyListeners();
  }

  void showInSnackBar(String value, BuildContext? context) {
    if (context != null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));
    }
  }
}

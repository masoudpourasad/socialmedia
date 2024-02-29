import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia/models/post.dart';
import 'package:socialmedia/screens/mainscreen.dart';
import 'package:socialmedia/services/post_service.dart';
import 'package:socialmedia/services/user_service.dart';
import 'package:socialmedia/utils/constants.dart';
import 'package:socialmedia/utils/firebase.dart';

class PostsViewModel extends ChangeNotifier {
  //Services
  UserService userService = UserService();
  PostService postService = PostService();

  //Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Variables
  bool loading = false;
  String? username;
  File? mediaUrl;
  final picker = ImagePicker();
  String? location;
  Position? position;
  Placemark? placemark;
  String? bio;
  String? description;
  String? email;
  String? commentData;
  String? ownerId;
  String? userId;
  String? type;
  File? userDp;
  String? imgLink;
  bool edit = false;
  String? id;

  //controllers
  TextEditingController locationTEC = TextEditingController();

  //Setters
  setEdit(bool val) {
    edit = val;
    notifyListeners();
  }

  setPost(PostModel post) {
    description = post.description;
    imgLink = post.mediaUrl;
    location = post.location;
    edit = true;
    edit = false;
    notifyListeners();
  }

  setUsername(String val) {
    username = val;
    notifyListeners();
  }

  setDescription(String val) {
    description = val;
    notifyListeners();
  }

  setLocation(String val) {
    location = val;
    notifyListeners();
  }

  setBio(String val) {
    bio = val;
    notifyListeners();
  }

  pickImage({bool camera = false, context}) async {
    loading = true;
    notifyListeners();
    try {
      XFile? pickedFile = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      CroppedFile? croppedFile = await ImageCropper().cropImage(
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
      mediaUrl = croppedFile != null ? File(croppedFile.path) : null;
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar('Cancelled', context);
    }
  }

  getLocation(context) async {
    loading = true;
    notifyListeners();
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      LocationPermission rPermission = await Geolocator.requestPermission();
      if (rPermission == LocationPermission.denied ||
          rPermission == LocationPermission.deniedForever) {
        showInSnackBar('Location permission denied', context);
        loading = false;
        notifyListeners();
      } else {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position!.latitude, position!.longitude);
          if (placemarks.isNotEmpty) {
            placemark = placemarks[0];
            location = " ${placemarks[0].locality}, ${placemarks[0].country}";
            locationTEC.text = location!;
          } else {
            throw Exception(
                "No address information found for supplied coordinates");
          }
        } catch (e) {
          showInSnackBar('Error retrieving location information', context);
        }
      }
      await getLocation(context);
    }

    loading = false;
    notifyListeners();
  }

  uploadPosts(context) async {
    try {
      loading = true;
      notifyListeners();
      await postService.uploadPost(mediaUrl!, location!, description!);
      loading = false;
      resetPost(context);
      notifyListeners();
    } catch (e) {
      loading = false;
      resetPost(context);
      showInSnackBar('Uploaded successfully!', context);
      notifyListeners();
    }
  }

  uploadProfilePicture(context) async {
    if (mediaUrl == null) {
      showInSnackBar('Please select an image', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        await postService.uploadProfilePicture(
            mediaUrl!, firebaseAuth.currentUser!);
        loading = false;
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (_) => const TabScreen()));
        notifyListeners();
      } catch (e) {
        loading = false;
        showInSnackBar('Uploaded successfully!', context);
        notifyListeners();
      }
    }
  }

  resetPost(context) {
    mediaUrl = null;
    description = null;
    location = null;
    edit = false;
    notifyListeners();
  }

  void showInSnackBar(String value, BuildContext? context) {
    if (context != null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));
    } else {}
  }
}

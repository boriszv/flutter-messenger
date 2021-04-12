import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pa_messenger/models/appUser.dart';
import 'package:pa_messenger/pages/take_picture.dart';
import 'package:pa_messenger/services/file_uploading_service.dart';
import 'package:pa_messenger/services/ifile_uploading_service.dart';
import 'package:pa_messenger/services/iimage_compressing_service.dart';
import 'package:pa_messenger/services/iimage_cropping_service.dart';
import 'package:pa_messenger/services/image_compressing_service.dart';
import 'package:pa_messenger/services/image_cropping_service.dart';
import 'package:pa_messenger/widgets/app_button.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';
import 'package:pa_messenger/widgets/app_text_field.dart';
import 'package:path/path.dart' as p;

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  static final IFileUploadingService _fileUploadingService = FileUploadingService();
  static final IImageCroppingService _imageCroppingService = ImageCroppingService();
  static final IImageCompressingService _imageCompressingService = ImageCompressingService();

  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _aboutMeController = TextEditingController();

  String imageUrl;
  var showLoading = false;
  var showSaving = false;

  get currentUserId => FirebaseAuth.instance.currentUser.uid;

  @override
  void initState() {
    _fetchConversations();
    super.initState();
  }

  DocumentReference _buildQuery() {
    return FirebaseFirestore.instance.doc('users/$currentUserId');
  }

  Future<void> _fetchConversations() async {
    setState(() { showLoading = true; });

    final result = await _buildQuery().get();
    final user = AppUser.fromMap(result.id, result.data());

    _nameController.text = user.name;
    _aboutMeController.text = user.bio;

    setState(() {
      showLoading = false;
      imageUrl = user.imageUrl;
    });
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(context: context, builder: (context) => BottomSheet(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: Icon(Icons.camera), title: Text('Camera'), onTap: () {
            Navigator.of(context).pop();
            _selectPhotoWithCamera();
          }),
          ListTile(leading: Icon(Icons.filter), title: Text('Pick a file'), onTap: () {
            Navigator.of(context).pop();
            _selectPhotoWithGallery();
          }),
        ],
      ),
      onClosing: () {},
    ));
  }

  Future _selectPhotoWithCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    final path = await Navigator.of(context).pushNamed('/take-picture', arguments: TakePictureArgs(cropImage: true)) as String;
    if (path == null || path.trim().isEmpty) {
      return;
    }

    await _uploadFile(path);
  }

  Future _selectPhotoWithGallery() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile == null) {
      return;
    }

    var file = await _imageCroppingService.cropImage(pickedFile.path, 1, 1);
    if (file == null) {
      return;
    }

    file = await _imageCompressingService.compressImagePath(file.path, 35);

    await _uploadFile(file.path);
  }

  Future _uploadFile(String path) async {
    final pathToUploadTo = '/users/$currentUserId/${p.basename(path)}';
    final fileUrl = await _fileUploadingService.uploadFileAndGetUrl(path, pathToUploadTo: pathToUploadTo);

    setState(() { imageUrl = fileUrl; });

    try {
      final userToUpdate = { 'imageUrl': imageUrl };
      await _buildQuery().set(userToUpdate, SetOptions(merge: true));
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile image updated')));

    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile image not updated')));
    }
  }

  Future _saveChanges() async {
    setState(() { showSaving = true; });

    try {
      final user = {
        'bio': _aboutMeController.text,
        'name': _nameController.text,
        'imageUrl': imageUrl
      };
      await _buildQuery().set(user, SetOptions(merge: true));
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile saved')));

    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile was not saved')));

    } finally {
      setState(() { showSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Builder(
            builder: (context) {
              if (showLoading) {
                return Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (imageUrl != null) ...[
                    _image(imageUrl),
                    SizedBox(height: 10),
                    _changePhoto(context),
                  ],

                  SizedBox(height: 10),
                  _name(),
                  SizedBox(height: 15),
                  _aboutMe(),
                  SizedBox(height: 40),

                  if (!showSaving) _save(),
                  if (showSaving) CircularProgressIndicator(),
                ],
              );
            }
          ),
        ),
      )
    );
  }

  _image(String imageUrl) => InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: () => _selectPhoto(),
    child: AppRoundImage.url(
      imageUrl,
      width: 80,
      height: 80,
    ),
  );

  _changePhoto(BuildContext context) => InkWell(
    onTap: () => _selectPhoto(),
    child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Change photo', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
    ),
  );

  _name() => AppTextField(
    controller: _nameController,
    labelText: 'Name',
    keyboardType: TextInputType.text,
  );

  _aboutMe() => AppTextField(
    controller: _aboutMeController,
    labelText: 'About me',
    keyboardType: TextInputType.multiline,
    minLines: 3,
    alignLabelWithHint: true,
  );

  _save() => PrimaryButton(
    onPressed: () {
      _saveChanges();
    },
    borderRadius: 30,
    minWidth: double.infinity,
    text: 'Save',
  );
}

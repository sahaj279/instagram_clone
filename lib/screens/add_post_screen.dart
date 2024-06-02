import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapblog/models/user_model.dart';
import 'package:snapblog/providers/user_provider.dart';
import 'package:snapblog/resources/firestore_methods.dart';
import 'package:snapblog/utils/colors.dart';
import 'package:snapblog/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descController = TextEditingController();
  bool _isLosding = false;
  bool isblog = false;

  _selectImage(BuildContext context) async {
    //to show the dialog box
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create a Post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take from photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await Util.pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Chose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await Util.pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void postImage(
      {required String uid,
      required String username,
      required String profileImage}) async {
    try {
      setState(() {
        _isLosding = true;
      });
      String res = await FirestoreMethods()
          .uploadPost(_descController.text, _file, uid, username, profileImage);
      setState(() {
        _isLosding = false;
      });
      if (res == 'Success!') {
        Util.showSnackBar(res, context);
        clearImage();
      } else {
        Util.showSnackBar(res, context);
      }
    } catch (e) {
      Util.showSnackBar(e.toString(), context);
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
      isblog = false;
    });
  }

  void _addblog() {
    setState(() {
      isblog = true;
      // print(_file);
    });
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return (_file == null && isblog == false)
        ? SafeArea(
          child: Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'Add a post',
                        style:
                            TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.upload,
                          size: 35,
                          color:borderColor
                        ),
                        onPressed: () => _selectImage(context),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'Write a blog',
                        style:
                            TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon:const  Icon(
                          Icons.draw_outlined,
                          size: 35,
                          color: borderColor,
                        ),
                        onPressed: _addblog,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        )
        : isblog == true
            ? Scaffold(
                appBar: AppBar(
                  title: const Text('Blog',style: TextStyle(fontWeight: FontWeight.bold),),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: clearImage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => postImage(
                          uid: user.uid,
                          username: user.username,
                          profileImage: user.photourl), //is blog
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          color: textButtonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (_isLosding)
                          ? const LinearProgressIndicator()
                          : const Padding(padding: EdgeInsets.only(top: 0)),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: borderColor,
                              radius: 19,
                              child: CircleAvatar(
                              radius: 16,
                                backgroundImage:
                                    CachedNetworkImageProvider(user.photourl),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              user.username,
                              style: const TextStyle(
                                  fontSize: 20, color: textColor,fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: borderColor,),
                      Padding(
                          padding: const EdgeInsets.all(10.0).copyWith(top:0),
                          child: TextField(
                            scrollPhysics:const NeverScrollableScrollPhysics(),
                            controller: _descController,
                            autofocus: true,
                            maxLines: null,
                            cursorColor: Colors.white,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            decoration:const  InputDecoration(
                              border: InputBorder.none,
                              hintText: 'I want to share...',
                            ),
                          ))
                    ],
                  ),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: const Text('Post to',style:TextStyle(fontWeight: FontWeight.bold)),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: clearImage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => postImage(
                          uid: user.uid,
                          username: user.username,
                          profileImage: user.photourl),
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          color: textButtonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    (_isLosding)
                        ? const LinearProgressIndicator()
                        : const Padding(padding: EdgeInsets.only(top: 0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: borderColor,
                          radius:19,
                          child: CircleAvatar(
                          radius:16,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photourl),
                            // NetworkImage(user.photourl),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Write a Caption...',
                              border: InputBorder.none,
                            ),
                            maxLines: 5,
                            maxLength: 100,
                            controller: _descController,
                          ),
                        ),
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: AspectRatio(
                            aspectRatio: 487 / 451,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: MemoryImage(_file!),
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter,
                              )),
                            ),
                          ),
                        ),
                        // Divider(
                        //   // height: 20,
                        //   color: Colors.grey,
                        // ),
                      ],
                    )
                  ],
                ),
              );
  }
}

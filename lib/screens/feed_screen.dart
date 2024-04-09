// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'dart:typed_data';

// // Data model for images
// class HiveImageInfo {
//   final Uint8List image;
//   final String prompt;
//   final DateTime timestamp;

//   HiveImageInfo(this.image, this.prompt, this.timestamp);
// }

// class FeedScreen extends StatefulWidget {
//   @override
//   _FeedScreenState createState() => _FeedScreenState();
// }

// class _FeedScreenState extends State<FeedScreen> {
//   late List<HiveImageInfo> allImages;

//   @override
//   void initState() {
//     super.initState();
//     loadImages();
//   }

//   Future<void> loadImages() async {
//     // Initialize list
//     List<HiveImageInfo> aggregatedImages = [];

//     // Iterate through all users' local storage
//     final users = Hive.box('users');
//     for (int i = 0; i < users.length; i++) {
//       final user = users.getAt(i);

//       // Retrieve image history for the user
//       final imageHistoryBox = Hive.box('imageHistory_${user.userId}');
//       for (int j = 0; j < imageHistoryBox.length; j++) {
//         final imageInfo = imageHistoryBox.getAt(j) as HiveImageInfo;
//         aggregatedImages.add(imageInfo);
//       }
//     }

//     // Sort images by timestamp
//     aggregatedImages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

//     setState(() {
//       allImages = aggregatedImages;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Feed'),
//       ),
//       body: allImages == null
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: allImages.length,
//               itemBuilder: (context, index) {
//                 final imageInfo = allImages[index];
//                 return ListTile(
//                   leading: Image.memory(
//                     imageInfo.image,
//                     width: 40,
//                     height: 40,
//                     errorBuilder: (context, error, stackTrace) =>
//                         Icon(Icons.error),
//                   ),
//                   title: Text(imageInfo.prompt),
//                   subtitle: Text(imageInfo.timestamp.toString()),
//                   onTap: () {
//                     // Handle tap on image
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/image_info.dart';



class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
   List<HiveImageInfo> allImages = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUser = user;
        });
        loadImages(user.uid);
      }
    });
  }

  Future<void> loadImages(String userId) async {
  // Open the image history box for the user
  final imageHistoryBox = Hive.box('imageHistory');

  // Initialize list
  List<HiveImageInfo> aggregatedImages = [];

  // Retrieve image history for the user
  for (int j = 0; j < imageHistoryBox.length; j++) {
    final imageInfo = imageHistoryBox.getAt(j)!; // Ensure to handle null safely
    aggregatedImages.add(imageInfo);
  }

  // Sort images by timestamp
  aggregatedImages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  setState(() {
    allImages = aggregatedImages;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: currentUser == null
          ? Center(child: CircularProgressIndicator())
          : allImages == null
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: allImages.length,
                  itemBuilder: (context, index) {
                    final imageInfo = allImages[index];
                    return ListTile(
                      leading: Image.memory(
                        imageInfo.image,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.error),
                      ),
                      title: Text(imageInfo.prompt),
                      subtitle: Text(imageInfo.timestamp.toString()),
                      onTap: () {
                        // Handle tap on image
                      },
                    );
                  },
                ),
    );
  }
}

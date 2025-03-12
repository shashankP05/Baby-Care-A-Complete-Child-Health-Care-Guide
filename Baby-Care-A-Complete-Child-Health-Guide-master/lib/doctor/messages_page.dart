import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String searchQuery = "";
  String sortOption = "newest";
  bool isUploading = false;

  Future<void> _addPost() async {
    TextEditingController postController = TextEditingController();
    File? image;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 15,
                right: 15,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: postController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Write something...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final pickedFile = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 70, // Compress image
                          );
                          if (pickedFile != null) {
                            setModalState(() {
                              image = File(pickedFile.path);
                            });
                          }
                        },
                        child: const Text("Attach Image"),
                      ),
                      if (image != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Image.file(image!, height: 50),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () async {
                        if (postController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please write something"),
                            ),
                          );
                          return;
                        }

                        setModalState(() {
                          isUploading = true;
                        });

                        try {
                          String? imageUrl;
                          if (image != null) {
                            // Create a unique filename
                            String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
                            Reference ref = FirebaseStorage.instance.ref().child(fileName);

                            // Upload the file
                            await ref.putFile(
                              image!,
                              SettableMetadata(contentType: 'image/jpeg'),
                            );

                            // Get the download URL
                            imageUrl = await ref.getDownloadURL();
                          }

                          // Add post to Firestore
                          await FirebaseFirestore.instance
                              .collection("posts")
                              .add({
                            "text": postController.text,
                            "image": imageUrl,
                            "timestamp": FieldValue.serverTimestamp(),
                          });

                          // Close the bottom sheet immediately after successful upload
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${e.toString()}"),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setModalState(() {
                              isUploading = false;
                            });
                          }
                        }
                      },
                      child: Text(isUploading ? "Posting..." : "Post"),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rest of your build method remains the same
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search posts...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .orderBy("timestamp", descending: sortOption == "newest")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var posts = snapshot.data!.docs
                    .where((doc) => doc["text"]
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(post["text"] ?? "",
                            style: const TextStyle(fontSize: 16)),
                        subtitle: post["image"] != null
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Image.network(post["image"]),
                        )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: _addPost,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
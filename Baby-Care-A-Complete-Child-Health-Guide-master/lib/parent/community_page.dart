import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = "";
  String sortOption = "newest";
  bool isUploading = false;

  Future<void> _addPost() async {
    TextEditingController postController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 15,
            right: 15,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: postController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Write something...",
                  border: OutlineInputBorder(),
                ),
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

                    setState(() {
                      isUploading = true;
                    });

                    try {
                      await _firestore.collection("posts").add({
                        "text": postController.text,
                        "userId": _auth.currentUser!.uid,
                        "userName": _auth.currentUser!.displayName ?? "Anonymous",
                        "timestamp": FieldValue.serverTimestamp(),
                        "likes": 0, // Initialize likes to 0
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Post created successfully"),
                          ),
                        );
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
                        setState(() {
                          isUploading = false;
                        });
                      }
                    }
                  },
                  child: Text(isUploading ? "Posting..." : "Post"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editPost(String postId, String currentText) async {
    TextEditingController postController = TextEditingController(text: currentText);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 15,
            right: 15,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: postController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Edit your post...",
                  border: OutlineInputBorder(),
                ),
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

                    setState(() {
                      isUploading = true;
                    });

                    try {
                      await _firestore.collection("posts").doc(postId).update({
                        "text": postController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Post updated successfully"),
                          ),
                        );
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
                        setState(() {
                          isUploading = false;
                        });
                      }
                    }
                  },
                  child: Text(isUploading ? "Updating..." : "Update"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _firestore.collection("posts").doc(postId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Post deleted successfully"),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
          ),
        );
      }
    }
  }

  Future<void> _likePost(String postId, int currentLikes) async {
    try {
      await _firestore.collection("posts").doc(postId).update({
        "likes": currentLikes + 1,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
          ),
        );
      }
    }
  }

  Future<void> _sharePost(String postText) async {
    // Implement your share functionality here
    // For example, use the `share` package to share the post text
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Share functionality not implemented yet"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
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
              stream: _firestore
                  .collection("posts")
                  .orderBy("timestamp", descending: sortOption == "newest")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var posts = snapshot.data!.docs
                    .where((doc) => doc["text"]
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                    .toList();

                if (posts.isEmpty) {
                  return const Center(
                    child: Text('No posts found'),
                  );
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    var postId = post.id;
                    var userId = post["userId"];
                    var userName = post["userName"] ?? "Anonymous"; // Fallback for empty name
                    var text = post["text"];
                    var likes = post["likes"] ?? 0;
                    var timestamp = post["timestamp"]?.toDate();
                    var formattedDate = timestamp != null
                        ? DateFormat('MMM d, y • h:mm a').format(timestamp)
                        : '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            userName.isNotEmpty ? userName[0] : "A", // Fallback for empty name
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(text, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            formattedDate,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        trailing: SizedBox(
                          height: 56, // Constrain the height to prevent overflow
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Like and Share Buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up, size: 20),
                                    onPressed: () => _likePost(postId, likes),
                                  ),
                                  Text(likes.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.share, size: 20),
                                    onPressed: () => _sharePost(text),
                                  ),
                                ],
                              ),
                              // Edit/Delete Menu (only for the post owner)
                              if (_auth.currentUser?.uid == userId)
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text("Edit"),
                                      onTap: () => _editPost(postId, text),
                                    ),
                                    PopupMenuItem(
                                      child: const Text("Delete"),
                                      onTap: () => _deletePost(postId),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
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
        padding: const EdgeInsets.only(bottom: 70), // Adjusted to move the button higher
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
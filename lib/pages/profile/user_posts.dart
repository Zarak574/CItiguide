import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rolebase/pages/profile/editpost_screen.dart';
import 'package:rolebase/pages/profile/upload_screen.dart';

class UserPosts extends StatefulWidget {
  @override
  _UserPostsState createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  late User _user;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _posts = []; // List to store posts

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchUserData();
    _fetchUserPosts(); // Fetch posts when the screen initializes
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();

      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print('Failed to fetch user data: $e');
    }
  }

Future<void> _fetchUserPosts() async {
  try {
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: _user.uid)
        .orderBy('timestamp', descending: true) // Order posts by timestamp
        .get();

    List<Map<String, dynamic>> posts = postsSnapshot.docs
        .map((doc) => {
          'id': doc.id, // Add the document ID here
          ...doc.data() as Map<String, dynamic>,
        })
        .toList();

    setState(() {
      _posts = posts;
    });
  } catch (e) {
    print('Failed to fetch user posts: $e');
  }
}


void _showPostDetailsDialog(Map<String, dynamic> post) {
  final postId = post['id'] as String?;
  if (postId == null) {
    print('Post ID is null');
    print('Post data: $post');
    return; // Exit early if post ID is null
  }
  
  // Fetch like and comment counts
  final likesCountFuture = _getLikesCount(postId);
  final commentsCountFuture = _getCommentsCount(postId);

  // Display dialog with fetched data
  showDialog(
    context: context,
    builder: (context) {
      final postId = post['id'] as String? ?? '';
      final imageUrl = post['url'] as String?;
      final postType = post['type'] as String?;
      final content = post['content'] as String?;
      final timestamp = (post['timestamp'] as Timestamp?)?.toDate();
      final userProfilePic = _userData?['profile_picture'] as String?;
      final userName = _userData?['username'] as String?;

      String formattedDate = timestamp != null
          ? '${timestamp.toLocal().toLocal().toString().split(' ')[0]}'
          : 'Date';

      return FutureBuilder(
        future: Future.wait([likesCountFuture, commentsCountFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              content: Center(child: CircularProgressIndicator()),
              actions: [
                TextButton(
                  child: Text(
                    'Close',
                    style: TextStyle(color: Color(0xFFFF8340)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            print('Error fetching counts: ${snapshot.error}');
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              content: Text('Error fetching counts'),
              actions: [
                TextButton(
                  child: Text(
                    'Close',
                    style: TextStyle(color: Color(0xFFFF8340)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }

                final likes = post['likes'] as List<dynamic>? ?? [];
                final isLiked = likes.contains(FirebaseAuth.instance.currentUser?.uid);
          final List<dynamic> counts = snapshot.data as List<dynamic>;
          final likesCount = counts[0] as int;
          final commentsCount = counts[1] as int;

          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: userProfilePic != null
                            ? NetworkImage(userProfilePic)
                            : null,
                        child: userProfilePic == null
                            ? Icon(Icons.person, size: 20, color: Colors.grey[700])
                            : null,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName ?? 'User',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.inversePrimary),
                            ),
                            Text(formattedDate),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editPost(post);
                          } else if (value == 'delete') {
                            _confirmDeletePost(post);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (content != null && content.isNotEmpty)
                    Text(
                      content,
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 10),
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: postType == 'video'
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(imageUrl, fit: BoxFit.cover),
                                Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
                              ],
                            )
                          : Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                         children: [
                              IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : null,
                              ),
                              onPressed: () async {
                                await _toggleLike(postId, FirebaseAuth.instance.currentUser?.uid ?? '');
                              },
                            ),
                              Text(
                                '$likesCount', 
                                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12
                                ),
                              ),
                            ]
                      ),
                      Row(
                       children: [
                                      IconButton(
                                        icon: const Icon(Icons.mode_comment_outlined),
                                        onPressed: () {
                                          _showCommentsDialog(postId);
                                        },
                                      ),
                                      Text(
                                        '$commentsCount',
                                        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                                      ),
                                    ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Close',
                  style: TextStyle(color: Color(0xFFFF8340)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}


Future<int> _getLikesCount(String postId) async {
  try {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final postDoc = await postRef.get();
    final data = postDoc.data() as Map<String, dynamic>?;
    final likes = List<String>.from(data?['likes'] ?? []);
    return likes.length;
  } catch (e) {
    print('Failed to fetch likes count: $e');
    return 0;
  }
}

  void _confirmDeletePost(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the confirmation dialog
                await _deletePost(post); // Call the delete method
              },
              child: Text('Delete' ,style: TextStyle(color: Color(0xFFFF8340),),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(Map<String, dynamic> post) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(post['id']).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
      _fetchUserPosts(); // Refresh posts list
    } catch (e) {
      print('Failed to delete post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

// Update this section in _editPost method
void _editPost(Map<String, dynamic> post) async {
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => EditPostScreen(
        postId: post['id'],
        initialContent: post['content'] ?? '',
        initialImageUrl: post['url'],
      ),
    ),
  );
  if (result == true) {
    _fetchUserPosts(); // Refresh posts if the result indicates changes
  }
}


Future<void> _toggleLike(String postId, String userId) async {
  final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

  try {
    final postDoc = await postRef.get();
    
    if (!postDoc.exists) {
      print('Post document does not exist');
      return;
    }

    final data = postDoc.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likes'] ?? []);

    if (likes.contains(userId)) {
      // User already liked, so remove the like
      likes.remove(userId);
    } else {
      // Add the user to the likes list
      likes.add(userId);
    }

    await postRef.update({'likes': likes});
    print('Likes updated successfully for postId: $postId');
  } catch (e) {
    print('Failed to toggle like: $e');
  }
}


Future<void> _addComment(String postId, String commentText) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  try {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments');

    await commentsRef.add({
      'userId': userId,
      'text': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('Comment added successfully');
  } catch (e) {
    print('Failed to add comment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to add comment.')),
    );
  }
}


Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc.data()!;
    } else {
      return {
        'username': 'Unknown User',
        'profile_picture': '', // Default or placeholder image URL
      };
    }
  } catch (e) {
    print('Failed to fetch user details: $e');
    return {
      'username': 'Error',
      'profile_picture': '', // Default or placeholder image URL
    };
  }
}


Future<List<Map<String, dynamic>>> _fetchComments(String postId) async {
  try {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments');

    final querySnapshot = await commentsRef.orderBy('timestamp').get();
    
    final comments = await Future.wait(querySnapshot.docs.map((doc) async {
      final data = doc.data();
      final userId = data['userId'];
      final userDetails = await _fetchUserDetails(userId);
      return {
        'userId': userId,
        'username': userDetails['username'],
        'profile_picture': userDetails['profile_picture'],
        'text': data['text'],
        'timestamp': data['timestamp'],
      };
    }));

    return comments;
  } catch (e) {
    print('Failed to fetch comments: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to fetch comments.')),
    );
    return [];
  }
}


Future<int> _getCommentsCount(String postId) async {
  try {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments');

    final querySnapshot = await commentsRef.get();
    return querySnapshot.size; // Return the count of comments
  } catch (e) {
    print('Failed to fetch comments count: $e');
    return 0; // Return 0 in case of an error
  }
}


void _showCommentsDialog(String postId) async {
  // Fetch comments when the dialog is opened
  final comments = await _fetchComments(postId);
  final commentsCount = comments.length; // Count the number of comments

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.secondary,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Comments',
            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 20),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: comments.isEmpty
              ? const Center(child: Text('No comments yet.'))
              : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final timestamp = (comment['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        leading: CircleAvatar(
                          backgroundImage: comment['profile_picture'] != null && comment['profile_picture']!.isNotEmpty
                              ? NetworkImage(comment['profile_picture'])
                              : null,
                          child: comment['profile_picture'] == null || comment['profile_picture']!.isEmpty
                              ? Icon(Icons.person, size: 20, color: Colors.grey[700])
                              : null,
                        ),
                        title: Text(comment['username'] ?? 'Unknown User', style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        )),
                        subtitle: Text(comment['text'] ?? '', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 14)),
                        trailing: Text(
                          DateFormat('MM/dd/yyyy').format(timestamp),
                          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                        ),
                      ),
                    );
                  },
                ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF56C6D3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF56C6D3), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF56C6D3), width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF8340)),
                  onPressed: () async {
                    if (_commentController.text.trim().isNotEmpty) {
                      await _addComment(postId, _commentController.text.trim());
                      _commentController.clear();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  final _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: _userData == null
                ? Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      // Profile Picture
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _userData?['profile_picture'] != null
                              ? NetworkImage(_userData!['profile_picture'] as String)
                              : null,
                          child: _userData?['profile_picture'] == null
                              ? Icon(Icons.person, size: 40, color: Colors.grey[700])
                              : null,
                        ),
                      ),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userData?['username'] ?? 'Username', // User name
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _userData?['bio'] ?? 'This is a user bio', // User bio
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Post Count
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary, // Background color
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(12), // Padding inside the container
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_posts.length} Posts',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 6, right: 10, bottom: 10, top: 5),
            child: Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // User Posts
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 posts per row
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.10, // Aspect ratio for image and text
              ),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                final imageUrl = post['url'] as String?;
                final content = post['content'] as String?;

                return GestureDetector(
                  onTap: () => _showPostDetailsDialog(post),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.secondary, // Background color for the entire post
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display image
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              height: 120, // Adjust as needed
                              width: double.infinity,
                            ),
                          ),
                        // Display text below image
                        if (content != null && content.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              content,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400, // Adjust text weight as needed
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Add Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UploadScreen(),
                    ),
                  ).then((_) {
                    // Refresh posts after returning from the upload screen
                    _fetchUserPosts();
                  });
                },
                child: const Icon(Icons.add, color: Color(0xFFFFF3E0), size: 30,),
                backgroundColor: Color(0xFFFF8340),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

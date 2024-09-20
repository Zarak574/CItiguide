import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:video_player/video_player.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {

int _currentIndex = 3;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Map<String, dynamic>> _posts = []; 
  @override
  void initState() {
    super.initState();
    _fetchAllPosts(); 
  }

  Future<void> _fetchAllPosts() async {
    try {
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true) // Order posts by timestamp
          .get();

      List<Map<String, dynamic>> posts = postsSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            data['timestamp'] = (data['timestamp'] as Timestamp).toDate(); // Convert Timestamp to DateTime
            return data;
          })
          .toList();

      setState(() {
        _posts = posts;
      });
    } catch (e) {
      print('Failed to fetch all posts: $e');
    }
  }
  Future<String?> _getUserProfileImageUrl(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print("User document does not exist.");
        return null;
      }

      final data = userDoc.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('profile_picture')) {
        print("Profile picture URL not found in the user document.");
        return null;
      }

      return data['profile_picture'] as String?;
    } catch (e) {
      print("Error fetching user profile image URL: $e");
      return null;
    }
  }

  Future<String?> _getUsername(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print("User document does not exist.");
        return null;
      }

      final data = userDoc.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('username')) {
        print("Username not found in the user document.");
        return null;
      }

      return data['username'] as String?;
    } catch (e) {
      print("Error fetching username: $e");
      return null;
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

    print('Comments fetched successfully: $comments');
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
                    final timestamp = (comment['timestamp'] as Timestamp).toDate();
                     return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background, // Background color
                        borderRadius: BorderRadius.circular(12), // Rounded borders
                        ),
                        child: ListTile(
                           contentPadding: const EdgeInsets.all(8.0),
                        leading: CircleAvatar(
                            backgroundImage: NetworkImage(comment['profile_picture']),
                        ),
                        title: Text(comment['username'], style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        subtitle: Text(comment['text'], style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 14,),),
                        trailing: Text(
                          DateFormat('MM/dd/yyyy').format(timestamp), style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary,),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding inside the text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded borders for text field
                        borderSide: const BorderSide(color: Color(0xFF56C6D3), width: 2), // Border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF56C6D3), width: 2), // Border color when focused
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF56C6D3), width: 2), // Border color when focused
                      ),
                    ),
                  ),
                ),
                 const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF8340),),
                  onPressed: () async {
                    if (_commentController.text.trim().isNotEmpty) {
                      await _addComment(postId, _commentController.text.trim());
                      _commentController.clear(); // Clear the text field
                      Navigator.pop(context); // Close the dialog
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
        title: const Text('Discover'),
      ),
      body: _posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                final postId = post['id'] as String? ?? '';
                final content = post['content'] as String? ?? '';
                final url = post['url'] as String?;
                final userId = post['userId'] as String? ?? '';
                final timestamp = post['timestamp'] as DateTime? ?? DateTime.now();
                final likesCount = (post['likes'] as List<dynamic>?)?.length ?? 0;
                final likes = post['likes'] as List<dynamic>? ?? [];
                final isLiked = likes.contains(FirebaseAuth.instance.currentUser?.uid);

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.secondary,
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile
                        FutureBuilder<String?>(
                          future: _getUsername(userId),
                          builder: (context, usernameSnapshot) {
                            if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (usernameSnapshot.hasError || !usernameSnapshot.hasData) {
                              return ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text('Unknown User',
                                  style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                                ),
                                subtitle: Text('${timestamp.toLocal().toString().split(' ')[0]}'),
                              );
                            } else {
                              return FutureBuilder<String?>(
                                future: _getUserProfileImageUrl(userId),
                                builder: (context, imageSnapshot) {
                                  if (imageSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (imageSnapshot.hasError || !imageSnapshot.hasData) {
                                    return ListTile(
                                      leading: const CircleAvatar(child: Icon(Icons.person)),
                                      title: Text(usernameSnapshot.data ?? 'Unknown User',
                                        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                                      ),
                                      subtitle: Text('${timestamp.toLocal().toString().split(' ')[0]}'),
                                    );
                                  } else {
                                    final profileImageUrl = imageSnapshot.data;
                                    return ListTile(
                                      leading: profileImageUrl != null
                                        ? CircleAvatar(backgroundImage: NetworkImage(profileImageUrl))
                                        : const CircleAvatar(child: Icon(Icons.person)),
                                      title: Text(usernameSnapshot.data ?? 'Unknown User',
                                        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                                      ),
                                      subtitle: Text('${timestamp.toLocal().toString().split(' ')[0]}'),
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),
                        // Text Content
                        if (content.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _TextWithToggle(content: content),
                          ),
                        // Media Content
                        if (url != null && url.isNotEmpty)
                          Container(
                            width: double.infinity,
                            height: 200,
                            padding: const EdgeInsets.all(8.0),
                            child: url.endsWith('.mp4')
                                ? AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: VideoPlayerWidget(url: url),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        // Actions
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : null,
                              ),
                              onPressed: () async {
                                await _toggleLike(postId, FirebaseAuth.instance.currentUser?.uid ?? '');
                                _fetchAllPosts(); 
                              },
                            ),
                              Text(
                                '$likesCount', 
                                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12
                                ),
                              ),
                             
                            const SizedBox(width: 6),
                            FutureBuilder<int>(
                              future: _getCommentsCount(postId),
                              builder: (context, commentsSnapshot) {
                                if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (commentsSnapshot.hasError) {
                                  return const Text('0 Comments'); // Default if there's an error
                                } else {
                                  final commentsCount = commentsSnapshot.data ?? 0;
                                  return Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.mode_comment_outlined),
                                        onPressed: () {
                                          _showCommentsDialog(postId);
                                        },
                                      ),
                                      Text(
                                        '$commentsCount', // Display comments count
                                        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                                      ),
                                    ],
                                  );
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
            },
          ),
           bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
  );
}
}
class _TextWithToggle extends StatefulWidget {
  final String content;

  _TextWithToggle({required this.content});

  @override
  _TextWithToggleState createState() => _TextWithToggleState();
}

class _TextWithToggleState extends State<_TextWithToggle> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.content,
          maxLines: _isExpanded ? null : 2,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (widget.content.length > 100) // Show toggle only if content is long
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show less' : 'Show more',
              style: const TextStyle(color: Color(0xFF56C6D3)),
            ),
          ),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : VideoPlayer(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

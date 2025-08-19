import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/widgets/general_button_widget.dart';
import 'tutor_login_screen.dart';

class TutorProfilePage extends StatefulWidget {
  const TutorProfilePage({Key? key}) : super(key: key);

  @override
  State<TutorProfilePage> createState() => _TutorProfilePageState();
}

class _TutorProfilePageState extends State<TutorProfilePage> {
  void _showUpdatePasscodeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedOption = 0; // 0 = Tutor ID, 1 = Password
        final idController = TextEditingController();
        final passwordController = TextEditingController();
        final confirmPasswordController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Passcode'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      RadioListTile<int>(
                        value: 0,
                        groupValue: selectedOption,
                        onChanged: (val) => setState(() => selectedOption = val ?? 0),
                        title: const Text('Change Tutor ID'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<int>(
                        value: 1,
                        groupValue: selectedOption,
                        onChanged: (val) => setState(() => selectedOption = val ?? 0),
                        title: const Text('Change Password'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (selectedOption == 0) ...[
                    const Text('New Tutor ID'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        hintText: 'Enter new Tutor ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ] else ...[
                    const Text('New Password'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter new password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Confirm Password'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Re-enter new password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                GeneralButtonWidget(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: const Color(0xFFFFBA31),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  textColor: Colors.black,
                ),
                GeneralButtonWidget(
                  text: 'Update',
                  onPressed: () async {
                    if (selectedOption == 0) {
                      // Update Tutor ID
                      final newId = idController.text.trim();
                      if (newId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tutor ID cannot be empty.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) throw Exception('Not logged in');
                        await FirebaseFirestore.instance
                            .collection('tutors')
                            .doc(user.uid)
                            .update({'tutorId': newId});
                        Navigator.pop(context);
                        setState(() {
                          _tutorData?['tutorId'] = newId;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tutor ID updated!'),
                              backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to update Tutor ID: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    } else {
                      // Update Password
                      final newPass = passwordController.text.trim();
                      final confirmPass = confirmPasswordController.text.trim();
                      if (newPass.isEmpty || confirmPass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password fields cannot be empty.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (newPass != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Passwords do not match.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (newPass.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password must be at least 6 characters.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) throw Exception('Not logged in');
                        await user.updatePassword(newPass);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password updated!'),
                              backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to update password: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  backgroundColor: const Color(0xFF181DB4),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ],
            );
          },
        );
      },
    );
  }
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _tutorData;

  @override
  void initState() {
    super.initState();
    _fetchTutorData();
  }

  Future<void> _fetchTutorData() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('tutors').doc(user.uid).get();
    setState(() {
      _tutorData = doc.data();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF181DB4);
    final Color accentColor = const Color(0xFFFFBA31);
    final Color cardColor = const Color(0xFFF8F8FC);
    return Scaffold(
      backgroundColor: cardColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tutorData == null
              ? const Center(child: Text('No profile data found.', style: TextStyle(fontSize: 16, color: Colors.black54)))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 220,
                      backgroundColor: primaryColor,
                      iconTheme: const IconThemeData(color: Colors.white),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person, size: 54, color: primaryColor),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                (() {
                                  final name = _tutorData?['name'];
                                  if (name is String && name.trim().isNotEmpty) {
                                    return name;
                                  } else {
                                    return 'No Name';
                                  }
                                })(),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _tutorData?['email'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.badge, color: Color(0xFF181DB4)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Tutor ID: ${_tutorData?['tutorId'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 18),
                              // const Text('Bio:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              // const SizedBox(height: 6),
                              // Text(
                              //   _tutorData?['bio'] ?? 'No bio provided.',
                              //   style: const TextStyle(fontSize: 15, color: Colors.black87),
                              // ),
                              const SizedBox(height: 32),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.edit, color: Colors.black, size: 20),
                                    label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.black,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      final nameController = TextEditingController(text: _tutorData?['name'] ?? '');
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Edit Name'),
                                          content: TextField(
                                            controller: nameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Tutor Name',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final newName = nameController.text.trim();
                                                if (newName.isEmpty) return;
                                                final user = FirebaseAuth.instance.currentUser;
                                                if (user == null) return;
                                                await FirebaseFirestore.instance
                                                    .collection('tutors')
                                                    .doc(user.uid)
                                                    .update({'name': newName});
                                                setState(() {
                                                  _tutorData?['name'] = newName;
                                                });
                                                Navigator.of(context).pop();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Name updated!'), backgroundColor: Colors.green),
                                                );
                                              },
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.lock, color: Colors.white, size: 20),
                                    label: const Text('Update Passcode', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurpleAccent,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: _showUpdatePasscodeDialog,
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                                    label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      if (context.mounted) {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) => const TutorLoginScreen()),
                                          (route) => false,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({Key? key}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  DateTime? _birthDate;
  String? _gender;
  String? _bloodGroup;
  String? _photoUrl;
  File? _imageFile;
  int? _age;
  bool _isLoading = false;
  bool _isInitialDataLoaded = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!_isInitialDataLoaded && userDoc.exists) {
          setState(() {
            _fullNameController.text = userDoc.get('name') ?? '';
            _contactController.text = userDoc.get('contact') ?? '';
            _weightController.text = userDoc.get('weight')?.toString() ?? '';
            _heightController.text = userDoc.get('height')?.toString() ?? '';
            _gender = userDoc.get('gender');
            _bloodGroup = userDoc.get('bloodGroup');
            _photoUrl = userDoc.get('photoUrl');

            if (userDoc.data()!.containsKey('birthDate')) {
              String birthDateStr = userDoc.get('birthDate');
              _birthDate = DateTime.parse(birthDateStr);
              _age = _calculateAge(_birthDate!);
            }

            _isInitialDataLoaded = true;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_photos')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = await storageRef.putFile(
          _imageFile!,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'userId': user.uid},
          ),
        );

        if (uploadTask.state == TaskState.success) {
          final downloadUrl = await storageRef.getDownloadURL();

          if (_photoUrl != null) {
            try {
              final oldImageRef = FirebaseStorage.instance.refFromURL(_photoUrl!);
              await oldImageRef.delete();
            } catch (e) {
              print('Error deleting old image: $e');
            }
          }

          setState(() {
            _photoUrl = downloadUrl;
          });

          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'photoUrl': downloadUrl});
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfileDetails() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final details = {
          'fullName': _fullNameController.text.trim(),
          'contact': _contactController.text.trim(),
          'weight': _weightController.text.trim(),
          'height': _heightController.text.trim(),
          'gender': _gender,
          'bloodGroup': _bloodGroup,
          'birthDate': _birthDate?.toIso8601String(),
          'age': _age,
          'lastUpdated': FieldValue.serverTimestamp(),
          if (_photoUrl != null) 'photoUrl': _photoUrl,
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .update(details);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
        _age = _calculateAge(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Personal Profile'),
        backgroundColor: const Color(0xFFA3DAE5),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoSection(),
                  const SizedBox(height: 25),
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactController,
                    label: 'Contact',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          icon: Icons.monitor_weight,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          icon: Icons.height,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    value: _gender,
                    items: ['Male', 'Female', 'Other'],
                    hint: 'Select Gender',
                    icon: Icons.person_outline,
                    onChanged: (String? value) {
                      setState(() => _gender = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    value: _bloodGroup,
                    items: _bloodGroups,
                    hint: 'Select Blood Group',
                    icon: Icons.bloodtype,
                    onChanged: (String? value) {
                      setState(() => _bloodGroup = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDateSelector(),
                  if (_age != null) ...[
                    const SizedBox(height: 16),
                    _buildAgeChip(),
                  ],
                  const SizedBox(height: 25),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!) as ImageProvider
                : (_photoUrl != null
                ? NetworkImage(_photoUrl!)
                : null),
            child: _photoUrl == null && _imageFile == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(hint),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectBirthDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              _birthDate != null
                  ? DateFormat('yyyy-MM-dd').format(_birthDate!)
                  : 'Select Date of Birth',
              style: TextStyle(
                color: _birthDate != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Age: $_age years',
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfileDetails,
        style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
    ),
    ),
    child: _isLoading
    ? const CircularProgressIndicator(color: Colors.white)
        : const Text(
      'Save Changes',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
        ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
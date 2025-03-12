import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({Key? key}) : super(key: key);

  @override
  _DoctorDetailsPageState createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  String? _photoUrl;
  File? _imageFile;
  bool _isLoading = false;
  bool _hasExistingData = false;

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'contact': TextEditingController(),
    'specialization': TextEditingController(),
    'experience': TextEditingController(),
    'hospital': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadDoctorData() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('doctors').doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          setState(() {
            _controllers.forEach((key, controller) {
              controller.text = data[key]?.toString() ?? '';
            });
            _photoUrl = data['photoUrl'];
            _hasExistingData = true;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _photoUrl;

    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('doctor_photos/${user.uid}');
      final uploadTask = await ref.putFile(_imageFile!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      _showErrorSnackBar('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateProfileDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final photoUrl = await _uploadImage();

        final details = {
          'name': _controllers['name']!.text.trim(),
          'contact': _controllers['contact']!.text.trim(),
          'specialization': _controllers['specialization']!.text.trim(),
          'experience': _controllers['experience']!.text.trim(),
          'hospital': _controllers['hospital']!.text.trim(),
          'photoUrl': photoUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('doctors').doc(user.uid).set(details, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _hasExistingData = true);
      }
    } catch (e) {
      _showErrorSnackBar('Error updating profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPhotoSection(),
                  const SizedBox(height: 24),
                  if (_hasExistingData || _controllers['name']!.text.isNotEmpty)
                    ..._buildFormFields(),
                  if (!_hasExistingData && _controllers['name']!.text.isEmpty)
                    _buildEmptyState(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _getProfileImage(),
              child: _showDefaultIcon() ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 140,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: _pickImage,
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (_imageFile != null) return FileImage(_imageFile!);
    if (_photoUrl != null) return NetworkImage(_photoUrl!);
    return null;
  }

  bool _showDefaultIcon() {
    return _imageFile == null && _photoUrl == null;
  }

  List<Widget> _buildFormFields() {
    final fields = [
      ('name', 'Full Name', Icons.person, TextInputType.name),
      ('contact', 'Contact Number', Icons.phone, TextInputType.phone),
      ('specialization', 'Specialization', Icons.medical_services, TextInputType.text),
      ('experience', 'Experience (Years)', Icons.work, TextInputType.number),
      ('hospital', 'Hospital/Clinic', Icons.local_hospital, TextInputType.text),
    ];

    return fields.map((field) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _buildTextField(
          controller: _controllers[field.$1]!,
          label: field.$2,
          icon: field.$3,
          keyboardType: field.$4,
        ),
      );
    }).toList();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Profile Details Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your professional details to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _updateProfileDetails,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Text(
        'Save Changes',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
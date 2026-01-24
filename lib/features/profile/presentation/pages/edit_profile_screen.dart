import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:peerpicks/common/app_colors.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;

  File? _imageFile;
  DateTime? _selectedDate;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userSession = ref.read(userSessionServiceProvider);

    _nameController = TextEditingController(
      text: userSession.getCurrentUserFullName(),
    );
    _emailController = TextEditingController(
      text: userSession.getCurrentUserEmail(),
    );
    _selectedDate = userSession.getCurrentUserDob();

    _dobController = TextEditingController(
      text: _selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
          : '',
    );

    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // --- IMAGE PICKING LOGIC ---

  Future<void> _showPickOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Profile Photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primaryGreen,
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _handleImagePick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primaryGreen,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _handleImagePick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImagePick(ImageSource source) async {
    PermissionStatus status = source == ImageSource.camera
        ? await Permission.camera.request()
        : (Platform.isAndroid
              ? await Permission.photos.request()
              : await Permission.photos.request());

    if (status.isGranted) {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 75,
      );
      if (pickedFile != null)
        setState(() => _imageFile = File(pickedFile.path));
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Please enable permissions in settings to change your photo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: openAppSettings, child: const Text('Settings')),
        ],
      ),
    );
  }

  void _handleLogout() async {
    await ref.read(userSessionServiceProvider).clearSession();
    if (mounted) {
      // Navigate to Login Screen and clear navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired. Please login again.")),
      );
    }
  }

  // --- UPDATED API UPLOAD LOGIC ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userSession = ref.read(userSessionServiceProvider);
    final String? token = userSession.getToken();

    try {
      // 1. CONVERT DATE FORMAT
      // Assuming your controller has "DD/MM/YYYY", we must convert it.
      // If you have a DateTime object from a date picker, use:
      // String formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      // For now, let's try to parse what's in your controller:
      String rawDate = _dobController.text.trim();
      String formattedDob;

      try {
        // If the controller is "22/01/2000", this splits and rearranges it to "2000-01-22"
        List<String> parts = rawDate.split('/');
        if (parts.length == 3) {
          formattedDob = "${parts[2]}-${parts[1]}-${parts[0]}";
        } else {
          formattedDob = rawDate; // Fallback if already formatted
        }
      } catch (e) {
        formattedDob = rawDate;
      }

      // 2. PREPARE DATA
      FormData formData = FormData.fromMap({
        "fullName": _nameController.text.trim(),
        "dob": formattedDob, // MUST be YYYY-MM-DD
      });

      if (_imageFile != null) {
        formData.files.add(
          MapEntry(
            "profilePicture",
            await MultipartFile.fromFile(_imageFile!.path),
          ),
        );
      }

      // 3. SEND PUT REQUEST
      final response = await Dio().put(
        "${ApiEndpoints.baseUrl}auth/update-profile",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final updatedUser = response.data['data'];
        await userSession.updateProfileDetails(
          fullName: updatedUser['fullName'],
          dob: updatedUser['dob'],
          profilePicture: updatedUser['profilePicture'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile Updated!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } on DioException catch (e) {
      debugPrint("BACKEND ERROR: ${e.response?.data}");
      // ... error handling logic ...
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSection(ref),
              const SizedBox(height: 40),
              _buildTextField(
                'Full Name',
                _nameController,
                Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Email Address',
                _emailController,
                Icons.email_outlined,
                enabled: false,
              ),
              const SizedBox(height: 20),
              _buildDateField(),
              const SizedBox(height: 40),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(WidgetRef ref) {
    final String name = _nameController.text.trim();
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    // CORRECT: Get the instance from the provider
    final userSession = ref.watch(userSessionServiceProvider);
    final String? serverImagePath = userSession.getCurrentUserProfilePicture();

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primaryGreen,
            child: CircleAvatar(
              radius: 57,
              backgroundColor: AppColors.fieldFill,
              // Priority: 1. Locally picked image, 2. Server image, 3. Initials
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : (serverImagePath != null
                            ? NetworkImage(
                                "${ApiEndpoints.serverBaseUrl}$serverImagePath",
                              )
                            : null)
                        as ImageProvider?,
              child: (_imageFile == null && serverImagePath == null)
                  ? Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showPickOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.darkText,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.fieldFill,
            prefixIcon: Icon(icon, color: AppColors.primaryGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
              });
            }
          },
          child: IgnorePointer(
            child: TextFormField(
              controller: _dobController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryGreen,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'UPDATE PROFILE',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

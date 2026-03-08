import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:peerpicks/core/utils/snackbar_utils.dart';
import 'package:peerpicks/features/picks/presentation/state/picks_state.dart';
import 'package:peerpicks/features/picks/presentation/view_model/picks_viewmodel.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  const AddReviewScreen({super.key});

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _mapController = MapController();

  double _stars = 3.0;
  final List<File> _mediaFiles = [];
  bool _isSubmitting = false;

  // Default location (Kathmandu)
  LatLng _selectedLocation = const LatLng(27.7172, 85.3240);
  bool _locationPicked = false;

  final _categories = [
    'Restaurant',
    'Cafe',
    'Bar',
    'Hotel',
    'Park',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _aliasController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    if (_mediaFiles.length >= 5) {
      SnackbarUtils.showInfo(context, 'Maximum 5 media files allowed');
      return;
    }

    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Media',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.photo_library, color: cs.primary),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final images = await picker.pickMultiImage(
                      imageQuality: 80,
                      maxWidth: 1920,
                    );
                    if (images.isNotEmpty) {
                      setState(() {
                        for (final img in images) {
                          if (_mediaFiles.length < 5) {
                            _mediaFiles.add(File(img.path));
                          }
                        }
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: cs.primary),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final photo = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (photo != null) {
                      setState(() => _mediaFiles.add(File(photo.path)));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam, color: cs.primary),
                  title: const Text('Record Video'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final video = await picker.pickVideo(
                      source: ImageSource.camera,
                      maxDuration: const Duration(seconds: 60),
                    );
                    if (video != null) {
                      setState(() => _mediaFiles.add(File(video.path)));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await ref
        .read(picksViewModelProvider.notifier)
        .createPick(
          alias: _aliasController.text.trim(),
          lat: _selectedLocation.latitude,
          lng: _selectedLocation.longitude,
          description: _descriptionController.text.trim(),
          stars: _stars,
          mediaFiles: _mediaFiles,
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text.trim()
              : null,
        );

    setState(() => _isSubmitting = false);
  }

  void _openMapPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        LatLng tempLocation = _selectedLocation;
        final sheetCs = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheetCs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title + coordinates
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Pick Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${tempLocation.latitude.toStringAsFixed(4)}, ${tempLocation.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: sheetCs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Tap on the map to select location',
                      style: TextStyle(
                        fontSize: 13,
                        color: sheetCs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Map
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: tempLocation,
                          initialZoom: 15,
                          onTap: (tapPos, latLng) {
                            setModalState(() => tempLocation = latLng);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.peerpicks.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: tempLocation,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF75A638),
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Confirm button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedLocation = tempLocation;
                            _locationPicked = true;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sheetCs.primary,
                          foregroundColor: sheetCs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm Location',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
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
    final cs = Theme.of(context).colorScheme;
    // Listen for picks state changes
    ref.listen<PicksState>(picksViewModelProvider, (previous, next) {
      if (next.status == PicksStatus.created) {
        SnackbarUtils.showSuccess(context, 'Review created successfully!');
        _formKey.currentState?.reset();
        _aliasController.clear();
        _descriptionController.clear();
        _categoryController.clear();
        setState(() {
          _mediaFiles.clear();
          _stars = 3.0;
          _locationPicked = false;
          _selectedLocation = const LatLng(27.7172, 85.3240);
        });
      } else if (next.status == PicksStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Failed to create review',
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Add Review',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Place Name
              _buildLabel(
                'Place Name',
                cs,
                icon: Icons.storefront_rounded,
                subtitle: 'Enter the name of the place you\'re reviewing',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _aliasController,
                decoration: _inputDecoration(
                  'e.g. Cafe Mitra, Park Street',
                  cs,
                  prefixIcon: Icons.edit_location_alt_outlined,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Place name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category
              _buildLabel(
                'Category',
                cs,
                icon: Icons.category_rounded,
                subtitle: 'What type of place is this?',
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration(
                  'Select category',
                  cs,
                  prefixIcon: Icons.grid_view_rounded,
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  _categoryController.text = val ?? '';
                },
              ),
              const SizedBox(height: 24),

              // Location Map
              _buildLabel(
                'Location',
                cs,
                icon: Icons.map_rounded,
                subtitle: 'Tap the map to pin the exact location',
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _openMapPicker,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        IgnorePointer(
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _selectedLocation,
                              initialZoom: 14,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.peerpicks.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _selectedLocation,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF75A638),
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Overlay to indicate tappable
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _locationPicked
                                        ? Icons.check_circle
                                        : Icons.touch_app,
                                    size: 14,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _locationPicked
                                        ? 'Location selected'
                                        : 'Tap to pick location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_locationPicked)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 24),

              // Star Rating
              _buildLabel(
                'Rating',
                cs,
                icon: Icons.star_rounded,
                subtitle: 'How would you rate this place?',
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final isActive = _stars >= starValue;
                        return GestureDetector(
                          onTap: () => setState(() => _stars = starValue),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              isActive
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 44,
                              color: isActive
                                  ? const Color(0xFFFFB800)
                                  : cs.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _ratingLabel(_stars),
                      style: TextStyle(
                        fontSize: 15,
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_stars.toInt()} / 5',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description
              _buildLabel(
                'Your Review',
                cs,
                icon: Icons.rate_review_rounded,
                subtitle: 'Tell others what makes this place special (or not)',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 3000,
                decoration: _inputDecoration(
                  'What did you love? What could be better? Share details about the food, service, ambience...',
                  cs,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please write a review';
                  }
                  if (val.trim().length < 10) {
                    return 'Review must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Media
              _buildLabel(
                'Photos & Videos (${_mediaFiles.length}/5)',
                cs,
                icon: Icons.photo_camera_rounded,
                subtitle: 'Add up to 5 photos or videos to support your review',
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.5),
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: cs.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Add Media',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ..._mediaFiles.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final file = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(file),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _mediaFiles.removeAt(idx));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text,
    ColorScheme cs, {
    IconData? icon,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    ColorScheme cs, {
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: cs.onSurfaceVariant, size: 20)
          : null,
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  String _ratingLabel(double stars) {
    switch (stars.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

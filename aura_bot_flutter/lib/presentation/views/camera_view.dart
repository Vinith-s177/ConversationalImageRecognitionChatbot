import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aura_bot_flutter/core/theme/anti_gravity_theme.dart';
import 'package:aura_bot_flutter/presentation/widgets/glass_card.dart';

class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraView({super.key, required this.cameras});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;
  double _currentZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  bool _isScanningMode = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize().then((_) async {
      _maxZoomLevel = await _controller.getMaxZoomLevel();
      _minZoomLevel = await _controller.getMinZoomLevel();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (!_controller.value.isInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller.setFlashMode(FlashMode.off);
      } else {
        await _controller.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint("Error toggling flash: $e");
    }
  }

  Future<void> _capturePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      if (mounted) {
        Navigator.pop(context, XFile(image.path));
      }
    } catch (e) {
      debugPrint("Error capturing photo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Live Viewfinder
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),

                // Scanning HUD overlay (if scanning mode is enabled)
                if (_isScanningMode)
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: AntiGravityTheme.neonCyan, width: 2.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2.0,
                              color: AntiGravityTheme.neonCyan,
                              // Scanning laser animation placeholder
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Top Panel (Back, Flash, Scan Mode toggler)
                Positioned(
                  top: 48,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: _isFlashOn ? AntiGravityTheme.neonCyan : Colors.white,
                              size: 28,
                            ),
                            onPressed: _toggleFlash,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner,
                              color: _isScanningMode ? AntiGravityTheme.neonCyan : Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                _isScanningMode = !_isScanningMode;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Zoom Control Slider
                Positioned(
                  right: 16,
                  bottom: 150,
                  top: 150,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: _currentZoomLevel,
                      min: _minZoomLevel,
                      max: _maxZoomLevel,
                      activeColor: AntiGravityTheme.neonCyan,
                      inactiveColor: Colors.white24,
                      onChanged: (value) async {
                        setState(() {
                          _currentZoomLevel = value;
                        });
                        await _controller.setZoomLevel(value);
                      },
                    ),
                  ),
                ),

                // Bottom Panel Buttons
                Positioned(
                  bottom: 48,
                  left: 32,
                  right: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery picker shortcut
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white, size: 36),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(source: ImageSource.gallery);
                          if (file != null && mounted) {
                            Navigator.pop(context, file);
                          }
                        },
                      ),

                      // Capture Trigger
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4.0),
                          ),
                          child: Center(
                            child: Container(
                              height: 64,
                              width: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Camera flipping placeholder
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 36),
                        onPressed: () {
                          // Swap front/back camera if multiple are available
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: AntiGravityTheme.neonCyan),
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../provider/upi_provider.dart';
import 'send_money_screen.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scanAnimation;
  final TextEditingController _manualUpiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _manualUpiController.dispose();
    super.dispose();
  }

  void _handleManualUpi(BuildContext context) {
    final upi = _manualUpiController.text.trim();
    if (upi.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<UpiProvider>(),
          child: SendMoneyScreen(prefillUpiId: upi),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Toggle torch with mobile_scanner
            },
          ),
        ],
      ),
      body: Column(
        children: [

          // ── Camera viewfinder ──────────────────────────────────
          Expanded(
            child: Stack(
              children: [

                // Camera background
                // TODO: Replace Container with MobileScanner widget
                // MobileScanner(onDetect: (capture) { ... })
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: Text(
                      'Camera Preview\n(Add mobile_scanner package)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Scan frame overlay
                Center(
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      children: [
                        // Corner borders
                        ..._buildScanCorners(),

                        // Animated scan line
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (_, _) => Positioned(
                            top: _scanAnimation.value * 220,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary,
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Instructions
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Align QR code within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Manual UPI entry ───────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Or enter UPI ID manually',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualUpiController,
                        decoration: InputDecoration(
                          hintText: 'name@bank',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
                              size: 20, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _handleManualUpi(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Pay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Scan frame corners ─────────────────────────────────────────
  List<Widget> _buildScanCorners() {
    const size = 28.0;
    const thickness = 4.0;

    Widget corner(double top, double left, double top2, double left2,
        double top3, double left3) {
      return Stack(
        children: [
          Positioned(
            top: top,
            left: left,
            child: Container(
              width: size,
              height: thickness,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            top: top2,
            left: left2,
            child: Container(
              width: thickness,
              height: size,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }

    return [
      corner(0, 0, 0, 0, 0, 0),                           // top-left
      corner(0, 212, 0, 236, 0, 236),                      // top-right
      corner(236, 0, 212, 0, 212, 0),                      // bottom-left
      corner(236, 212, 212, 236, 212, 236),                 // bottom-right
    ];
  }
}
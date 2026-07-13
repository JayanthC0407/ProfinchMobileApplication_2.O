import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/dashboard/provider/dashboard_provider.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';

enum PatternScreenMode { setup, login }

class PatternScreen extends StatefulWidget {
  final PatternScreenMode mode;

  const PatternScreen({super.key, required this.mode});

  @override
  State<PatternScreen> createState() => _PatternScreenState();
}

class _PatternScreenState extends State<PatternScreen> {
  // 3x3 grid — index 0-8
  static const int _gridSize = 3;
  static const int _minPoints = 4;

  final List<int> _selected = [];
  final List<int> _firstPattern = [];
  bool _confirming = false;
  bool _hasError = false;
  String _errorMessage = '';
  Offset? _currentTouch;

  // Center positions of each dot (populated in layout)
  final List<Offset> _dotCenters = List.filled(9, Offset.zero);
  final GlobalKey _gridKey = GlobalKey();

  void _reset() {
    setState(() {
      _selected.clear();
      _currentTouch = null;
      _hasError = false;
      _errorMessage = '';
    });
  }

  void _onPanStart(DragStartDetails d) {
    _reset();
    _checkHit(d.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _currentTouch = d.localPosition);
    _checkHit(d.localPosition);
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() => _currentTouch = null);
    if (_selected.length >= _minPoints) {
      _handlePatternComplete();
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Connect at least $_minPoints dots';
      });
      Future.delayed(const Duration(milliseconds: 800), _reset);
    }
  }

  void _checkHit(Offset pos) {
    for (int i = 0; i < 9; i++) {
      if (_selected.contains(i)) continue;
      final dist = (_dotCenters[i] - pos).distance;
      if (dist < 26) {
        setState(() => _selected.add(i));
        break;
      }
    }
  }

  Future<void> _handlePatternComplete() async {
    final pattern = List<int>.from(_selected);
    final authProvider = context.read<AuthProvider>();

    if (widget.mode == PatternScreenMode.login) {
      final ok = authProvider.verifyPattern(pattern);
      if (ok) {
        final user = authProvider.currentUser;
        if (user != null) {
          context.read<DashboardProvider>().resetToPrimary(user.primaryAccountId);
        }
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.dashboard, (route) => false);
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Incorrect pattern. Try again.';
        });
        await Future.delayed(const Duration(milliseconds: 800));
        _reset();
      }
      return;
    }

    // Setup mode
    if (!_confirming) {
      setState(() {
        _firstPattern.clear();
        _firstPattern.addAll(pattern);
        _confirming = true;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      _reset();
    } else {
      final matches = _listEquals(pattern, _firstPattern);
      if (matches) {
        authProvider.setPattern(_firstPattern);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pattern set successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = "Patterns don't match. Start again.";
          _confirming = false;
          _firstPattern.clear();
        });
        await Future.delayed(const Duration(milliseconds: 800));
        _reset();
      }
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLogin = widget.mode == PatternScreenMode.login;

    final title = isLogin
        ? 'Draw your pattern'
        : (_confirming ? 'Confirm pattern' : 'Draw a new pattern');

    final subtitle = isLogin
        ? 'Draw the unlock pattern'
        : (_confirming
            ? 'Draw the same pattern to confirm'
            : 'Connect at least $_minPoints dots in order');

    return BackgroundWrapper(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),

            if (isLogin) ...[
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  (authProvider.patternUsername ?? 'User')
                    .trim()
                    .split(' ')
                    .where((e) => e.isNotEmpty)
                    .take(2)
                    .map((e) => e[0].toUpperCase())
                    .join(),
                  style: TextStyle(
                      fontSize: AppFontSize.large(context),
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                authProvider.patternUsername ?? '',
                style: TextStyle(
                    fontSize: AppFontSize.large(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
            ],

            Text(title,
                style: TextStyle(
                    fontSize: AppFontSize.xl(context),
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: AppFontSize.body(context),
                    color: Colors.white.withValues(alpha: 0.65))),

            const SizedBox(height: 8),

            if (_hasError)
              Text(_errorMessage,
                  style: TextStyle(
                      fontSize: AppFontSize.small(context),
                      color: Colors.red.shade300))
            else
              const SizedBox(height: 18),

            const Spacer(),

            // ── Pattern grid ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    key: _gridKey,
                    painter: _PatternPainter(
                      selected: _selected,
                      dotCenters: _dotCenters,
                      currentTouch: _currentTouch,
                      hasError: _hasError,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cellW = constraints.maxWidth / _gridSize;
                        final cellH = constraints.maxHeight / _gridSize;
                        for (int r = 0; r < _gridSize; r++) {
                          for (int c = 0; c < _gridSize; c++) {
                            _dotCenters[r * _gridSize + c] = Offset(
                              cellW * c + cellW / 2,
                              cellH * r + cellH / 2,
                            );
                          }
                        }
                        return const SizedBox.expand();
                      },
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            if (isLogin) ...[
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (route) => false),
                child: Text(
                  'Use password instead',
                  style: TextStyle(
                      fontSize: AppFontSize.body(context),
                      color: Colors.white.withValues(alpha: 0.6),
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withValues(alpha: 0.6)),
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              TextButton(
                onPressed: _reset,
                child: Text('Reset',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: AppFontSize.body(context))),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<int> selected;
  final List<Offset> dotCenters;
  final Offset? currentTouch;
  final bool hasError;

  _PatternPainter({
    required this.selected,
    required this.dotCenters,
    required this.currentTouch,
    required this.hasError,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activeColor = hasError ? Colors.red.shade400 : AppColors.primary;
    final inactiveColor = Colors.white.withOpacity(0.3);

    final linePaint = Paint()
      ..color = activeColor.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Draw lines between selected dots
    for (int i = 0; i < selected.length - 1; i++) {
      canvas.drawLine(
        dotCenters[selected[i]],
        dotCenters[selected[i + 1]],
        linePaint,
      );
    }

    // Draw line from last selected dot to current touch
    if (selected.isNotEmpty && currentTouch != null) {
      canvas.drawLine(dotCenters[selected.last], currentTouch!, linePaint);
    }

    // Draw dots
    for (int i = 0; i < 9; i++) {
      final isSelected = selected.contains(i);

      // Outer ring
      canvas.drawCircle(
        dotCenters[i],
        20,
        Paint()
          ..color = isSelected
              ? activeColor.withOpacity(0.15)
              : inactiveColor.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );

      // Border ring
      canvas.drawCircle(
        dotCenters[i],
        20,
        Paint()
          ..color = isSelected ? activeColor : Colors.white.withOpacity(0.4)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );

      // Center dot
      canvas.drawCircle(
        dotCenters[i],
        isSelected ? 8 : 5,
        Paint()
          ..color = isSelected ? activeColor : Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill,
      );

      // Order number on selected dots
      if (isSelected) {
        // final order = selected.indexOf(i) + 1;
        final tp = TextPainter(
          text: TextSpan(
            // text: '$order',
            style: const TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            dotCenters[i] - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) =>
      old.selected != selected ||
      old.currentTouch != currentTouch ||
      old.hasError != hasError;
}
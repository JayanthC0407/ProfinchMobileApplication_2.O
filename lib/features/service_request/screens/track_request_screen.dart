import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// ⚠️ STUB. You described the "Raise a new request" flow in detail (6
/// endpoints, confirmed responses) but not "Track Request" — no captured
/// requests for it yet, so there's nothing to wire up here. This exists
/// only so [AppRoutes.trackRequest] has somewhere to land instead of
/// crashing. Once you can share the Track Request flow the same way
/// (endpoints + a couple of real responses), this becomes a real screen.
class TrackRequestScreen extends StatelessWidget {
  const TrackRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Track Request'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Track Request isn't wired up yet — this screen is a "
            'placeholder until the API flow for it is confirmed.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

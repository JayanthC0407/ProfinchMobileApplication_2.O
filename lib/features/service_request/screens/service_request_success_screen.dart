import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/fonts_size.dart';
import '../../../core/routes/app_routes.dart';
import '../provider/service_request_provider.dart';

/// The confirmation screen shown after a successful submission — matches
/// the base app's two options: track the request, or go back home.
class ServiceRequestSuccessScreen extends StatelessWidget {
  const ServiceRequestSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.watch<ServiceRequestProvider>().submissionResult;

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: AppColors.light, size: 46),
              ),
              const SizedBox(height: 24),
              Text(
                'Request Submitted',
                style: TextStyle(
                  fontSize: AppFontSize.xl(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (result != null && result.displayReferenceNumber.isNotEmpty)
                Text(
                  'Reference number: ${result.displayReferenceNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSize.body(context),
                    color: AppColors.textMuted,
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ServiceRequestProvider>().reset();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.trackRequest,
                      (route) => route.settings.name == AppRoutes.dashboard,
                    );
                  },
                  child: const Text('Track Request'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ServiceRequestProvider>().reset();
                    Navigator.popUntil(
                      context,
                      (route) => route.settings.name == AppRoutes.dashboard,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

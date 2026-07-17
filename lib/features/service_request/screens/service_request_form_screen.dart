import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/fonts_size.dart';
import '../../../core/routes/app_routes.dart';
import '../provider/service_request_provider.dart';

/// Shown after picking a definition from [RaiseRequestScreen]. Loads the
/// full definition (icon + infoNote) on open, collects the free-text
/// description, shows a confirm dialog on Submit, then does the real POST
/// only after the user confirms.
class ServiceRequestFormScreen extends StatefulWidget {
  final String definitionId;

  const ServiceRequestFormScreen({super.key, required this.definitionId});

  @override
  State<ServiceRequestFormScreen> createState() =>
      _ServiceRequestFormScreenState();
}

class _ServiceRequestFormScreenState extends State<ServiceRequestFormScreen> {
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<ServiceRequestProvider>()
            .loadDefinitionDetail(widget.definitionId);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitPressed() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Request'),
        content: const Text(
            "You're about to submit this service request. Continue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<ServiceRequestProvider>();
    final success = await provider.submit(
      definitionId: widget.definitionId,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(
          context, AppRoutes.serviceRequestSuccess);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitError ?? 'Submission failed.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceRequestProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Service Request'),
      ),
      body: provider.isLoadingDefinitionDetail
          ? const Center(child: CircularProgressIndicator())
          : provider.definitionDetailLoadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.orange, size: 32),
                      const SizedBox(height: 8),
                      const Text("Couldn't load this service."),
                      TextButton(
                        onPressed: () => provider
                            .loadDefinitionDetail(widget.definitionId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildForm(context, provider),
    );
  }

  Widget _buildForm(BuildContext context, ServiceRequestProvider provider) {
    final def = provider.selectedDefinition;
    final infoNote = def?.form?.infoNote;
    final icon = provider.selectedIcon;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                if (icon != null && icon.isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(icon.bytes,
                        width: 56, height: 56, fit: BoxFit.cover),
                  ),
                if (icon != null && icon.isImage) const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def?.name ?? '',
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: AppFontSize.large(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (infoNote != null && infoNote.header.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${infoNote.header} ${infoNote.description}'
                                .trim(),
                            style: TextStyle(
                              color: AppColors.light.withValues(alpha: 0.85),
                              fontSize: AppFontSize.small(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: TextStyle(
              fontSize: AppFontSize.body(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Describe your request…',
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isSubmitting ? null : _onSubmitPressed,
              child: provider.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

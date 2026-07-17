import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/fonts_size.dart';
import '../provider/service_request_provider.dart';
import 'service_request_form_screen.dart';

/// The "Raise a new request" screen — a search field over the list of
/// service request definitions. Confirmed flow: opening this screen fires
/// GET definitions + GET categories together (see
/// `ServiceRequestProvider.loadDefinitions`); tapping a result loads its
/// full detail (with icon) on the next screen.
class RaiseRequestScreen extends StatefulWidget {
  const RaiseRequestScreen({super.key});

  @override
  State<RaiseRequestScreen> createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ServiceRequestProvider>().loadDefinitions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceRequestProvider>(context);

    final filtered = provider.definitions.where((d) {
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      return d.name.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q) ||
          d.categoryType.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Raise a New Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search for a service (e.g. "Activate")',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(provider, filtered)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ServiceRequestProvider provider,
    List filtered,
  ) {
    if (provider.isLoadingDefinitions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.definitionsLoadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.orange, size: 32),
            const SizedBox(height: 8),
            const Text("Couldn't load services."),
            TextButton(
              onPressed: () => provider.loadDefinitions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _query.trim().isEmpty
              ? 'No services available.'
              : 'No matches for "$_query".',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final def = filtered[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceRequestFormScreen(definitionId: def.id),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_outlined,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.name,
                        style: TextStyle(
                          fontSize: AppFontSize.medium(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (def.categoryType.isNotEmpty)
                        Text(
                          def.categoryType,
                          style: TextStyle(
                            fontSize: AppFontSize.small(context),
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}

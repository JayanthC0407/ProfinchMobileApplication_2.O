import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/fonts_size.dart';
import '../provider/service_request_provider.dart';

/// The Track Request filter form + results list. Confirmed flow: opening
/// this screen fires GET products + GET status-enum together; picking a
/// product fires GET categories for that product; Apply fires a GET on
/// the service request list endpoint with categoryType/product/status
/// query params (only the ones actually selected — see the note on
/// [_onApply]).
class TrackRequestScreen extends StatefulWidget {
  const TrackRequestScreen({super.key});

  @override
  State<TrackRequestScreen> createState() => _TrackRequestScreenState();
}

class _TrackRequestScreenState extends State<TrackRequestScreen> {
  String? _selectedProduct;
  String? _selectedCategory;
  String? _selectedStatusCode;
  String? _selectedStatusDescription;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ServiceRequestProvider>().loadTrackFilters();
    });
  }

  void _onProductChanged(String? product) {
    setState(() {
      _selectedProduct = product;
      _selectedCategory = null;
    });
    if (product != null) {
      context.read<ServiceRequestProvider>().loadCategoriesForProduct(product);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  /// ⚠️ Only sends `categoryType`/`product`/`status` when actually
  /// selected — the one real captured query had all three set, so
  /// whether omitting one is valid server-side isn't confirmed the same
  /// way the rest of this flow is, but it's the standard/expected
  /// behavior for a filter form (an unset filter usually means "don't
  /// filter on this"), so it's a much safer assumption than most of the
  /// other guesses flagged elsewhere in this module.
  ///
  /// From/To Date are collected in the UI (matches your screenshots) but
  /// deliberately **not sent** — the captured query had no date params at
  /// all, so the expected key names are unconfirmed. Capture a query
  /// string with the date fields filled in and I'll wire them up.
  void _onApply() {
    context.read<ServiceRequestProvider>().searchTrackRequests(
          categoryType: _selectedCategory ?? '',
          product: _selectedProduct ?? '',
          status: _selectedStatusCode ?? '',
        );
  }

  void _onReset() {
    setState(() {
      _selectedProduct = null;
      _selectedCategory = null;
      _selectedStatusCode = null;
      _selectedStatusDescription = null;
      _fromDate = null;
      _toDate = null;
    });
    context.read<ServiceRequestProvider>().resetTrackFilters();
  }

  String _formatDate(DateTime? date) =>
      date == null ? '' : DateFormat('dd/MM/yyyy').format(date);

  String? _statusDescriptionFor(ServiceRequestProvider provider, String? code) {
    if (code == null) return null;
    for (final s in provider.trackStatuses) {
      if (s.code == code) return s.description;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceRequestProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Track Requests'),
      ),
      body: provider.isLoadingTrackFilters
          ? const Center(child: CircularProgressIndicator())
          : provider.trackFiltersLoadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.orange, size: 32),
                      const SizedBox(height: 8),
                      const Text("Couldn't load filters."),
                      TextButton(
                        onPressed: () =>
                            provider.loadTrackFilters(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterForm(context, provider),
                      const SizedBox(height: 20),
                      _buildResults(context, provider),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFilterForm(BuildContext context, ServiceRequestProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context, 'Product Name'),
          DropdownButtonFormField<String>(
            value: _selectedProduct,
            hint: const Text('Please Select'),
            decoration: _fieldDecoration(),
            items: provider.trackProducts
                .map((p) => DropdownMenuItem(
                      value: p.productName,
                      child: Text(p.productName),
                    ))
                .toList(),
            onChanged: _onProductChanged,
          ),
          const SizedBox(height: 14),
          _fieldLabel(context, 'Category Name'),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedCategory,
            hint: Text(provider.isLoadingTrackCategories
                ? 'Loading…'
                : 'Please Select'),
            decoration: _fieldDecoration(),
            items: provider.trackCategories
                .map((c) => DropdownMenuItem(
                      value: c.categoryName,
                      child: Text(c.categoryName,
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: _selectedProduct == null
                ? null
                : (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(context, 'From Date'),
                    _buildDateField(
                        _fromDate, () => _pickDate(isFrom: true)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(context, 'To Date'),
                    _buildDateField(
                        _toDate, () => _pickDate(isFrom: false)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Date range isn't applied to results yet.",
              style: TextStyle(
                fontSize: AppFontSize.xs(context),
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel(context, 'Status'),
          DropdownButtonFormField<String>(
            value: _selectedStatusCode,
            hint: const Text('Please Select'),
            decoration: _fieldDecoration(),
            items: provider.trackStatuses
                .map((s) => DropdownMenuItem(
                      value: s.code,
                      child: Text(s.description),
                    ))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedStatusCode = v;
              _selectedStatusDescription = _statusDescriptionFor(provider, v);
            }),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onApply,
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _onReset,
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.small(context),
            color: AppColors.textMuted,
          ),
        ),
      );

  InputDecoration _fieldDecoration() => InputDecoration(
        filled: true,
        fillColor: AppColors.light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );

  Widget _buildDateField(DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _fieldDecoration().copyWith(
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          date == null ? 'Select date' : _formatDate(date),
          style: TextStyle(
            color: date == null ? AppColors.textMuted : null,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, ServiceRequestProvider provider) {
    if (provider.isSearchingTrackResults) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.trackSearchError != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.orange, size: 28),
            const SizedBox(height: 6),
            const Text("Couldn't load results."),
          ],
        ),
      );
    }

    if (!provider.hasSearchedTrackRequests) {
      return const SizedBox.shrink();
    }

    if (provider.trackResults.isEmpty) {
      return Column(
        children: [
          _buildFilterSummaryBar(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No Service Request Found',
              style: TextStyle(
                fontSize: AppFontSize.body(context),
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFilterSummaryBar(),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.trackResults.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = provider.trackResults[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.description.isNotEmpty
                  ? item.description
                  : item.categoryType),
              subtitle: Text('${item.product} • ${item.categoryType}'),
              trailing: Text(item.status),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              [
                _selectedProduct,
                _selectedCategory,
                if (_fromDate != null && _toDate != null)
                  '${_formatDate(_fromDate)} - ${_formatDate(_toDate)}',
                _selectedStatusDescription,
              ].where((s) => s != null && s.isNotEmpty).join('   '),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.filter_alt_outlined,
              color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;

import '../models/listing.dart';
import '../theme.dart';
import '../widgets/market_ui.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.listings,
    required this.onOpenListing,
  });

  final List<Listing> listings;
  final Future<void> Function(BuildContext, Listing) onOpenListing;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _filterToggleFocus = FocusNode();
  final _keyword = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  String _selectedCategory = 'All';
  String _appliedCategory = 'All';
  String _query = '';
  double? _minPrice;
  double? _maxPrice;
  bool _showFilters = false;

  int get _filterCount =>
      (_appliedCategory == 'All' ? 0 : 1) +
      (_minPrice == null && _maxPrice == null ? 0 : 1);

  @override
  void dispose() {
    _filterToggleFocus.dispose();
    _keyword.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  double? _parsePrice(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  String? _validatePrice(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final price = _parsePrice(text);
    if (price == null || !price.isFinite || price < 0) {
      return 'Enter a non-negative price.';
    }
    return null;
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;
    _filterToggleFocus.requestFocus();
    setState(() {
      _appliedCategory = _selectedCategory;
      _minPrice = _parsePrice(_min.text);
      _maxPrice = _parsePrice(_max.text);
      _showFilters = false;
    });
  }

  void _clearFilters({bool clearKeyword = false}) {
    if (clearKeyword) _keyword.clear();
    _min.clear();
    _max.clear();
    _filterToggleFocus.requestFocus();
    setState(() {
      _selectedCategory = 'All';
      _appliedCategory = 'All';
      _minPrice = null;
      _maxPrice = null;
      _showFilters = false;
      if (clearKeyword) _query = '';
    });
  }

  void _clearQuery() {
    _keyword.clear();
    setState(() => _query = '');
  }

  bool _matches(Listing listing) {
    final text = '${listing.title} ${listing.description}'.toLowerCase();
    return !listing.isSold &&
        text.contains(_query) &&
        (_appliedCategory == 'All' || listing.category == _appliedCategory) &&
        (_minPrice == null || listing.price >= _minPrice!) &&
        (_maxPrice == null || listing.price <= _maxPrice!);
  }

  String _priceLabel(double price) => price == price.truncateToDouble()
      ? price.toStringAsFixed(0)
      : price.toString();

  // Responsive price fields mount during layout, after the buttons mount.
  Widget _filterControl(double order, Widget child) => FocusTraversalOrder(
    order: NumericFocusOrder(order),
    child: Semantics(
      container: true,
      explicitChildNodes: true,
      sortKey: OrdinalSortKey(order),
      child: child,
    ),
  );

  Widget _priceFields() {
    final minimum = _filterControl(
      4,
      TextFormField(
        controller: _min,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Min price (TRY)',
          errorMaxLines: 2,
        ),
        validator: _validatePrice,
      ),
    );
    final maximum = _filterControl(
      5,
      TextFormField(
        controller: _max,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Max price (TRY)',
          errorMaxLines: 3,
        ),
        onFieldSubmitted: (_) => _apply(),
        validator: (value) {
          final error = _validatePrice(value);
          if (error != null) return error;
          final min = _parsePrice(_min.text);
          final max = _parsePrice(value ?? '');
          if (min != null && min.isFinite && max != null && max < min) {
            return 'Maximum must be at least minimum.';
          }
          return null;
        },
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 340 &&
            MediaQuery.textScalerOf(context).scale(14) <= 18) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: minimum),
              const SizedBox(width: AppSpacing.medium),
              Expanded(child: maximum),
            ],
          );
        }
        return Column(
          children: [
            minimum,
            const SizedBox(height: AppSpacing.medium),
            maximum,
          ],
        );
      },
    );
  }

  Widget _filtersPanel() {
    if (!_showFilters) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: 'Filter options',
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _filterControl(
                  3,
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      for (final category in ['All', ...listingCategories])
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                    ],
                    onChanged: (value) => _selectedCategory = value ?? 'All',
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _priceFields(),
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    _filterControl(
                      6,
                      ElevatedButton(
                        onPressed: _apply,
                        child: const Text('Apply filters'),
                      ),
                    ),
                    _filterControl(
                      7,
                      OutlinedButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.listings.where(_matches).toList();
    final hasCriteria = _query.isNotEmpty || _filterCount > 0;
    final minimum = _minPrice;
    final maximum = _maxPrice;

    return MarketPage(
      title: 'Search & filters',
      child: Form(
        key: _formKey,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FocusTraversalOrder(
                        order: const NumericFocusOrder(0),
                        child: TextFormField(
                          controller: _keyword,
                          decoration: InputDecoration(
                            labelText: 'Keyword',
                            hintText: 'Try textbook or headphones',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _keyword.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear keyword',
                                    onPressed: _clearQuery,
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                          textInputAction: TextInputAction.search,
                          onChanged: (value) => setState(
                            () => _query = value.trim().toLowerCase(),
                          ),
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).unfocus(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Wrap(
                        spacing: AppSpacing.small,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(1),
                            child: Semantics(
                              expanded: _showFilters,
                              child: OutlinedButton.icon(
                                focusNode: _filterToggleFocus,
                                onPressed: () {
                                  _filterToggleFocus.requestFocus();
                                  setState(() => _showFilters = !_showFilters);
                                },
                                icon: Icon(
                                  _showFilters
                                      ? Icons.expand_less_rounded
                                      : Icons.tune_rounded,
                                ),
                                label: Text(
                                  _filterCount == 0
                                      ? 'Filters'
                                      : 'Filters ($_filterCount)',
                                ),
                              ),
                            ),
                          ),
                          if (_filterCount > 0 && !_showFilters)
                            FocusTraversalOrder(
                              order: const NumericFocusOrder(2),
                              child: TextButton(
                                onPressed: _clearFilters,
                                child: const Text('Clear filters'),
                              ),
                            ),
                        ],
                      ),
                      if (MediaQuery.disableAnimationsOf(context))
                        _filtersPanel()
                      else
                        AnimatedSize(
                          alignment: Alignment.topCenter,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          child: _filtersPanel(),
                        ),
                      if (_filterCount > 0 && !_showFilters) ...[
                        const SizedBox(height: AppSpacing.small),
                        Wrap(
                          spacing: AppSpacing.small,
                          runSpacing: AppSpacing.small,
                          children: [
                            if (_appliedCategory != 'All')
                              MarketBadge(label: _appliedCategory),
                            if (minimum != null)
                              MarketBadge(
                                label: 'Min TRY ${_priceLabel(minimum)}',
                              ),
                            if (maximum != null)
                              MarketBadge(
                                label: 'Max TRY ${_priceLabel(maximum)}',
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.large),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: Semantics(
                  container: true,
                  header: true,
                  liveRegion: true,
                  child: Text(
                    '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                    style: AppText.heading,
                  ),
                ),
              ),
            ),
            if (results.isEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EmptyState(
                      icon: Icons.search_off_rounded,
                      message: hasCriteria
                          ? 'No listings match your filters.'
                          : 'No active listings yet.',
                    ),
                    if (hasCriteria)
                      TextButton(
                        onPressed: () => _clearFilters(clearKeyword: true),
                        child: const Text('Clear search and filters'),
                      ),
                  ],
                ),
              )
            else
              SliverList.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final listing = results[index];
                  return Padding(
                    key: ValueKey(listing.id),
                    padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                    child: ListingCard(
                      listing: listing,
                      onTap: () async {
                        await widget.onOpenListing(context, listing);
                        if (mounted) setState(() {});
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

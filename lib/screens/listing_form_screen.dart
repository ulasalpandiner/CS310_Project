import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../theme.dart';
import '../widgets/market_ui.dart';

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({super.key, required this.listingId, this.listing});

  final int listingId;
  final Listing? listing;

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  static const _samplePhotos = {
    'assets/images/textbook-photo.jpg': 'Textbook',
    'assets/images/desk-lamp-photo.jpg': 'Desk lamp',
    'assets/images/dorm-chair-photo.jpg': 'Dorm chair',
    'assets/images/headphones-photo.jpg': 'Headphones',
  };

  final _formKey = GlobalKey<FormState>();
  final _photoSectionKey = GlobalKey();
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late final List<String> _photos;
  String? _category;
  String? _condition;
  bool _submitted = false;

  bool get _isEditing => widget.listing != null;

  double? get _enteredPrice =>
      double.tryParse(_price.text.trim().replaceAll(',', '.'));

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _title = TextEditingController(text: listing?.title);
    _price = TextEditingController(text: listing?.price.toString());
    _description = TextEditingController(text: listing?.description);
    _category = listing?.category;
    _condition = listing?.condition;
    _photos = List<String>.of(listing?.photos ?? []);
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Choose a sample photo'),
        children: [
          for (final photo in _samplePhotos.entries)
            if (!_photos.contains(photo.key))
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, photo.key),
                child: Row(
                  children: [
                    ListingImage(source: photo.key, width: 56, height: 48),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(child: Text(photo.value)),
                  ],
                ),
              ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => _photos.add(selected));
  }

  Future<void> _submit() async {
    if (!_submitted) setState(() => _submitted = true);
    final invalidFields = _formKey.currentState!.validateGranularly();
    if (invalidFields.isNotEmpty || _photos.isEmpty) {
      final firstProblem = _photos.isEmpty
          ? _photoSectionKey.currentContext
          : invalidFields.first.context;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || firstProblem == null || !firstProblem.mounted) return;
        Scrollable.ensureVisible(
          firstProblem,
          alignment: .1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
      return;
    }

    FocusScope.of(context).unfocus();
    final confirmed = await confirmAction(
      context,
      title: _isEditing ? 'Save these changes?' : 'Publish this listing?',
      message: _isEditing
          ? 'Save the updated photos and listing information.'
          : 'Your listing will appear in the active campus feed.',
      confirmLabel: _isEditing ? 'Save' : 'Publish',
    );
    if (!mounted || !confirmed) return;

    final original = widget.listing;
    Navigator.pop(
      context,
      Listing(
        id: original?.id ?? widget.listingId,
        title: _title.text.trim(),
        price: _enteredPrice!,
        description: _description.text.trim(),
        category: _category!,
        condition: _condition!,
        seller: original?.seller ?? 'You',
        isMine: original?.isMine ?? true,
        isSold: original?.isSold ?? false,
        postedAt: original?.postedAt,
        photos: List<String>.of(_photos),
      ),
    );
  }

  Widget _photoEditor() {
    final canAdd = _samplePhotos.keys.any((path) => !_photos.contains(path));
    return Container(
      key: _photoSectionKey,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Photos *', style: AppText.heading),
          const SizedBox(height: 5),
          const Text(
            'Choose sample photos for your demo listing.',
            style: AppText.note,
          ),
          const SizedBox(height: AppSpacing.medium),
          if (_photos.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < _photos.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.small),
                      child: Column(
                        children: [
                          ListingImage(
                            source: _photos[index],
                            width: 96,
                            height: 78,
                          ),
                          IconButton(
                            tooltip: 'Remove photo ${index + 1}',
                            onPressed: () =>
                                setState(() => _photos.removeAt(index)),
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: AppColors.navy,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: canAdd ? _addPhoto : null,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Add photo'),
          ),
          if (_submitted && _photos.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.small),
              child: Semantics(
                liveRegion: true,
                child: const Text(
                  'Add at least one photo.',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MarketPage(
      title: _isEditing ? 'Edit listing' : 'Create listing',
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _photoEditor(),
              const SizedBox(height: AppSpacing.extraLarge),
              const Text('Listing details', style: AppText.heading),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title *'),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Enter a title.' : null,
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price (TRY) *'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final price = _enteredPrice;
                  if (price == null || !price.isFinite || price <= 0) {
                    return 'Enter a price greater than 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description *'),
                minLines: 2,
                maxLines: 4,
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Enter a description.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.large),
              DropdownButtonFormField<String>(
                initialValue: widget.listing?.category,
                decoration: const InputDecoration(labelText: 'Category *'),
                isExpanded: true,
                items: [
                  for (final category in listingCategories)
                    DropdownMenuItem(value: category, child: Text(category)),
                ],
                onChanged: (value) => _category = value,
                validator: (value) =>
                    value == null ? 'Choose a category.' : null,
              ),
              const SizedBox(height: AppSpacing.large),
              DropdownButtonFormField<String>(
                initialValue: widget.listing?.condition,
                decoration: const InputDecoration(labelText: 'Condition *'),
                isExpanded: true,
                items: [
                  for (final condition in listingConditions)
                    DropdownMenuItem(value: condition, child: Text(condition)),
                ],
                onChanged: (value) => _condition = value,
                validator: (value) =>
                    value == null ? 'Choose a condition.' : null,
              ),
              const SizedBox(height: AppSpacing.extraLarge),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Save changes' : 'Publish listing'),
              ),
              const SizedBox(height: AppSpacing.small),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

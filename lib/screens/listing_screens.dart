import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../theme.dart';
import '../widgets/market_ui.dart';
import 'listing_form_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({
    super.key,
    required this.listings,
    required this.onCreate,
    required this.onOpenListing,
  });

  final List<Listing> listings;
  final Future<bool> Function(BuildContext) onCreate;
  final Future<void> Function(BuildContext, Listing) onOpenListing;

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  Widget build(BuildContext context) {
    final ownListings = widget.listings.where((item) => item.isMine).toList();
    final soldCount = ownListings.where((item) => item.isSold).length;

    return MarketPage(
      title: 'My listings',
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: const Text(
                      'Your active and sold items',
                      style: AppText.heading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ownListings.length - soldCount} active · $soldCount sold',
                    style: AppText.note,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await widget.onCreate(context);
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create listing'),
                  ),
                ],
              ),
            ),
          ),
          if (ownListings.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(message: 'You have no listings yet.'),
            )
          else
            SliverList.builder(
              itemCount: ownListings.length,
              itemBuilder: (context, index) {
                final listing = ownListings[index];
                return Padding(
                  key: ValueKey(listing.id),
                  padding: const EdgeInsets.only(bottom: AppSpacing.extraLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListingCard(
                        listing: listing,
                        onTap: () async {
                          await widget.onOpenListing(context, listing);
                          if (mounted) setState(() {});
                        },
                      ),
                      const SizedBox(height: AppSpacing.small),
                      _ListingStatus(isSold: listing.isSold),
                      const SizedBox(height: AppSpacing.small),
                      OwnerActions(
                        listing: listing,
                        listings: widget.listings,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ListingDetailsScreen extends StatefulWidget {
  const ListingDetailsScreen({
    super.key,
    required this.listing,
    required this.listings,
    required this.onMessageSeller,
  });

  final Listing listing;
  final List<Listing> listings;
  final void Function(BuildContext, Listing) onMessageSeller;

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  final _photoController = PageController();
  late Listing _listing = widget.listing;
  int _selectedPhoto = 0;

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  void _selectPhoto(int index) {
    if (!_photoController.hasClients || index == _selectedPhoto) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _photoController.jumpToPage(index);
    } else {
      _photoController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = _listing.photos;
    final fallback = photos
        .where((photo) => photo.startsWith('assets/'))
        .firstOrNull;

    return MarketPage(
      title: 'Listing details',
      bottomNavigationBar: _listing.isMine
          ? null
          : _ListingContactBar(
              isSold: _listing.isSold,
              onMessageSeller: () => widget.onMessageSeller(context, _listing),
            ),
      child: ListView(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = (constraints.maxWidth * .75).clamp(
                160.0,
                350.0,
              );
              return SizedBox(
                height: imageHeight,
                child: photos.length <= 1
                    ? Semantics(
                        image: true,
                        label: photos.isEmpty
                            ? 'No photo available'
                            : '${_listing.title}, photo',
                        child: ListingImage(
                          source: photos.isEmpty ? '' : photos.first,
                          width: double.infinity,
                          height: imageHeight,
                          borderRadius: 20,
                          fit: BoxFit.contain,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _photoController,
                              itemCount: photos.length,
                              onPageChanged: (index) =>
                                  setState(() => _selectedPhoto = index),
                              itemBuilder: (context, index) => Semantics(
                                image: true,
                                label: '${_listing.title}, photo ${index + 1}',
                                child: ListingImage(
                                  source: photos[index],
                                  fallbackSource: fallback,
                                  width: double.infinity,
                                  height: imageHeight,
                                  borderRadius: 0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            PositionedDirectional(
                              end: AppSpacing.medium,
                              bottom: AppSpacing.medium,
                              child: IgnorePointer(
                                child: Semantics(
                                  label:
                                      'Photo ${_selectedPhoto + 1} of ${photos.length}',
                                  excludeSemantics: true,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.navy,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        '${_selectedPhoto + 1} / ${photos.length}',
                                        style: AppText.note.copyWith(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
          if (photos.length > 1) ...[
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                for (var index = 0; index < photos.length; index++)
                  Semantics(
                    selected: index == _selectedPhoto,
                    child: IconButton(
                      tooltip: 'View photo ${index + 1}',
                      onPressed: () => _selectPhoto(index),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(2),
                        minimumSize: const Size(60, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: index == _selectedPhoto
                              ? AppColors.navy
                              : AppColors.control,
                          width: index == _selectedPhoto ? 2 : 1,
                        ),
                      ),
                      icon: ExcludeSemantics(
                        child: ListingImage(
                          source: photos[index],
                          fallbackSource: fallback,
                          width: 54,
                          height: 46,
                          borderRadius: 7,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          Text(_listing.category, style: AppText.eyebrow),
          const SizedBox(height: 4),
          Semantics(
            header: true,
            child: Text(_listing.title, style: AppText.display),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            _listing.priceLabel,
            style: AppText.price.copyWith(fontSize: 24),
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MarketBadge(
                label: _listing.condition,
                semanticLabel: 'Condition: ${_listing.condition}',
              ),
              _ListingStatus(isSold: _listing.isSold),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          Semantics(
            header: true,
            child: const Text('About this item', style: AppText.heading),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(_listing.description),
          const SizedBox(height: AppSpacing.large),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(20),
              color: AppColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.soft,
                    foregroundColor: AppColors.navy,
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller: ${_listing.seller}',
                          style: AppText.price,
                        ),
                        Text(
                          'Posted ${MaterialLocalizations.of(context).formatMediumDate(_listing.postedAt)}',
                          style: AppText.note,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          if (_listing.isMine)
            OwnerActions(
              listing: _listing,
              listings: widget.listings,
              onChanged: (item) {
                if (item == null) {
                  Navigator.pop(context);
                  return;
                }
                if (_photoController.hasClients && _selectedPhoto != 0) {
                  _photoController.jumpToPage(0);
                }
                setState(() {
                  _listing = item;
                  _selectedPhoto = 0;
                });
              },
            ),
        ],
      ),
    );
  }
}

class _ListingStatus extends StatelessWidget {
  const _ListingStatus({required this.isSold});

  final bool isSold;

  @override
  Widget build(BuildContext context) {
    return MarketBadge(
      icon: isSold ? Icons.check_circle_outline_rounded : Icons.circle,
      backgroundColor: isSold ? AppColors.sand : AppColors.soft,
      label: isSold ? 'SOLD' : 'ACTIVE',
      semanticLabel: isSold ? 'Listing sold' : 'Listing active',
    );
  }
}

class _ListingContactBar extends StatelessWidget {
  const _ListingContactBar({
    required this.isSold,
    required this.onMessageSeller,
  });

  final bool isSold;
  final VoidCallback onMessageSeller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSold ? null : onMessageSeller,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Message seller'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OwnerActions extends StatelessWidget {
  const OwnerActions({
    super.key,
    required this.listing,
    required this.listings,
    required this.onChanged,
  });

  final Listing listing;
  final List<Listing> listings;
  final ValueChanged<Listing?> onChanged;

  Future<void> _edit(BuildContext context) async {
    final edited = await Navigator.push<Listing>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListingFormScreen(listingId: listing.id, listing: listing),
      ),
    );
    if (!context.mounted || edited == null) return;
    final index = listings.indexWhere((item) => item.id == listing.id);
    if (index == -1) return;
    listings[index] = edited;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Listing updated.')));
    onChanged(edited);
  }

  Future<void> _markSold(BuildContext context) async {
    final confirmed = await confirmAction(
      context,
      title: 'Mark as sold?',
      message:
          'The listing will stay in My listings and leave the active feed.',
      confirmLabel: 'Mark sold',
    );
    if (!context.mounted || !confirmed) return;
    listing.isSold = true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Listing marked as sold.')));
    onChanged(listing);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await confirmAction(
      context,
      title: 'Delete this listing?',
      message:
          'This listing will be removed from your items and the active feed.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!context.mounted || !confirmed) return;
    listings.removeWhere((item) => item.id == listing.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Listing deleted.')));
    onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: [
        OutlinedButton.icon(
          onPressed: () => _edit(context),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit'),
        ),
        if (!listing.isSold)
          OutlinedButton.icon(
            onPressed: () => _markSold(context),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Mark as sold'),
          ),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => _delete(context),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text('Delete'),
        ),
      ],
    );
  }
}

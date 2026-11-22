import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../theme.dart';
import '../widgets/market_ui.dart';
import 'listing_form_screen.dart';
import 'listing_screens.dart';
import 'messages_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _listingSection = GlobalKey();
  final List<Listing> _listings = sampleListings();
  final List<Conversation> _conversations = [
    Conversation(
      listingId: 1,
      messages: [
        const ChatMessage(
          text: 'Is the Calculus textbook still available?',
          fromMe: true,
          time: '14:02',
        ),
        const ChatMessage(
          text: 'Yes. We can meet near the library after class.',
          fromMe: false,
          time: '14:10',
        ),
      ],
    ),
    Conversation(
      listingId: 2,
      messages: [
        const ChatMessage(
          text: 'The headphones include the charging cable.',
          fromMe: false,
          time: '15:06',
        ),
      ],
    ),
  ];
  int _nextListingId = 5;
  String _category = 'All items';

  Future<void> _openListing(BuildContext context, Listing listing) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ListingDetailsScreen(
          listing: listing,
          listings: _listings,
          onMessageSeller: _openConversation,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _openConversation(BuildContext context, Listing listing) {
    var index = _conversations.indexWhere(
      (item) => item.listingId == listing.id,
    );
    if (index == -1) {
      _conversations.add(Conversation(listingId: listing.id, messages: []));
      index = _conversations.length - 1;
    }
    final conversation = _conversations[index];
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          listing: listing,
          conversation: conversation,
          onOpenListing: _openListing,
        ),
      ),
    );
  }

  Future<bool> _createListing(BuildContext context) async {
    final listing = await Navigator.push<Listing>(
      context,
      MaterialPageRoute(
        builder: (context) => ListingFormScreen(listingId: _nextListingId),
      ),
    );
    if (!mounted || listing == null) return false;
    setState(() {
      _listings.insert(0, listing);
      _nextListingId++;
    });
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listing published.')));
    }
    return true;
  }

  Future<void> _openMyListings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => MyListingsScreen(
          listings: _listings,
          onCreate: _createListing,
          onOpenListing: _openListing,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openSearch() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchScreen(listings: _listings, onOpenListing: _openListing),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openMessages() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesScreen(
          listings: _listings,
          conversations: _conversations,
          onOpenListing: _openListing,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _sell() async {
    final created = await _createListing(context);
    if (!mounted || !created) return;
    setState(() => _category = 'All items');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectionContext = _listingSection.currentContext;
      if (!mounted || sectionContext == null) return;
      Scrollable.ensureVisible(
        sectionContext,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeListings = _listings
        .where(
          (item) =>
              !item.isSold &&
              (_category == 'All items' || item.category == _category),
        )
        .toList();

    return MarketPage(
      title: 'CampusMarket',
      actions: [
        IconButton(
          tooltip: 'Log out',
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout_rounded),
        ),
        const SizedBox(width: AppSpacing.small),
      ],
      bottomNavigationBar: _MarketplaceActions(
        onMessages: _openMessages,
        onMyListings: _openMyListings,
        onSell: _sell,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CampusIntro(),
                const SizedBox(height: AppSpacing.medium),
                OutlinedButton.icon(
                  onPressed: _openSearch,
                  style: OutlinedButton.styleFrom(
                    alignment: AlignmentDirectional.centerStart,
                    backgroundColor: AppColors.white,
                    minimumSize: const Size(0, 54),
                  ),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Search listings & filters'),
                ),
                const SizedBox(height: AppSpacing.medium),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final category in [
                        'All items',
                        ...listingCategories,
                      ])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: AppSpacing.small,
                          ),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _category == category,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Semantics(
                  key: _listingSection,
                  header: true,
                  child: const Text('Active on campus', style: AppText.heading),
                ),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    '${activeListings.length} ${activeListings.length == 1 ? 'listing' : 'listings'}',
                    style: AppText.note,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
              ],
            ),
          ),
          if (activeListings.isEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmptyState(
                    message: _category == 'All items'
                        ? 'No active listings yet.'
                        : 'No active listings in $_category.',
                  ),
                  if (_category != 'All items')
                    TextButton(
                      onPressed: () => setState(() => _category = 'All items'),
                      child: const Text('Browse all items'),
                    ),
                ],
              ),
            )
          else
            SliverList.builder(
              itemCount: activeListings.length,
              itemBuilder: (context, index) {
                final listing = activeListings[index];
                return Padding(
                  key: ValueKey(listing.id),
                  padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                  child: ListingCard(
                    listing: listing,
                    featured: index == 0,
                    onTap: () => _openListing(context, listing),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MarketplaceActions extends StatelessWidget {
  const _MarketplaceActions({
    required this.onMessages,
    required this.onMyListings,
    required this.onSell,
  });

  final VoidCallback onMessages;
  final VoidCallback onMyListings;
  final VoidCallback onSell;

  @override
  Widget build(BuildContext context) {
    final shortcuts = Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onMessages,
            style: TextButton.styleFrom(padding: const EdgeInsets.all(5)),
            child: const _ActionLabel(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Messages',
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: onMyListings,
            style: TextButton.styleFrom(padding: const EdgeInsets.all(5)),
            child: const _ActionLabel(
              icon: Icons.inventory_2_outlined,
              label: 'My listings',
            ),
          ),
        ),
      ],
    );
    final sell = ElevatedButton(
      onPressed: onSell,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(5)),
      child: const _ActionLabel(icon: Icons.sell_outlined, label: '+ Sell'),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: 6,
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 410 &&
                    MediaQuery.textScalerOf(context).scale(13) > 19) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [shortcuts, const SizedBox(height: 4), sell],
                  );
                }
                return Row(
                  children: [
                    Expanded(flex: 2, child: shortcuts),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(child: sell),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _CampusIntro extends StatelessWidget {
  const _CampusIntro();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: AppColors.navy,
        child: Stack(
          children: [
            PositionedDirectional(
              top: -65,
              end: -76,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (final size in [220.0, 186.0, 152.0])
                          Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: .15),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SABANCI UNIVERSITY',
                    style: AppText.eyebrow.copyWith(color: AppColors.lime),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Semantics(
                    header: true,
                    child: Text(
                      'Find it on campus.',
                      style: AppText.display.copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buy and sell with your campus community.',
                    style: AppText.note.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

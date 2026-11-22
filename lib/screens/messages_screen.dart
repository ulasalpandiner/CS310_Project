import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../theme.dart';
import '../widgets/market_ui.dart';

class Conversation {
  Conversation({required this.listingId, required this.messages});

  final int listingId;
  final List<ChatMessage> messages;
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromMe,
    required this.time,
  });

  final String text;
  final bool fromMe;
  final String time;
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.listings,
    required this.conversations,
    required this.onOpenListing,
  });

  final List<Listing> listings;
  final List<Conversation> conversations;
  final void Function(BuildContext, Listing) onOpenListing;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Future<void> _openConversation(
    Listing listing,
    Conversation conversation,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          listing: listing,
          conversation: conversation,
          onOpenListing: widget.onOpenListing,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _refresh() {
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Conversations refreshed.')));
  }

  @override
  Widget build(BuildContext context) {
    final listingsById = {
      for (final listing in widget.listings) listing.id: listing,
    };
    final availableConversations = widget.conversations
        .where(
          (conversation) => listingsById.containsKey(conversation.listingId),
        )
        .toList();

    return MarketPage(
      title: 'Messages',
      actions: [TextButton(onPressed: _refresh, child: const Text('Refresh'))],
      child: availableConversations.isEmpty
          ? ListView(
              children: [
                const EmptyState(message: 'No conversations yet.'),
                const SizedBox(height: AppSpacing.large),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Browse listings'),
                ),
              ],
            )
          : ListView.builder(
              itemCount: availableConversations.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CAMPUS INBOX', style: AppText.eyebrow),
                        SizedBox(height: AppSpacing.small),
                        Text('Your conversations', style: AppText.heading),
                      ],
                    ),
                  );
                }
                final conversation = availableConversations[index - 1];
                final listing = listingsById[conversation.listingId]!;
                final latestMessage = conversation.messages.isEmpty
                    ? 'Start a conversation.'
                    : conversation.messages.last.text;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                  child: Material(
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Semantics(
                      button: true,
                      child: InkWell(
                        onTap: () => _openConversation(listing, conversation),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListingImage(
                                source:
                                    listing.photos
                                        .where(
                                          (photo) =>
                                              photo.startsWith('assets/'),
                                        )
                                        .firstOrNull ??
                                    '',
                                width: 53,
                                height: 53,
                                borderRadius: 13,
                              ),
                              const SizedBox(width: AppSpacing.medium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listing.seller,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(listing.title, style: AppText.note),
                                    const SizedBox(height: 6),
                                    Text(
                                      latestMessage,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSpacing.small),
                                    const Text(
                                      'Open conversation',
                                      style: TextStyle(
                                        color: AppColors.navy,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.navy,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.listing,
    required this.conversation,
    required this.onOpenListing,
  });

  final Listing listing;
  final Conversation conversation;
  final void Function(BuildContext, Listing) onOpenListing;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _messageError;

  @override
  void initState() {
    super.initState();
    _scrollToLatest(animate: false);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _messageError = 'Enter a message.');
      return;
    }
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    setState(() {
      widget.conversation.messages.add(
        ChatMessage(text: message, fromMe: true, time: '$hour:$minute'),
      );
      _messageError = null;
    });
    _messageController.clear();
    _scrollToLatest();
  }

  void _scrollToLatest({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final latest = _scrollController.position.maxScrollExtent;
      if (!animate || MediaQuery.disableAnimationsOf(context)) {
        _scrollController.jumpTo(latest);
      } else {
        _scrollController.animateTo(
          latest,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _refresh() {
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Conversation refreshed.')));
  }

  @override
  Widget build(BuildContext context) {
    return MarketPage(
      title: widget.listing.seller,
      actions: [TextButton(onPressed: _refresh, child: const Text('Refresh'))],
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: widget.conversation.messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      ListingCard(
                        listing: widget.listing,
                        onTap: () =>
                            widget.onOpenListing(context, widget.listing),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      if (widget.conversation.messages.isEmpty)
                        const EmptyState(
                          icon: Icons.chat_bubble_outline_rounded,
                          message: 'Start a conversation about this listing.',
                        ),
                    ],
                  );
                }
                return _MessageBubble(
                  message: widget.conversation.messages[index - 1],
                  seller: widget.listing.seller,
                );
              },
            ),
          ),
          const Divider(color: AppColors.line, height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    errorText: _messageError,
                  ),
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onChanged: (_) {
                    if (_messageError != null) {
                      setState(() => _messageError = null);
                    }
                  },
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              ElevatedButton(onPressed: _send, child: const Text('Send')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.seller});

  final ChatMessage message;
  final String seller;

  @override
  Widget build(BuildContext context) {
    final sender = message.fromMe ? 'You' : seller;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: FractionallySizedBox(
        widthFactor: 0.86,
        alignment: message.fromMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: message.fromMe ? AppColors.navy : AppColors.white,
            border: message.fromMe ? null : Border.all(color: AppColors.line),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(19),
              topRight: const Radius.circular(19),
              bottomLeft: Radius.circular(message.fromMe ? 19 : 5),
              bottomRight: Radius.circular(message.fromMe ? 5 : 19),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.fromMe ? AppColors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  '$sender · ${message.time}',
                  style: AppText.note.copyWith(
                    color: message.fromMe ? AppColors.soft : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

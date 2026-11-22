import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../theme.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.bottomNavigationBar,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        titleSpacing: ModalRoute.of(context)?.canPop == true
            ? 4
            : AppSpacing.page,
        actions: actions,
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        bottom: bottomNavigationBar == null,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.small,
                AppSpacing.page,
                AppSpacing.large,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class ListingImage extends StatelessWidget {
  const ListingImage({
    super.key,
    required this.source,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.fallbackSource,
    this.fit = BoxFit.cover,
  });

  final String source;
  final double width;
  final double height;
  final double borderRadius;
  final String? fallbackSource;
  final BoxFit fit;

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.muted,
        size: 23,
      ),
    );
  }

  Widget _asset(String path) => Image.asset(
    path,
    fit: fit,
    excludeFromSemantics: true,
    errorBuilder: (context, error, stack) => _placeholder(),
  );

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (source.startsWith('https://')) {
      Widget fallback() =>
          fallbackSource == null ? _placeholder() : _asset(fallbackSource!);
      image = Image.network(
        source,
        fit: fit,
        excludeFromSemantics: true,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback(),
        errorBuilder: (context, error, stack) => fallback(),
      );
    } else {
      image = source.isEmpty ? _placeholder() : _asset(source);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: ColoredBox(
          color: AppColors.soft,
          child: SizedBox.expand(child: image),
        ),
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.featured = false,
  });

  final Listing listing;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final source = listing.photos.isEmpty ? '' : listing.photos.first;
    final fallback = listing.photos
        .where((photo) => photo.startsWith('assets/'))
        .firstOrNull;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(listing.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 5),
        Text(listing.priceLabel, style: AppText.price),
        const SizedBox(height: 5),
        Text('${listing.category} · ${listing.condition}', style: AppText.note),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.line),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: featured
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.48,
                      child: ListingImage(
                        source: source,
                        fallbackSource: fallback,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 0,
                      ),
                    ),
                    Padding(padding: const EdgeInsets.all(13), child: text),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ListingImage(
                        source: source,
                        fallbackSource: fallback,
                        width: 81,
                        height: 85,
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(child: text),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.extraLarge),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.navy, size: 25),
          const SizedBox(height: AppSpacing.small),
          Text(message, textAlign: TextAlign.center, style: AppText.note),
        ],
      ),
    );
  }
}

class MarketBadge extends StatelessWidget {
  const MarketBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.white,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final Color backgroundColor;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: const StadiumBorder(
            side: BorderSide(color: AppColors.control),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppColors.navy),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title, style: AppText.heading),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: destructive
              ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
              : null,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return answer ?? false;
}

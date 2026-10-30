/// BMJ product detail page (PDP).
///
/// Replaces the legacy `_DetailPageState` stack (unstyled white panel,
/// hard-coded `Subscribe @Rs.129 89/juice` copy, no real price) with the
/// Stitch `juice_detail_selection` layout: glass header, gradient hero,
/// real catalog price, a dedicated "Select a size" block backed by `ItemPrice`
/// ids, "Key ingredients", macro stats and one primary CTA.
///
/// Flow: **Product tile → PDP → existing size sheet → cart → checkout.**
/// "Select options" (hero) and "Choose quantity" (size card) both open the
/// shared [showSizeSelectionSheet], which is also used by the Menu and Home
/// quick-add paths. "Weekly subscription" in the Purchase option block routes to
/// the existing `/plan-selection` flow instead. Every price comes from the
/// catalog — nothing is invented.
///
/// Two entry points:
/// - [DetailPage.catalog] — a `CatalogItem` from `ProductCatalogBloc`
///   (Menu / Home cards).
/// - [DetailPage.legacy] — the old `Product` value object, kept so any
///   remaining `Product`-based navigation still resolves.
///
/// Use [DetailPage.fromArgument] with a named route so `main.dart` accepts
/// either argument type.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart'
    hide AddToCart;
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/utils/analytics_service.dart';
import 'package:lush/utils/price_utils.dart';
import 'package:lush/views/models/cart_item.dart';
import 'package:lush/views/models/item.dart';
import 'package:lush/views/models/model.dart';
import 'package:lush/views/widgets/size_selection_sheet.dart';
import 'package:lush/widgets/bmj_glass_button.dart';
import 'package:lush/widgets/bmj_glass_card.dart';
import 'package:lush/widgets/bmj_glass_header.dart';
import 'package:lush/widgets/bmj_pill.dart';
import 'package:toastification/toastification.dart';

/// Product detail page for a catalog item (or a legacy [Product]).
class DetailPage extends StatefulWidget {
  /// Named route used by Menu and Home.
  static const routeName = '/productDetails';

  /// Catalog-driven PDP argument.
  final CatalogItem? catalogItem;

  /// Legacy PDP argument — kept for back-compatible navigation.
  final Product? product;

  const DetailPage({super.key, this.catalogItem, this.product})
      : assert(
          catalogItem != null || product != null,
          'DetailPage needs a CatalogItem or a Product',
        );

  /// PDP for a catalog item — the supported path.
  factory DetailPage.catalog(CatalogItem item) => DetailPage(catalogItem: item);

  /// PDP for the legacy [Product] model.
  factory DetailPage.legacy(Product product) => DetailPage(product: product);

  /// Resolves the `/productDetails` route argument.
  ///
  /// Accepts a [CatalogItem] (Menu / Home) or a legacy [Product]; anything else
  /// renders a friendly "juice not found" PDP instead of throwing a cast error.
  static Widget fromArgument(Object? argument) {
    if (argument is CatalogItem) return DetailPage.catalog(argument);
    if (argument is Product) return DetailPage.legacy(argument);
    return const DetailPage.missing();
  }

  /// Fallback PDP shown when the route argument is not a product.
  const DetailPage.missing({super.key})
      : catalogItem = null,
        product = null;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String _name = '';
  String _description = '';
  String _category = 'Juice';
  int? _calories;
  double? _rating;
  String _startColor = '#FF8C42';
  String _endColor = '#FF6B35';
  String _imagePath = '';
  List<String> _ingredients = <String>[];
  List<ItemPrice> _prices = <ItemPrice>[];
  Item? _item;
  ItemPrice? _selected;
  bool _missing = false;

  /// Stitch "Purchase Option" selection. Only a UI mode: `false` adds to the
  /// cart, `true` routes to the existing `/plan-selection` subscription flow.
  bool _subscribe = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
    if (!_missing) {
      AnalyticsService.logItemViewed(
        itemId: _item?.id ?? _name,
        itemName: _name,
        family: _category.toLowerCase(),
      );
    }
  }

  void _hydrate() {
    final CatalogItem? catalog = widget.catalogItem;
    if (catalog != null) {
      _name = catalog.name;
      _description = catalog.description;
      _category = catalog.category;
      _calories = catalog.item.kacl;
      _rating = catalog.item.rating;
      _startColor = catalog.startColor;
      _endColor = catalog.endColor;
      _imagePath = catalog.imagePath;
      _ingredients = catalog.ingredients;
      _prices = catalog.prices;
      _item = catalog.item;
      _selected = cheapestPricedOption(_prices);
      return;
    }

    final Product? legacy = widget.product;
    if (legacy == null) {
      _missing = true;
      return;
    }

    _name = legacy.name;
    _description = legacy.details;
    _category = 'Juice';
    _imagePath = legacy.imgUrl;

    // The legacy model stores the price as display text ("₹129").
    final double? parsed = double.tryParse(
      legacy.price.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (parsed != null && parsed > 0) {
      final ItemPrice price = ItemPrice(
        id: '${legacy.name}_default'.toLowerCase().replaceAll(' ', '_'),
        name: 'Regular',
        price: parsed,
        currencyCode: 'INR',
      );
      _prices = <ItemPrice>[price];
      _selected = price;
      _item = Item(
        id: price.id,
        name: legacy.name,
        description: legacy.details,
        price: parsed,
        itemPrices: <ItemPrice>[price],
        servingSize: 'Regular',
        imagePath: legacy.imgUrl,
        startColor: legacy.bgColor.toARGB32().toRadixString(16),
        endColor: legacy.nameColor.toARGB32().toRadixString(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);

    return Scaffold(
      backgroundColor: palette.surface,
      body: Column(
        children: <Widget>[
          BMJGlassHeader(
            leading: Semantics(
              button: true,
              label: 'Back',
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: palette.onSurface,
                tooltip: 'Back',
              ),
            ),
            onCartTap: () => Navigator.of(context).pushNamed('/cart'),
          ),
          Expanded(
            child: _missing
                ? _MissingBody(palette: palette)
                : ListView(
                    // The photography is full-bleed, so the ListView itself
                    // carries no horizontal padding — everything after the hero
                    // is inset to the 16 dp page margin instead.
                    padding: const EdgeInsets.only(bottom: BMJTokens.spaceXl),
                    children: <Widget>[
                      _hero(palette),
                      // Stitch pulls the info column up over the photograph
                      // (`-mt-8` + `relative z-10`): the first glass card
                      // overlaps the image edge, which is what binds "photo" to
                      // "product" instead of stacking two separate blocks.
                      Transform.translate(
                        offset: const Offset(0, -32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BMJTokens.pageMargin,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Stitch's title block is a
                              // `glass-panel rounded-xl p-md` card, and with the
                              // −32 dp pull-up that card is the thing that
                              // actually overlaps the photograph. Bare text here
                              // would make the overlap do nothing.
                              BMJGlassCard(
                                child: _titleBlock(palette),
                              ),
                              const SizedBox(height: BMJTokens.spaceMd),
                              _sizeSection(palette),
                              const SizedBox(height: BMJTokens.spaceMd),
                              _purchaseOption(palette),
                              const SizedBox(height: BMJTokens.spaceMd),
                              _nutritionPanels(palette),
                              const SizedBox(height: BMJTokens.spaceMd),
                              _ingredientsCard(palette),
                              // Re-consumes the 32 dp the translate moved the
                              // column up by, so the last card keeps its
                              // breathing room at the end of the scroll.
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          // Stitch pins the primary CTA to the bottom of the PDP; keeping it
          // out of the scroll view means "Add to cart" is always one tap away
          // (the size sheet stays reachable from the hero and the size block).
          if (!_missing)
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border(
                  top: BorderSide(color: palette.outlineVariant),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BMJTokens.pageMargin,
                    BMJTokens.spaceSm,
                    BMJTokens.pageMargin,
                    BMJTokens.spaceMd,
                  ),
                  child: _actions(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Stitch PDP hero geometry.
  ///
  /// `juice_detail_selection` renders the photography as
  /// `<section class="relative w-full aspect-[4/5]">` — full-bleed, square
  /// corners, no margin, no card chrome. At the 390 dp reference width that is
  /// 390 × 487.5 dp of product, i.e. the top 55 % of the viewport. Keeping it as
  /// a ratio (rather than the old fixed 488 dp inset container) preserves that
  /// crop at every device width.
  static const double _heroAspect = 4 / 5;

  Widget _hero(BMJPalette palette) {
    final LinearGradient gradient = LinearGradient(
      colors: <Color>[_colorFromHex(_startColor), _colorFromHex(_endColor)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AspectRatio(
      aspectRatio: _heroAspect,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // The item's own brand gradient stands behind the photograph, and
          // shows alone when the catalog ships no artwork.
          DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
          if (_imagePath.isNotEmpty)
            Image.asset(
              _imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            )
          else
            Center(
              child: Icon(
                Icons.local_drink,
                size: 96,
                color: palette.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          // Stitch floats glass pills over the top of the photograph
          // (`top-4 left-4`) and draws no bottom scrim, so none is drawn here.
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: _heroBadge(_category),
          ),
          // Same glass-pill chrome as the badges: the hero gets one overlay
          // language instead of a badge plus a page-sized CTA.
          if (widget.catalogItem != null && _prices.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.md,
              child: Center(child: _heroAction()),
            ),
        ],
      ),
    );
  }

  /// Tappable hero pill — the size sheet's second entry point.
  ///
  /// The visual pill is only 26 dp tall, so it sits inside a 48 dp hit area to
  /// stay a legal touch target without drawing a bigger surface on the image.
  Widget _heroAction() {
    return Semantics(
      button: true,
      label: 'Select size and quantity',
      child: SizedBox(
        height: BMJTokens.minTouchTarget,
        child: GestureDetector(
          onTap: _openOptions,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: BMJTokens.darkSurfaceDeep.withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(BMJTokens.radiusPill),
                border: Border.all(color: BMJTokens.darkGlassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: BMJTokens.inkOnBrand,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Select options',
                    style: AppTextStyles.textTheme.labelSmall?.copyWith(
                      color: BMJTokens.inkOnBrand,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Glass pill that sits on product photography.
  ///
  /// A theme-aware pill cannot guarantee contrast over an unknown image, so the
  /// hero pill uses a fixed light surface with dark ink — the same reading in
  /// both themes, and the Stitch `glass-panel px-3 py-1 rounded-full` badge.
  Widget _heroBadge(
    String label, {
    IconData? icon,
    bool uppercase = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: BMJTokens.lightSurfaceContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(BMJTokens.radiusPill),
        border: Border.all(color: BMJTokens.lightGlassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: BMJTokens.lightOnSurface),
            const SizedBox(width: 4),
          ],
          Text(
            uppercase ? label.toUpperCase() : label,
            style: AppTextStyles.textTheme.labelSmall?.copyWith(
              color: BMJTokens.lightOnSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleBlock(BMJPalette palette) {
    final String priceLabel =
        _selected == null ? kPriceFallback : formatRupees(_selected!.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            _name,
            // The name is the page's hero: it has to outrank the price sitting
            // directly beneath it, or the product reads as a SKU.
            style: AppTextStyles.textTheme.headlineLarge?.copyWith(
              color: palette.onSurface,
              fontSize: 34,
              height: 1.15,
              letterSpacing: -1.0,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Product story first, money second: the name has to own this card.
        if (_description.trim().isNotEmpty) ...<Widget>[
          Text(
            _description.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textTheme.bodyLarge?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              priceLabel,
              // A supporting figure now, not the headline.
              style: BMJType.statNum.copyWith(
                fontSize: 20,
                height: 1.2,
                color: palette.primaryEmphasis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                'per bottle',
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: palette.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        if (_rating != null && _rating! > 0) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          // Stitch separates the rating with `mt-4 pt-4 border-t`: a hairline
          // rule turns it into a footer row of the title card instead of a third
          // line of body copy.
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: palette.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: BMJTokens.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  _rating!.toStringAsFixed(1),
                  style: AppTextStyles.textTheme.titleSmall?.copyWith(
                    color: palette.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'customer rating',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Stitch "Select Size" block: the real catalog prices, cheapest preselected.
  ///
  /// Tapping a pill only changes the selection (and the CTA price); the full
  /// picker with quantities is the shared size sheet behind [showSizeSelectionSheet].
  Widget _sizeSection(BMJPalette palette) {
    return BMJGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Select a size',
            style: AppTextStyles.textTheme.titleSmall?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_prices.isEmpty)
            Text(
              'Size options are unavailable for this juice.',
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: palette.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final ItemPrice price in _prices)
                  BMJPill(
                    label:
                        '${price.name ?? 'Size'} · ${formatRupees(price.price)}',
                    tone: _selected?.id == price.id
                        ? BMJPillTone.primary
                        : BMJPillTone.neutral,
                    onTap: price.price == null || price.price! <= 0
                        ? null
                        : () => setState(() => _selected = price),
                  ),
              ],
            ),
          if (_prices.isNotEmpty && widget.catalogItem != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            BMJGlassButton.compact(
              label: 'Choose quantity',
              icon: Icons.tune_rounded,
              semanticLabel: 'Choose size and quantity',
              onPressed: _openOptions,
            ),
          ],
        ],
      ),
    );
  }

  /// Stitch "Purchase Option".
  ///
  /// Two honest routes, no invented numbers: one-time uses the real selected
  /// catalog price, weekly carries no amount because `/plan-selection` owns
  /// subscription pricing (Chargebee). Selecting a row only switches the pinned
  /// CTA — the cart and the subscription flow are untouched.
  Widget _purchaseOption(BMJPalette palette) {
    final String oneTimeAmount =
        _selected == null ? kPriceFallback : formatRupees(_selected!.price);

    return BMJGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Purchase option',
            style: AppTextStyles.textTheme.titleSmall?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _purchaseRow(
            palette,
            selected: !_subscribe,
            icon: Icons.shopping_bag_outlined,
            title: 'One-time purchase',
            subtitle: 'Pay once, no commitment',
            amount: oneTimeAmount,
            onTap: () => setState(() => _subscribe = false),
          ),
          const SizedBox(height: AppSpacing.sm),
          _purchaseRow(
            palette,
            selected: _subscribe,
            icon: Icons.autorenew_rounded,
            title: 'Weekly subscription',
            subtitle: 'Recurring delivery, pause anytime',
            trailingLabel: 'View plans',
            onTap: () => setState(() => _subscribe = true),
          ),
        ],
      ),
    );
  }

  /// One radio row inside [purchaseOption].
  ///
  /// [amount] is a real catalog price; [trailingLabel] is used instead when the
  /// price is only known on the next screen (weekly plans).
  Widget _purchaseRow(
    BMJPalette palette, {
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? amount,
    String? trailingLabel,
  }) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.card);
    final String semanticsValue = amount ?? trailingLabel ?? '';

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsValue.isEmpty ? title : '$title, $semanticsValue',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: selected
                  ? palette.primary.withValues(alpha: 0.16)
                  : palette.surfaceContainerLow.withValues(alpha: 0.30),
              borderRadius: radius,
              border: Border.all(
                color: selected ? palette.primary : palette.outlineVariant,
                width: selected ? 2 : BMJTokens.hairline,
              ),
              // The chosen row lifts off the card; the other one recedes.
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: palette.primary.withValues(alpha: 0.26),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: selected ? 22 : 20,
                  color: selected ? palette.primary : palette.outline,
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, size: 18, color: palette.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTextStyles.textTheme.titleSmall?.copyWith(
                          color: palette.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: palette.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                if (amount != null)
                  Text(
                    amount,
                    // The chosen option's money lights up and grows — that jump is
                    // the payoff the reference gets from its selected row.
                    style: AppTextStyles.textTheme.titleMedium?.copyWith(
                      fontSize: selected ? 22 : 20,
                      height: 1.2,
                      color: selected
                          ? palette.primaryEmphasis
                          : palette.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    ),
                  )
                else if (trailingLabel != null)
                  Row(
                    children: <Widget>[
                      Text(
                        trailingLabel,
                        style: AppTextStyles.textTheme.labelMedium?.copyWith(
                          color: palette.primaryEmphasis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: palette.primaryEmphasis,
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

  /// Stitch nutrition block: two large, equal panels — a centred glyph, a big
  /// value and a small caps caption. Three figures inline on one line read as
  /// metadata; panels read as facts you can scan from across the room.
  ///
  /// Both values are real: the catalog's calorie count and the selected size.
  Widget _nutritionPanels(BMJPalette palette) {
    final String calories = _calories == null ? kPriceFallback : '$_calories';
    final String serving = _selected?.name ?? kPriceFallback;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: _nutritionPanel(
            palette,
            icon: Icons.local_fire_department_rounded,
            value: calories,
            label: 'Calories',
            accent: palette.primaryEmphasis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: _nutritionPanel(
            palette,
            icon: Icons.local_drink_outlined,
            value: serving,
            label: 'Serving',
            accent: palette.accentText,
          ),
        ),
      ],
    );
  }

  /// One large nutrition panel.
  Widget _nutritionPanel(
    BMJPalette palette, {
    required IconData icon,
    required String value,
    required String label,
    required Color accent,
  }) {
    return BMJGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 26, color: accent),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BMJType.statNum.copyWith(
              fontSize: 26,
              height: 1.1,
              color: palette.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.textTheme.labelSmall?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Stitch "Key Ingredients": a plain bulleted list, so the copy stays legible
  /// instead of shrinking into chips.
  Widget _ingredientsCard(BMJPalette palette) {
    if (_ingredients.isEmpty) return const SizedBox.shrink();

    return BMJGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.eco_rounded, size: 18, color: palette.accentText),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Key ingredients',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textTheme.titleSmall?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final String ingredient in _ingredients)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: palette.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: palette.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Stitch pins exactly one primary CTA to the bottom of the PDP.
  ///
  /// The size sheet stays reachable from the hero "Select options" and from
  /// "Choose quantity" inside the size card, so a second footer button only
  /// stole vertical space from the content above it.
  Widget _actions() {
    final bool canOrder = _selected != null && _item != null;

    final String label = _subscribe
        ? 'View weekly plans'
        : canOrder
            ? 'Add to cart · ${formatRupees(_selected!.price)}'
            : 'Not available for order';

    return BMJGlassButton(
      label: label,
      icon: _subscribe ? Icons.autorenew_rounded : Icons.add_shopping_cart,
      onPressed: _subscribe ? _openPlans : (canOrder ? _addToCart : null),
    );
  }

  /// Weekly subscription route — the existing plan-selection screen.
  void _openPlans() => Navigator.of(context).pushNamed('/plan-selection');

  void _openOptions() {
    final CatalogItem? catalog = widget.catalogItem;
    if (catalog == null) {
      Navigator.of(context).pushNamed('/plan-selection');
      return;
    }
    showSizeSelectionSheet(context, catalog);
  }

  void _addToCart() {
    final ItemPrice? selected = _selected;
    final Item? item = _item;
    if (selected == null || item == null) return;

    context.read<CartBloc>().add(
          AddToCart(
            CartItem(item: item, selectedPrice: selected),
          ),
        );

    toastification.show(
      type: ToastificationType.success,
      title: Text('${item.name ?? _name} (${selected.name ?? 'Size'}) added'),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  /// `#RRGGBB` / `RRGGBB` → [Color]; brand orange when malformed.
  Color _colorFromHex(String hex) {
    final String cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return BMJTokens.orange;
    final int? value = int.tryParse(cleaned, radix: 16);
    return value == null ? BMJTokens.orange : Color(0xFF000000 | value);
  }
}

/// Friendly empty state for a malformed `/productDetails` argument.
class _MissingBody extends StatelessWidget {
  final BMJPalette palette;

  const _MissingBody({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BMJTokens.pageMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.local_drink_outlined,
              size: 56,
              color: palette.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Juice not found',
              style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                color: palette.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This juice is no longer on the menu.',
              textAlign: TextAlign.center,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: palette.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BMJGlassButton(
              label: 'Back to menu',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

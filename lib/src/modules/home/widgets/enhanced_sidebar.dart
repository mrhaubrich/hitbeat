import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/widgets/animated_logo.dart';
import 'package:hitbeat/src/theme/sidebar_theme_extension.dart';

/// Controller for managing sidebar state.
class EnhancedSidebarController extends ChangeNotifier {
  /// Creates a new enhanced sidebar controller.
  EnhancedSidebarController({int initialIndex = 0})
    : _selectedIndex = initialIndex;

  int _selectedIndex;
  bool _isExtended = true;

  /// The currently selected index.
  int get selectedIndex => _selectedIndex;

  /// Whether the sidebar is extended.
  bool get isExtended => _isExtended;

  /// Selects a menu item by index.
  void selectIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  /// Toggles the extended state.
  void toggleExtended() {
    _isExtended = !_isExtended;
    notifyListeners();
  }

  /// Sets the extended state.
  void setExtended({required bool extended}) {
    if (_isExtended != extended) {
      _isExtended = extended;
      notifyListeners();
    }
  }
}

/// Data class for sidebar menu items.
class SidebarMenuItem {
  /// Creates a sidebar menu item.
  const SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.route,
    this.tooltip,
  });

  /// The icon to display.
  final IconData icon;

  /// The label text.
  final String label;

  /// The route to navigate to.
  final String route;

  /// Optional tooltip (shown when collapsed).
  final String? tooltip;
}

/// Enhanced sidebar widget with smooth animations and professional styling.
class EnhancedSidebar extends StatefulWidget {
  /// Creates an enhanced sidebar.
  const EnhancedSidebar({
    required this.controller,
    this.mainItems = const [],
    this.footerItems = const [],
    super.key,
  });

  /// The controller managing sidebar state.
  final EnhancedSidebarController controller;

  /// Main navigation items.
  final List<SidebarMenuItem> mainItems;

  /// Footer items (e.g., Settings).
  final List<SidebarMenuItem> footerItems;

  @override
  State<EnhancedSidebar> createState() => _EnhancedSidebarState();
}

class _EnhancedSidebarState extends State<EnhancedSidebar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  int? _previousIndex;
  bool _prevExtended = true;
  bool _showLabels = true; // gate label rendering during width animation

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    _prevExtended = widget.controller.isExtended;
    _showLabels = _prevExtended;
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_previousIndex != null &&
        _previousIndex != widget.controller.selectedIndex) {
      unawaited(_slideController.forward(from: 0));
    }
    final currExtended = widget.controller.isExtended;
    if (currExtended != _prevExtended) {
      // When expanding: delay label rendering until width animation mostly done
      if (currExtended) {
        _showLabels = false;
        Future<void>.delayed(const Duration(milliseconds: 220), () {
          if (mounted && widget.controller.isExtended) {
            setState(() => _showLabels = true);
          }
        });
      } else {
        // Collapsing: hide labels immediately to avoid overflow
        _showLabels = false;
      }
      _prevExtended = currExtended;
    }
    _previousIndex = widget.controller.selectedIndex;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sidebarTheme = Theme.of(context).extension<SidebarThemeExtension>()!;
    final isExtended = widget.controller.isExtended;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: isExtended ? 250 : 80,
          decoration: BoxDecoration(
            color: sidebarTheme.canvasColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  // Header with logo and title
                  _buildHeader(sidebarTheme, isExtended, _showLabels),

                  // Visual separator below header
                  _buildHeaderSeparator(sidebarTheme),

                  const SizedBox(height: 8),

                  // Main navigation items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: widget.mainItems.length,
                      itemBuilder: (context, index) {
                        return _buildMenuItem(
                          item: widget.mainItems[index],
                          index: index,
                          isExtended: isExtended,
                          sidebarTheme: sidebarTheme,
                          showText: _showLabels,
                        );
                      },
                    ),
                  ),

                  // Footer divider with more breathing room
                  if (widget.footerItems.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        color: sidebarTheme.textColor.withValues(alpha: 0.15),
                        thickness: 0.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Footer items
                  ...widget.footerItems.asMap().entries.map((entry) {
                    final footerIndex = widget.mainItems.length + entry.key;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildMenuItem(
                        item: entry.value,
                        index: footerIndex,
                        isExtended: isExtended,
                        sidebarTheme: sidebarTheme,
                        isFooter: true,
                        showText: _showLabels,
                      ),
                    );
                  }),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    SidebarThemeExtension theme,
    bool isExtended,
    bool showText,
  ) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: widget.controller.toggleExtended,
        borderRadius: BorderRadius.circular(20),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                child: AnimatedLogo(extended: isExtended),
              ),
              // Only show text when extended and allowed to render labels
              if (isExtended && showText)
                ClipRect(
                  child: Align(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'HitBeat',
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSeparator(SidebarThemeExtension theme) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            theme.textColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required SidebarMenuItem item,
    required int index,
    required bool isExtended,
    required SidebarThemeExtension sidebarTheme,
    required bool showText,
    bool isFooter = false,
  }) {
    final isSelected = widget.controller.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: _SidebarItemWidget(
        item: item,
        isSelected: isSelected,
        isExtended: isExtended,
        showText: showText,
        sidebarTheme: sidebarTheme,
        isFooter: isFooter,
        slideAnimation: _slideAnimation,
        onTap: () {
          widget.controller.selectIndex(index);
          Modular.to.navigate(item.route);
        },
      ),
    );
  }
}

class _SidebarItemWidget extends StatefulWidget {
  const _SidebarItemWidget({
    required this.item,
    required this.isSelected,
    required this.isExtended,
    required this.showText,
    required this.sidebarTheme,
    required this.slideAnimation,
    required this.onTap,
    this.isFooter = false,
  });

  final SidebarMenuItem item;
  final bool isSelected;
  final bool isExtended;
  final bool showText;
  final SidebarThemeExtension sidebarTheme;
  final bool isFooter;
  final Animation<double> slideAnimation;
  final VoidCallback onTap;

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.sidebarTheme;
    final isSelected = widget.isSelected;
    final isExtended = widget.isExtended;
    final showText = widget.showText && isExtended; // ensure both conditions
    // Precompute decorations (static pattern, reuse border radius).
    final Decoration decoration = isSelected
        ? _selectedDecoration(theme)
        : _baseDecoration(theme);

    return Tooltip(
      message: isExtended ? '' : widget.item.tooltip ?? widget.item.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: RepaintBoundary(
            child: Container(
              decoration: decoration,
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: isExtended ? 18 : 8,
              ),
              child: Row(
                mainAxisAlignment: isExtended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.item.icon,
                    size: isSelected ? 22 : 20,
                    color: isSelected
                        ? theme.activeIconColor
                        : theme.textColor.withValues(
                            alpha: _isHovered ? 0.9 : 0.75,
                          ),
                  ),
                  if (showText) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: theme.textColor.withValues(
                            alpha: isSelected
                                ? 1
                                : _isHovered
                                ? 0.9
                                : 0.75,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Cached decoration builders to avoid rebuilding large BoxDecoration objects.
  static BoxDecoration _selectedDecoration(SidebarThemeExtension theme) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.actionColor.withValues(alpha: 0.12),
        border: Border.all(
          color: theme.actionColor.withValues(alpha: 0.37),
        ),
      );

  static BoxDecoration _baseDecoration(SidebarThemeExtension theme) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.canvasColor),
      );
}

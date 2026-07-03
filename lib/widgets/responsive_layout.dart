import 'package:flutter/material.dart';

/// Breakpoints for mobile / tablet / desktop (web & macOS).
abstract final class Responsive {
  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1024;
  static const double contentMaxWidth = 1200;
  static const double formMaxWidth = 720;
  static const double authCardMaxWidth = 440;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isDesktop(BuildContext context) =>
      widthOf(context) >= desktopBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = widthOf(context);
    return w >= mobileBreakpoint && w < desktopBreakpoint;
  }

  static double horizontalPadding(BuildContext context) {
    final w = widthOf(context);
    if (w >= desktopBreakpoint) return 40;
    if (w >= mobileBreakpoint) return 28;
    return 20;
  }

  /// Max width for form / settings / wallet scroll pages.
  static double scrollMaxWidth(BuildContext context) {
    final w = widthOf(context);
    if (w >= desktopBreakpoint) return 920;
    if (w >= mobileBreakpoint) return 680;
    return 560;
  }

  /// Inner panel width for dashboard tabs on desktop.
  static double dashboardPanelMaxWidth(BuildContext context) {
    if (!isDesktop(context)) return contentMaxWidth;
    return 1280;
  }

  /// Columns for quick-action / stat grids.
  static int gridColumns(BuildContext context, {int maxColumns = 4}) {
    final w = widthOf(context);
    if (w >= 1100) return maxColumns.clamp(2, 4);
    if (w >= 800) return 3;
    if (w >= 500) return 2;
    return 2;
  }
}

/// Centers page content and caps width on desktop/web.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = Responsive.contentMaxWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ??
        EdgeInsets.symmetric(
          horizontal: Responsive.horizontalPadding(context),
        );

    // Center + explicit width: Column stretch no longer expands this to full viewport.
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: pad,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Wraps a tab/screen so desktop/web content is centered with side gutters.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = Responsive.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isDesktop(context)) {
      return child;
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }
}

/// Login / register: centered card on mobile; split brand + form on desktop.
class ResponsiveAuthShell extends StatelessWidget {
  const ResponsiveAuthShell({
    super.key,
    required this.formChild,
    this.brandTitle = 'Digital Portal',
    this.brandSubtitle = 'Registration & Access Hub',
    this.footer,
  });

  final Widget formChild;
  final String brandTitle;
  final String brandSubtitle;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1E88E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white24,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          SafeArea(
            child: desktop
                ? _DesktopAuthLayout(
                    brandTitle: brandTitle,
                    brandSubtitle: brandSubtitle,
                    formChild: formChild,
                    footer: footer,
                  )
                : _MobileAuthLayout(
                    formChild: formChild,
                    brandTitle: brandTitle,
                    brandSubtitle: brandSubtitle,
                    footer: footer,
                  ),
          ),
        ],
      ),
    );
  }
}

class _MobileAuthLayout extends StatelessWidget {
  const _MobileAuthLayout({
    required this.formChild,
    required this.brandTitle,
    required this.brandSubtitle,
    this.footer,
  });

  final Widget formChild;
  final String brandTitle;
  final String brandSubtitle;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: Responsive.authCardMaxWidth + 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AuthBrandHeader(title: brandTitle, subtitle: brandSubtitle),
              const SizedBox(height: 40),
              formChild,
              if (footer != null) ...[const SizedBox(height: 32), footer!],
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopAuthLayout extends StatelessWidget {
  const _DesktopAuthLayout({
    required this.brandTitle,
    required this.brandSubtitle,
    required this.formChild,
    this.footer,
  });

  final String brandTitle;
  final String brandSubtitle;
  final Widget formChild;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/digital_india_logo.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        brandTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        brandSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Secure registration for students, businesses, farmers, and banks — one digital hub.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: Responsive.authCardMaxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    formChild,
                    if (footer != null) ...[const SizedBox(height: 24), footer!],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/digital_india_logo.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

/// Standard form pages: scrollable, max-width on wide screens.
class ResponsiveFormScroll extends StatelessWidget {
  const ResponsiveFormScroll({
    super.key,
    required this.child,
    this.formKey,
    this.maxWidth = Responsive.formMaxWidth,
    this.padding,
  });

  final Widget child;
  final GlobalKey<FormState>? formKey;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ??
        EdgeInsets.all(Responsive.horizontalPadding(context));

    final scroll = SingleChildScrollView(
      padding: pad,
      child: child,
    );

    final body = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: scroll,
      ),
    );

    if (formKey != null) {
      return Form(key: formKey, child: body);
    }
    return body;
  }
}

/// Wraps a list of equal-height tiles in a responsive grid.
class ResponsiveActionGrid extends StatelessWidget {
  const ResponsiveActionGrid({
    super.key,
    required this.children,
    this.itemHeight = 100,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        if (!maxW.isFinite || maxW <= 0) {
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: children,
          );
        }
        final cols = Responsive.gridColumns(context, maxColumns: 4);
        final totalSpacing = spacing * (cols - 1);
        final itemWidth = (maxW - totalSpacing) / cols;
        final height = Responsive.isDesktop(context) ? itemHeight + 12 : itemHeight;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map(
                (c) => SizedBox(
                  width: itemWidth,
                  height: height,
                  child: c,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Constrains any child to a centered max width (lists, columns, custom layouts).
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: padding != null ? Padding(padding: padding!, child: child) : child,
        ),
      ),
    );
  }
}

/// Standard scrollable page: centered column on desktop/web.
class ResponsiveScrollBody extends StatelessWidget {
  const ResponsiveScrollBody({
    super.key,
    required this.children,
    this.maxWidth,
    this.padding,
  });

  final List<Widget> children;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveMax = maxWidth ?? Responsive.scrollMaxWidth(context);
    return SingleChildScrollView(
      child: ResponsiveContent(
        maxWidth: effectiveMax,
        padding: padding ??
            EdgeInsets.all(Responsive.horizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Page title strip for desktop tabs (replaces heavy mobile SliverAppBar).
class DesktopPageHeader extends StatelessWidget {
  const DesktopPageHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sidebar navigation for dashboard on desktop/web.
class DesktopSideNavigation extends StatelessWidget {
  const DesktopSideNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.userName,
    this.userCategory,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String? userName;
  final String? userCategory;

  static const _accent = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Center(
              child: Image.asset(
                'assets/images/digital_india_logo.png',
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                _NavTile(
                  icon: Icons.home_filled,
                  label: 'Home',
                  selected: selectedIndex == 0,
                  onTap: () => onDestinationSelected(0),
                ),
                _NavTile(
                  icon: Icons.grid_view_rounded,
                  label: 'Services',
                  selected: selectedIndex == 1,
                  onTap: () => onDestinationSelected(1),
                ),
                _NavTile(
                  icon: Icons.person,
                  label: 'Profile',
                  selected: selectedIndex == 2,
                  onTap: () => onDestinationSelected(2),
                ),
              ],
            ),
          ),
          if (userName != null && userName!.isNotEmpty) ...[
            const Divider(height: 1),
            InkWell(
              onTap: () => onDestinationSelected(2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _accent.withValues(alpha: 0.12),
                    child: Text(
                      userName!.trim().isNotEmpty
                          ? userName!.trim()[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (userCategory != null)
                          Text(
                            userCategory!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? const Color(0xFF2196F3).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? const Color(0xFF2196F3) : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey.shade600,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                    color: selected ? const Color(0xFF2196F3) : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey.shade700,
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

/// ListView with responsive max width.
class ResponsiveListView extends StatelessWidget {
  const ResponsiveListView({
    super.key,
    this.children,
    this.itemCount,
    this.itemBuilder,
    this.maxWidth = 560,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : assert(children != null || (itemCount != null && itemBuilder != null));

  final List<Widget>? children;
  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final pad = padding ??
        EdgeInsets.all(Responsive.horizontalPadding(context));

    final Widget list;
    if (itemBuilder != null) {
      list = ListView.builder(
        padding: pad,
        itemCount: itemCount,
        itemBuilder: itemBuilder!,
        shrinkWrap: shrinkWrap,
        physics: physics,
      );
    } else {
      list = ListView(
        padding: pad,
        children: children!,
        shrinkWrap: shrinkWrap,
        physics: physics,
      );
    }

    return ResponsiveBody(maxWidth: maxWidth, child: list);
  }
}

/// Simple scaffold + centered scroll list (used from dashboard sub-routes).
Scaffold responsiveListScaffold(
  BuildContext context, {
  required String title,
  required List<Widget> children,
  double? maxWidth,
}) {
  return Scaffold(
    appBar: AppBar(title: Text(title), centerTitle: true),
    body: ResponsiveScrollBody(
      maxWidth: maxWidth ?? Responsive.scrollMaxWidth(context),
      children: children,
    ),
  );
}

/// Centered modal with sensible max width on desktop/web (avoids full-screen dialogs).
class ResponsiveDialog extends StatelessWidget {
  const ResponsiveDialog({
    super.key,
    required this.child,
    this.maxWidth = 440,
    this.maxHeight = 520,
  });

  final Widget child;
  final double maxWidth;
  final double maxHeight;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double maxWidth = 440,
    double maxHeight = 520,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => ResponsiveDialog(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: desktop ? 48 : 24,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width < maxWidth ? MediaQuery.of(context).size.width : maxWidth,
          child: child,
        ),
      ),
    );
  }
}

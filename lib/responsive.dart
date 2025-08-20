import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatefulWidget {
  final List<Widget> pages;
  final List<NavigationDestination> destinations;
  final List<String> titles;
  final bool forceMobileLayout;

  const ResponsiveScaffold({
    super.key,
    required this.pages,
    required this.destinations,
    required this.titles,
    this.forceMobileLayout = false,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final isMobile = widget.forceMobileLayout || c.maxWidth < 600;

        if (isMobile) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(title: Text(widget.titles[index])),

              body: widget.pages[index],
              bottomNavigationBar: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                destinations: widget.destinations,
              ),
              resizeToAvoidBottomInset: true,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

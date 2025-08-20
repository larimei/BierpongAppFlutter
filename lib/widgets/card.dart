import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AvatarCardPage extends StatefulWidget {
  final String appBarTitle;
  final IconData avatarIconData;
  final double avatarIconSize;
  final Widget child;
  final Widget? bottom;

  final Color initialAvatarIconColor;
  final ValueChanged<Color>? onAvatarColorsChanged;

  final double avatarRadius;
  final double topOffset;
  final double maxWidth;
  final EdgeInsets pagePadding;
  final EdgeInsets cardPadding;

  const AvatarCardPage({
    super.key,
    required this.appBarTitle,
    required this.avatarIconData,
    required this.child,
    this.bottom,
    this.avatarIconSize = 64,
    this.initialAvatarIconColor = const Color(0xFF1D2C6B),
    this.onAvatarColorsChanged,
    this.avatarRadius = 64,
    this.topOffset = 64,
    this.maxWidth = 420,
    this.pagePadding = const EdgeInsets.all(16),
    this.cardPadding = const EdgeInsets.fromLTRB(20, 56, 20, 24),
  });

  @override
  State<AvatarCardPage> createState() => _AvatarCardPageState();
}

class _AvatarCardPageState extends State<AvatarCardPage> {
  late Color _color;
  bool _showPicker = false;

  @override
  void initState() {
    super.initState();
    _color = widget.initialAvatarIconColor;
  }

  void _togglePicker() => setState(() => _showPicker = !_showPicker);

  void _setColor(Color c) {
    setState(() => _color = c);
    widget.onAvatarColorsChanged?.call((_color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.appBarTitle)),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_color, const Color.fromARGB(0, 255, 255, 255)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fullHeight = constraints.maxHeight;
              final cardHeight =
                  (fullHeight - widget.pagePadding.vertical - widget.topOffset)
                      .clamp(0.0, double.infinity);

              return Padding(
                padding: widget.pagePadding.copyWith(
                  top: widget.pagePadding.top + widget.topOffset,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: widget.maxWidth),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          height: cardHeight,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            child: Padding(
                              padding: widget.cardPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: widget.child,
                                    ),
                                  ),
                                  if (widget.bottom != null) ...[
                                    const SizedBox(height: 12),
                                    AnimatedPadding(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(
                                                  context,
                                                ).viewInsets.bottom >
                                                0
                                            ? 8
                                            : 0,
                                      ),
                                      child: widget.bottom!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: -widget.avatarRadius,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Material(
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _togglePicker,
                                child: CircleAvatar(
                                  radius: widget.avatarRadius,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    widget.avatarIconData,
                                    size: widget.avatarIconSize,
                                    color: _color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (_showPicker)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Material(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        12,
                                        8,
                                        8,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Change Color',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: _togglePicker,
                                            tooltip: 'Close',
                                            icon: const Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      child: ListView(
                                        padding: const EdgeInsets.all(16),
                                        children: [
                                          BlockPicker(
                                            pickerColor: _color,
                                            onColorChanged: _setColor,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SafeArea(
                                      top: false,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          8,
                                          16,
                                          16,
                                        ),
                                        child: FilledButton(
                                          onPressed: _togglePicker,
                                          child: const Text('Ready'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

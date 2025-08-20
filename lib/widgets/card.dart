import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AvatarCardPage extends StatefulWidget {
  final String appBarTitle;
  final IconData avatarIconData;
  final double avatarIconSize;
  final Widget child;
  final Widget? bottom;

  final Color initialAvatarBgColor;
  final Color initialAvatarIconColor;
  final ValueChanged<(Color bg, Color icon)>? onAvatarColorsChanged;

  final double avatarRadius;
  final double topOffset;
  final double maxWidth;
  final EdgeInsets pagePadding;
  final EdgeInsets cardPadding;
  final Gradient backgroundGradient;

  const AvatarCardPage({
    super.key,
    required this.appBarTitle,
    required this.avatarIconData,
    required this.child,
    this.bottom,
    this.avatarIconSize = 64,
    this.initialAvatarBgColor = const Color(0xFFFFFFFF),
    this.initialAvatarIconColor = const Color(0xFF1D2C6B),
    this.onAvatarColorsChanged,
    this.avatarRadius = 64,
    this.topOffset = 64,
    this.maxWidth = 420,
    this.pagePadding = const EdgeInsets.all(16),
    this.cardPadding = const EdgeInsets.fromLTRB(20, 56, 20, 24),
    this.backgroundGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0E1A3A), Color.fromARGB(0, 255, 255, 255)],
    ),
  });

  @override
  State<AvatarCardPage> createState() => _AvatarCardPageState();
}

class _AvatarCardPageState extends State<AvatarCardPage> {
  late Color _bg;
  late Color _fg;
  bool _showPicker = false;

  @override
  void initState() {
    super.initState();
    _bg = widget.initialAvatarBgColor;
    _fg = widget.initialAvatarIconColor;
  }

  void _togglePicker() => setState(() => _showPicker = !_showPicker);

  void _setBg(Color c) {
    setState(() => _bg = c);
    widget.onAvatarColorsChanged?.call((_bg, _fg));
  }

  void _setFg(Color c) {
    setState(() => _fg = c);
    widget.onAvatarColorsChanged?.call((_bg, _fg));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.appBarTitle)),
      body: Container(
        decoration: BoxDecoration(gradient: widget.backgroundGradient),
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
                                  backgroundColor: _bg,
                                  child: Icon(
                                    widget.avatarIconData,
                                    size: widget.avatarIconSize,
                                    color: _fg,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (_showPicker)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _togglePicker,
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.black45,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 360,
                                    ),
                                    child: Material(
                                      elevation: 12,
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                'Icon-Farbe',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 8),
                                              BlockPicker(
                                                pickerColor: _fg,
                                                onColorChanged: _setFg,
                                              ),
                                              const SizedBox(height: 16),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: FilledButton(
                                                  onPressed: _togglePicker,
                                                  child: const Text('Fertig'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

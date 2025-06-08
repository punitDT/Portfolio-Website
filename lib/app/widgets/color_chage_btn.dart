import 'package:flutter/material.dart';
import 'package:mysite/core/color/colors.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/core/res/responsive.dart';

class ColorChageButton extends StatelessWidget {
  final String text;
  final Function() onTap;
  const ColorChageButton({Key? key, required this.text, required this.onTap})
      : super(key: key);
  @override
  @override
  Widget build(BuildContext context) {
    return Responsive(
      desktop: DesktopCCButton(text: text, onTap: onTap),
      tablet: TabCCButton(text: text, onTap: onTap),
      mobile: MobileCCButton(text: text, onTap: onTap),
    );
  }
}

class MobileCCButton extends StatefulWidget {
  final String text;
  final Function() onTap;
  const MobileCCButton({Key? key, required this.text, required this.onTap})
      : super(key: key);
  @override

  // ignore: library_private_types_in_public_api
  _MobileCCButtonState createState() => _MobileCCButtonState();
}

class _MobileCCButtonState extends State<MobileCCButton> {
  double _animatedWidth = 0.0;
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    // theme
    var theme = Theme.of(context);

    return Stack(
      children: [
        if (!isHover)
          Container(
            height: 40,
            width: 140,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 40,
          width: _animatedWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: buttonGradi,
            boxShadow: isHover ? [glowShadow] : [],
          ),
        ),
        InkWell(
          onHover: (value) {
            setState(() {
              isHover = !isHover;
              _animatedWidth = value ? 140 : 0.0;
            });
          },
          onTap: () {
            setState(() => _animatedWidth = 140);
            widget.onTap();
          },
          child: SizedBox(
            height: 40,
            width: 140,
            child: Center(
              child: Text(
                widget.text.toUpperCase(),
                style: TextStyle(
                  color: isHover ? whiteColor : primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TabCCButton extends StatefulWidget {
  final String text;
  final Function() onTap;
  const TabCCButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);
  @override

  // ignore: library_private_types_in_public_api
  _TabCCButtonState createState() => _TabCCButtonState();
}

class _TabCCButtonState extends State<TabCCButton> {
  double _animatedWidth = 0.0;
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    // theme
    var theme = Theme.of(context);

    return Stack(
      children: [
        if (!isHover)
          Container(
            height: 50,
            width: 200,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 50,
          width: _animatedWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: buttonGradi,
            boxShadow: isHover ? [glowShadow] : [],
          ),
        ),
        InkWell(
            onHover: (value) {
              setState(() {
                isHover = !isHover;
                _animatedWidth = value ? 200 : 0.0;
              });
            },
            onTap: () {
              setState(() => _animatedWidth = 200);
              widget.onTap();
            },
            child: SizedBox(
              height: 50,
              width: 200,
              child: Center(
                child: Text(
                  widget.text.toUpperCase(),
                  style: TextStyle(
                    color: isHover ? whiteColor : primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class DesktopCCButton extends StatefulWidget {
  final String text;
  final Function() onTap;
  const DesktopCCButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);
  @override

  // ignore: library_private_types_in_public_api
  _DesktopCCButtonState createState() => _DesktopCCButtonState();
}

class _DesktopCCButtonState extends State<DesktopCCButton> {
  double _animatedWidth = 0.0;
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Stack(
      children: [
        if (!isHover)
          Container(
            height: 60,
            width: 240,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          width: _animatedWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: buttonGradi,
            boxShadow: isHover ? [glowShadow] : [],
          ),
        ),
        InkWell(
          onHover: (value) {
            setState(() {
              isHover = !isHover;
              _animatedWidth = value ? 240 : 0.0;
            });
          },
          onTap: () {
            setState(() => _animatedWidth = 240);
            widget.onTap();
          },
          child: SizedBox(
            height: 60,
            width: 240,
            child: Center(
              child: Text(
                widget.text.toUpperCase(),
                style: TextStyle(
                  color: isHover ? whiteColor : primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

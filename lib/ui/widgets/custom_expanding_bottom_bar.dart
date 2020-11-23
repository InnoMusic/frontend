
import 'package:flutter/material.dart';

class CustomExpandingBottomNavBar extends StatefulWidget {
  /// Height of the navigation bar item
  final double navBarHeight;

  /// Items in the BottomNavigationBar
  final List<CustomExpandingBottomBarItem> items;

  /// Duration of the selection animation
  final Duration animationDuration;

  /// The selected index of the bar
  final int selectedIndex;

  /// Callback when an item is selected
  final ValueChanged<int> onIndexChanged;

  /// The background color of the BottomNavigationBar
  final Color backgroundColor;

  CustomExpandingBottomNavBar({
    this.navBarHeight = 100.0,
    @required this.items,
    this.animationDuration = const Duration(milliseconds: 200),
    @required this.selectedIndex,
    @required this.onIndexChanged,
    this.backgroundColor = Colors.white,
  }) : assert(items.length >= 2);

  @override
  _ExpandingBottomBarState createState() => _ExpandingBottomBarState();
}

class _ExpandingBottomBarState extends State<CustomExpandingBottomNavBar>
    with TickerProviderStateMixin {
  /// Hosts all the controllers controlling the boxes.
  List<AnimationController> _controllers = [];

  /// The current chosen index
  int indexChosen = 0;

  @override
  void initState() {
    super.initState();
    // Initialise all animation controllers.
    for (int i = 0; i < widget.items.length; i++) {
      _controllers.add(
        AnimationController(
          vsync: this,
          duration: widget.animationDuration,
        ),
      );
    }
    // Start animation for initially selected controller.
    _controllers[widget.selectedIndex].forward();
  }

  @override
  Widget build(BuildContext context) {
    _changeValue();
    return Container(
      height: widget.navBarHeight,
      color: widget.backgroundColor,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.items.map((item) {
            int index = widget.items.indexOf(item);
            return CustomExpandingDisplayItem(
              item.text,
              item.icon,
              item.iconColor,
              widget.navBarHeight,
              _controllers[index],
                  () {
                widget.onIndexChanged(index);
              },
              item.selectedColor,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _changeValue() {
    _controllers.forEach((controller) => controller.reverse());
    _controllers[widget.selectedIndex].forward();
  }
}

class CustomExpandingBottomBarItem {
  /// Icon to be displayed in the BottomNavigationBar
  IconData icon;
  Color iconColor;
  /// Title of the item
  String text;

  /// The color of the selected item
  Color selectedColor;

  CustomExpandingBottomBarItem({
    @required this.icon,
    @required this.iconColor,
    @required this.text,
    @required this.selectedColor,
  });
}


class CustomExpandingDisplayItem extends StatefulWidget {
  /// The title of the item in the BottomNavigationBar
  final String title;

  /// The icon in the item of the BottomNavigationBar
  final IconData icon;

  /// The height of the box (Carries the BottomNavigationBar height).
  final double height;

  /// The animation controller to control the flip animation.
  final AnimationController controller;

  /// Callback for when the box is selected (Not when the box is reversed).
  final VoidCallback onTapped;

  /// The color of the icon and background when selected
  final Color color;
  final Color iconColor;

  CustomExpandingDisplayItem(
      this.title,
      this.icon,
      this.iconColor,
      this.height,
      this.controller,
      this.onTapped,
      this.color,
      );

  @override
  _ExpandingDisplayItemState createState() => _ExpandingDisplayItemState();
}

class _ExpandingDisplayItemState extends State<CustomExpandingDisplayItem>
    with TickerProviderStateMixin {
  /// Tween for going from 0 to pi/2 radian and vice versa.
  Animation animation;

  /// Controller for controlling the Box.
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: 200));
    } else {
      controller = widget.controller;
    }
    animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    );

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTapped();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(
            widget.color.red,
            widget.color.green,
            widget.color.blue,
            (animation.value as double) / 2.5,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.height / 3.2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: animation.value != 0.0
                  ? Text(
                widget.title,
                style: TextStyle(
                  color: widget.iconColor,
                  fontSize: (widget.height / 4) * (animation.value as double),
                ),
              )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
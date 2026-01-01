import 'package:flutter/material.dart';

class CustomLoading extends StatefulWidget {
  final Color color;
  final double size;

  const CustomLoading({
    Key? key,
    this.color = Colors.black,
    this.size = 50,
  }) : super(key: key);

  @override
  State<CustomLoading> createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size / 4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final value = (_controller.value - delay).clamp(0.0, 1.0);
              final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2);
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.size / 20),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: widget.size / 6,
                    height: widget.size / 6,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Color? backgroundColor;
  final Color? iconColor;

  const CustomFAB({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    this.backgroundColor,
    this.iconColor,  
  }) : super(key: key); 

  @override
  State<CustomFAB> createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fabColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final iconColor = widget.iconColor ?? theme.colorScheme.onPrimary;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: Tooltip(
                message: widget.tooltip,
                child: InkWell(
                  onTapDown: (_) => _animationController.forward(),
                  onTapUp: (_) {
                    _animationController.reverse();
                    widget.onPressed();
                  },
                  onTapCancel: () => _animationController.reverse(),
                  borderRadius: BorderRadius.circular(32),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: fabColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: fabColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      child: Icon(
                        widget.icon,
                        color: iconColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
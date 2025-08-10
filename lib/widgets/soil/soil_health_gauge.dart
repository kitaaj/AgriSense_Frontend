import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/app_constants.dart';

class SoilHealthGauge extends StatefulWidget {
  final double score;
  final String rating;
  final double size;

  const SoilHealthGauge({
    super.key,
    required this.score,
    required this.rating,
    this.size = 200,
  });

  @override
  State<SoilHealthGauge> createState() => _SoilHealthGaugeState();
}

class _SoilHealthGaugeState extends State<SoilHealthGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _GaugeBackgroundPainter(),
          ),
          
          // Animated Progress Arc
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugeProgressPainter(
                  progress: _animation.value,
                  color: _getScoreColor(widget.score),
                ),
              );
            },
          ),
          
          // Center Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final animatedScore = (_animation.value * widget.score).round();
                  return Text(
                    '$animatedScore',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(widget.score),
                      fontSize: widget.size * 0.15,
                    ),
                  );
                },
              ),
              Text(
                widget.rating,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: widget.size * 0.08,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Soil Health Score',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: widget.size * 0.06,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          
          // Score Indicators
          Positioned(
            bottom: widget.size * 0.1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildScoreIndicator('Poor', Colors.red, 0, 20),
                _buildScoreIndicator('Fair', Colors.orange, 20, 40),
                _buildScoreIndicator('Good', Colors.lightGreen, 40, 60),
                _buildScoreIndicator('Excellent', Colors.green, 60, 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(String label, Color color, double min, double max) {
    final isActive = widget.score >= min && widget.score < max;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive ? color : Colors.grey[500],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: widget.size * 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    // Draw background arc (270 degrees)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75, // Start angle (top-left)
      math.pi * 1.5,   // Sweep angle (270 degrees)
      false,
      paint,
    );
    
    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i <= 10; i++) {
      final angle = -math.pi * 0.75 + (math.pi * 1.5 * i / 10);
      final startRadius = radius - 6;
      final endRadius = radius + 6;
      
      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GaugeProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugeProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    // Draw progress arc
    final sweepAngle = math.pi * 1.5 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75, // Start angle (top-left)
      sweepAngle,      // Sweep angle based on progress
      false,
      paint,
    );
    
    // Draw progress indicator dot
    if (progress > 0) {
      final angle = -math.pi * 0.75 + sweepAngle;
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);
      
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(dotX, dotY), 8, dotPaint);
      
      // Inner white dot
      final innerDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(dotX, dotY), 4, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _GaugeProgressPainter &&
           (oldDelegate.progress != progress || oldDelegate.color != color);
  }
}

class SoilHealthMiniGauge extends StatelessWidget {
  final double score;
  final String label;
  final double size;

  const SoilHealthMiniGauge({
    super.key,
    required this.score,
    required this.label,
    this.size = 60,
  });

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
              ),
              
              // Progress circle
              SizedBox(
                width: size - 8,
                height: size - 8,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                ),
              ),
              
              // Score text
              Text(
                '${score.round()}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                  fontSize: size * 0.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: size * 0.15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


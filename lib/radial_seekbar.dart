import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttery/gestures.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'theme.dart';

class RadialSeekBar extends StatefulWidget {
  const RadialSeekBar({
    Key key,
  }) : super(key: key);

  @override
  _RadialSeekBarState createState() => _RadialSeekBarState();
}

class _RadialSeekBarState extends State<RadialSeekBar> {
  double _progressPercent;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  @override
  void initState() {
    super.initState();
  }

  void _onDragStart(BuildContext context, PolarCoord coord) {
    _startDragCoord = coord;
    _startDragPercent = _progressPercent;
  }

  void _onDragUpdate(BuildContext context, PolarCoord coord) {
    final dragAngle = coord.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / (2 * pi);
    final schedule = Provider.of<AudioSchedule>(context);
    _currentDragPercent = (_startDragPercent + dragPercent) % 1.0;
    schedule.player.setSeekPosition(
        SeekPosition(schedule.song.audioDuration * _currentDragPercent));
  }

  void _onDragEnd(BuildContext context) {
    final schedule = Provider.of<AudioSchedule>(context);
    _startDragPercent = null;
    _startDragCoord = null;
    schedule.seek(_currentDragPercent);
    schedule.player.setSeekPosition(SeekPosition(schedule.song.audioDuration * _currentDragPercent, isEnd: true));
    _currentDragPercent = null;
  }

  @override
  Widget build(BuildContext context) {
    final schedule = Provider.of<AudioSchedule>(context);
    final audioPosition = Provider.of<AudioPosition>(context);
    final seekPosition = Provider.of<SeekPosition>(context);

    _progressPercent =
        (audioPosition.inSeconds / schedule.song.audioDuration.inSeconds) % 1.0;

    return RadialDragGestureDetector(
      onRadialDragStart: (coord) => _onDragStart(context, coord),
      onRadialDragUpdate: (coord) => _onDragUpdate(context, coord),
      onRadialDragEnd: () => _onDragEnd(context),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 180.0,
            height: 180.0,
            child: RadialProgressBar(
              trackColor: Color(0xFFDDDDDD),
              progressPercent: _progressPercent,
              progressColor: accentColor,
              thumbPosition:
                  seekPosition.inSeconds / schedule.song.audioDuration.inSeconds,
              thumbColor: lightAccentColor,
              innerPadding: EdgeInsets.all(10.0),
              outerPadding: EdgeInsets.all(10.0),
              child: ClipOval(
                clipper: CircleClipper(),
                child: schedule.song.albumArt,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbSize;
  final Color thumbColor;
  final double thumbPosition;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  const RadialProgressBar({
    Key key,
    this.trackWidth = 3.0,
    this.trackColor = Colors.grey,
    this.progressWidth = 5.0,
    this.progressColor = Colors.black,
    this.progressPercent = 0.0,
    this.thumbSize = 10.0,
    this.thumbColor = Colors.black,
    this.thumbPosition = 0.0,
    this.outerPadding = const EdgeInsets.all(0.0),
    this.innerPadding = const EdgeInsets.all(0.0),
    this.child,
  }) : super(key: key);

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding,
      child: CustomPaint(
        foregroundPainter: RadialProgressBarPainter(
          trackWidth: widget.trackWidth,
          trackColor: widget.trackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbSize: widget.thumbSize,
          thumbColor: widget.thumbColor,
          thumbPosition: widget.thumbPosition,
        ),
        child: Padding(
          padding: _insetsForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }

  EdgeInsets _insetsForPainter() {
    final outerThickness = max(
          widget.trackWidth,
          max(
            widget.progressWidth,
            widget.thumbSize,
          ),
        ) /
        2.0;
    return EdgeInsets.all(outerThickness);
  }
}

class RadialProgressBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final double progressPercent;
  final Paint progressPaint;
  final double thumbSize;
  final double thumbPosition;
  final Paint thumbPaint;

  RadialProgressBarPainter({
    @required this.trackWidth,
    @required trackColor,
    @required this.progressWidth,
    @required progressColor,
    @required this.progressPercent,
    @required this.thumbSize,
    @required thumbColor,
    @required this.thumbPosition,
  })  : trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(progressWidth, thumbSize));
    Size constraintSize = Size(
      size.width - outerThickness,
      size.height - outerThickness,
    );

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(constraintSize.width, constraintSize.height) / 2;

    // track
    canvas.drawCircle(center, radius, trackPaint);

    // progress
    final progressAngle = 2 * pi * progressPercent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progressAngle,
      false,
      progressPaint,
    );

    // thumb
    final thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final thumbX = cos(thumbAngle) * radius;
    final thumbY = sin(thumbAngle) * radius;
    final thumbCenter = Offset(thumbX, thumbY) + center;
    final thumbRadius = thumbSize / 2;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

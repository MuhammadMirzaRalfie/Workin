import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/exercise_poses.dart';
import '../theme.dart';

// Proporsi figur (tinggi berdiri ±1). Koordinat dunia: y ke atas, lantai y=0,
// figur menghadap ke kanan (+x) pada tampak samping.
const _torso = 0.30;
const _shoulderAt = 0.27;
const _headRadius = 0.062;
const _headOffset = 0.075;
const _upperArm = 0.15;
const _forearm = 0.14;
const _thigh = 0.22;
const _shin = 0.22;
const _shoulderHalf = 0.075;
const _hipHalf = 0.045;
const _footLength = 0.075;

enum FigureView { side, front }

/// Benda bantu di sekitar figur (kursi, meja, dinding).
class Prop {
  /// Kotak dari lantai: [rect] dalam koordinat dunia (y ke atas).
  const Prop.box(Rect this.rect) : wallX = null;

  /// Dinding tegak di posisi x.
  const Prop.wall(double this.wallX) : rect = null;

  final Rect? rect;
  final double? wallX;
}

/// Satu tungkai (lengan/kaki).
///
/// [Limb.reach]: ujung tungkai diarahkan ke titik dunia; siku/lutut dihitung
/// otomatis (inverse kinematics). [bend] +1 menekuk berlawanan jarum jam,
/// -1 searah jarum jam.
/// [Limb.angles]: sudut ruas atas & bawah dalam derajat, 0 = lurus ke bawah,
/// positif = ke arah hadap figur.
class Limb {
  const Limb.reach(Offset this.target, {this.bend = 1}) : upper = 0, lower = 0;

  const Limb.angles(this.upper, this.lower) : target = null, bend = 1;

  final Offset? target;
  final int bend;
  final double upper;
  final double lower;
}

class Pose {
  const Pose({
    required this.hip,
    required this.arm,
    required this.leg,
    this.torso = 0,
    this.head = 0,
    this.foot,
    Limb? farArm,
    Limb? farLeg,
  }) : farArm = farArm ?? arm,
       farLeg = farLeg ?? leg;

  /// Arah telapak kaki (derajat, 0 = ke bawah, 90 = ke depan). Null = tidak
  /// digambar; dipakai bila posisi tumit penting, mis. calf raise.
  final double? foot;

  /// Posisi pinggul di dunia.
  final Offset hip;

  /// Kemiringan badan dari tegak, derajat; positif = condong ke depan.
  final double torso;

  /// Kemiringan kepala relatif terhadap badan, derajat.
  final double head;

  final Limb arm;
  final Limb farArm;
  final Limb leg;
  final Limb farLeg;
}

class ExerciseAnimation {
  const ExerciseAnimation(
    this.frames, {
    this.view = FigureView.side,
    this.keyFrame = 1,
    this.transition = const Duration(milliseconds: 850),
    this.props = const [],
  });

  /// Pose kunci, dianimasikan berurutan lalu kembali ke awal.
  final List<Pose> frames;
  final FigureView view;
  final List<Prop> props;

  /// Pose yang ditampilkan saat diam (thumbnail / animasi dimatikan).
  final int keyFrame;
  final Duration transition;
}

// ---------------------------------------------------------------------------
// Rangka hasil hitung: posisi pinggul + sudut tiap ruas (radian, y ke atas).

class _Rig {
  const _Rig(this.hip, this.torso, this.head, this.limbs, [this.foot]);

  final Offset hip;
  final double torso;
  final double head;
  final double? foot;

  /// [armNear, armFar, legNear, legFar], masing-masing (ruas atas, ruas bawah).
  final List<(double, double)> limbs;
}

Offset _polar(double angle, double length) =>
    Offset(math.cos(angle) * length, math.sin(angle) * length);

/// Sudut dunia dari derajat "0 = ke bawah, positif = ke depan".
double _downAngle(double degrees) => -math.pi / 2 + degrees * math.pi / 180;

/// Sudut dunia dari derajat "0 = ke atas, positif = ke depan".
double _upAngle(double degrees) => math.pi / 2 - degrees * math.pi / 180;

class _Roots {
  _Roots(this.hip, double torso, FigureView view) {
    final dir = _polar(torso, 1);
    final perp = Offset(dir.dy, -dir.dx);
    final shoulder = hip + dir * _shoulderAt;
    final sw = view == FigureView.front ? _shoulderHalf : 0.0;
    final hw = view == FigureView.front ? _hipHalf : 0.0;
    shoulders = (shoulder + perp * sw, shoulder - perp * sw);
    hips = (hip + perp * hw, hip - perp * hw);
    neck = hip + dir * _torso;
  }

  final Offset hip;
  late final (Offset, Offset) shoulders;
  late final (Offset, Offset) hips;
  late final Offset neck;
}

(double, double) _solveLimb(Limb limb, Offset root, double l1, double l2) {
  final target = limb.target;
  if (target == null) {
    return (_downAngle(limb.upper), _downAngle(limb.lower));
  }
  final delta = target - root;
  final base = math.atan2(delta.dy, delta.dx);
  final d = delta.distance.clamp((l1 - l2).abs() + 1e-4, l1 + l2 - 1e-4);
  final cosA = ((l1 * l1 + d * d - l2 * l2) / (2 * l1 * d)).clamp(-1.0, 1.0);
  final a1 = base + limb.bend * math.acos(cosA);
  final joint = root + _polar(a1, l1);
  final end = root + _polar(base, d);
  final toEnd = end - joint;
  return (a1, math.atan2(toEnd.dy, toEnd.dx));
}

_Rig _solve(Pose pose, FigureView view) {
  final torso = _upAngle(pose.torso);
  final roots = _Roots(pose.hip, torso, view);
  final foot = pose.foot;
  return _Rig(
    pose.hip,
    torso,
    _upAngle(pose.torso + pose.head),
    [
      _solveLimb(pose.arm, roots.shoulders.$1, _upperArm, _forearm),
      _solveLimb(pose.farArm, roots.shoulders.$2, _upperArm, _forearm),
      _solveLimb(pose.leg, roots.hips.$1, _thigh, _shin),
      _solveLimb(pose.farLeg, roots.hips.$2, _thigh, _shin),
    ],
    foot == null ? null : _downAngle(foot),
  );
}

double _lerpAngle(double a, double b, double t) {
  var diff = (b - a) % (2 * math.pi);
  if (diff > math.pi) diff -= 2 * math.pi;
  return a + diff * t;
}

_Rig _lerpRig(_Rig a, _Rig b, double t) => _Rig(
  Offset.lerp(a.hip, b.hip, t)!,
  _lerpAngle(a.torso, b.torso, t),
  _lerpAngle(a.head, b.head, t),
  [
    for (var i = 0; i < 4; i++)
      (
        _lerpAngle(a.limbs[i].$1, b.limbs[i].$1, t),
        _lerpAngle(a.limbs[i].$2, b.limbs[i].$2, t),
      ),
  ],
  a.foot != null && b.foot != null
      ? _lerpAngle(a.foot!, b.foot!, t)
      : (t < 0.5 ? a.foot : b.foot),
);

/// Titik-titik figur siap digambar.
class _Points {
  _Points(_Rig rig, FigureView view) {
    final roots = _Roots(rig.hip, rig.torso, view);
    hip = rig.hip;
    neck = roots.neck;
    head = neck + _polar(rig.head, _headOffset);
    shoulder = roots.shoulders.$1;
    List<Offset> chain(Offset root, (double, double) a, double l1, double l2) {
      final joint = root + _polar(a.$1, l1);
      return [root, joint, joint + _polar(a.$2, l2)];
    }

    limbs = [
      chain(roots.shoulders.$1, rig.limbs[0], _upperArm, _forearm),
      chain(roots.shoulders.$2, rig.limbs[1], _upperArm, _forearm),
      chain(roots.hips.$1, rig.limbs[2], _thigh, _shin),
      chain(roots.hips.$2, rig.limbs[3], _thigh, _shin),
    ];
    final foot = rig.foot;
    toes =
        foot == null
            ? const []
            : [
              limbs[2][2] + _polar(foot, _footLength),
              limbs[3][2] + _polar(foot, _footLength),
            ];
  }

  late final Offset hip;
  late final Offset neck;
  late final Offset head;
  late final Offset shoulder;
  late final List<List<Offset>> limbs;

  /// Ujung jari kaki [dekat, jauh]; kosong jika telapak tidak digambar.
  late final List<Offset> toes;

  Iterable<Offset> get all => [hip, neck, for (final l in limbs) ...l, ...toes];
}

// ---------------------------------------------------------------------------

/// Figur garis yang memperagakan gerakan. Kosong jika belum ada posenya.
class ExerciseFigure extends StatefulWidget {
  const ExerciseFigure({
    super.key,
    required this.exerciseId,
    this.color,
    this.animate = true,
    this.frame,
  });

  final String exerciseId;

  /// Tampilkan pose tertentu secara diam (mengabaikan [animate]).
  final int? frame;

  /// Bawaan: warna teks utama.
  final Color? color;
  final bool animate;

  static bool hasPose(String exerciseId) =>
      exerciseAnimations.containsKey(exerciseId);

  @override
  State<ExerciseFigure> createState() => _ExerciseFigureState();
}

class _ExerciseFigureState extends State<ExerciseFigure>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  ExerciseAnimation? _animation;
  List<_Rig> _rigs = const [];
  Rect _bounds = Rect.zero;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ExerciseFigure oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseId != widget.exerciseId ||
        oldWidget.animate != widget.animate) {
      _controller?.dispose();
      _controller = null;
      _load();
      _syncController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  void _load() {
    final animation = exerciseAnimations[widget.exerciseId];
    _animation = animation;
    if (animation == null) return;
    _rigs = [for (final f in animation.frames) _solve(f, animation.view)];

    // Batas tetap per gerakan supaya figur tidak "melompat" saat bergerak.
    var bounds = Rect.fromLTRB(0, 0, 0, 0);
    for (var i = 0; i < _rigs.length; i++) {
      final next = _rigs[(i + 1) % _rigs.length];
      for (final t in const [0.0, 0.5]) {
        final points = _Points(_lerpRig(_rigs[i], next, t), animation.view);
        for (final p in points.all) {
          bounds = bounds.expandToInclude(
            Rect.fromCircle(center: p, radius: 0.03),
          );
        }
        bounds = bounds.expandToInclude(
          Rect.fromCircle(center: points.head, radius: _headRadius),
        );
      }
    }
    for (final prop in animation.props) {
      final rect = prop.rect;
      if (rect != null) bounds = bounds.expandToInclude(rect);
      final x = prop.wallX;
      if (x != null) {
        bounds = bounds.expandToInclude(Rect.fromLTRB(x - 0.02, 0, x, 0.9));
      }
    }
    _bounds = bounds.inflate(0.04);
  }

  void _syncController() {
    final animation = _animation;
    final shouldAnimate =
        widget.animate &&
        widget.frame == null &&
        animation != null &&
        animation.frames.length > 1 &&
        !MediaQuery.of(context).disableAnimations;
    if (shouldAnimate && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: animation.transition * animation.frames.length,
      )..repeat();
    } else if (!shouldAnimate && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  _Rig _rigAt(double progress) {
    final n = _rigs.length;
    final position = progress * n;
    final index = position.floor() % n;
    final local = position - position.floor();
    // Tahan sebentar di tiap pose, lalu bergerak halus.
    const hold = 0.25;
    final t =
        local < hold
            ? 0.0
            : Curves.easeInOut.transform((local - hold) / (1 - hold));
    return _lerpRig(_rigs[index], _rigs[(index + 1) % n], t);
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animation;
    if (animation == null) return const SizedBox.shrink();
    final color = widget.color ?? context.palette.tinta;
    final controller = _controller;
    final keyIndex = (widget.frame ?? animation.keyFrame).clamp(
      0,
      _rigs.length - 1,
    );

    Widget paint(_Rig rig) => CustomPaint(
      painter: _FigurePainter(
        points: _Points(rig, animation.view),
        bounds: _bounds,
        color: color,
        view: animation.view,
        props: animation.props,
      ),
      size: Size.infinite,
    );

    return Semantics(
      image: true,
      label: 'Ilustrasi gerakan',
      child:
          controller == null
              ? paint(_rigs[keyIndex])
              : AnimatedBuilder(
                animation: controller,
                builder: (_, __) => paint(_rigAt(controller.value)),
              ),
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter({
    required this.points,
    required this.bounds,
    required this.color,
    required this.view,
    required this.props,
  });

  final _Points points;
  final Rect bounds;
  final Color color;
  final FigureView view;
  final List<Prop> props;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scale = math.min(
      size.width / bounds.width,
      size.height / bounds.height,
    );
    final dx = (size.width - bounds.width * scale) / 2;
    final dy = (size.height - bounds.height * scale) / 2;
    Offset map(Offset p) => Offset(
      dx + (p.dx - bounds.left) * scale,
      dy + (bounds.bottom - p.dy) * scale,
    );

    final stroke = 0.048 * scale;
    final near =
        Paint()
          ..color = color
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
    final far =
        Paint()
          ..color =
              view == FigureView.front ? color : color.withValues(alpha: 0.35)
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    // Lantai.
    final floorY = map(Offset.zero).dy;
    canvas.drawLine(
      Offset(0, floorY),
      Offset(size.width, floorY),
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..strokeWidth = math.max(1, 0.012 * scale),
    );

    // Benda bantu: garis tipis dengan isian samar, di belakang figur.
    final propLine =
        Paint()
          ..color = color.withValues(alpha: 0.45)
          ..strokeWidth = math.max(1, 0.018 * scale)
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;
    final propFill = Paint()..color = color.withValues(alpha: 0.08);
    for (final prop in props) {
      final rect = prop.rect;
      if (rect != null) {
        final r = Rect.fromPoints(
          map(Offset(rect.left, rect.top)),
          map(Offset(rect.right, rect.bottom)),
        );
        canvas.drawRect(r, propFill);
        canvas.drawRect(r, propLine);
      }
      final x = prop.wallX;
      if (x != null) {
        canvas.drawLine(map(Offset(x, 0)), map(Offset(x, 0.9)), propLine);
      }
    }

    void limb(List<Offset> l, Paint paint) {
      final path =
          Path()
            ..moveTo(map(l[0]).dx, map(l[0]).dy)
            ..lineTo(map(l[1]).dx, map(l[1]).dy)
            ..lineTo(map(l[2]).dx, map(l[2]).dy);
      canvas.drawPath(path, paint);
    }

    void toe(int leg, Paint paint) {
      if (points.toes.isEmpty) return;
      canvas.drawLine(
        map(points.limbs[leg][2]),
        map(points.toes[leg - 2]),
        paint,
      );
    }

    // Belakang → depan: tungkai jauh, badan, kepala, tungkai dekat.
    limb(points.limbs[3], far);
    toe(3, far);
    limb(points.limbs[1], far);
    canvas.drawLine(map(points.hip), map(points.neck), near);
    canvas.drawCircle(
      map(points.head),
      _headRadius * scale,
      Paint()..color = color,
    );
    limb(points.limbs[2], near);
    toe(2, near);
    limb(points.limbs[0], near);
  }

  @override
  bool shouldRepaint(_FigurePainter old) =>
      old.points != points ||
      old.color != color ||
      old.bounds != bounds ||
      old.props != props;
}

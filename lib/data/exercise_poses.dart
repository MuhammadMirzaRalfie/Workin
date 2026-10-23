import 'package:flutter/painting.dart';

import '../widgets/exercise_figure.dart';

// Pose kunci tiap gerakan. Koordinat dunia: lantai y=0, y ke atas, tinggi
// berdiri ±1, figur menghadap ke kanan. Panjang ruas: badan 0,30 (bahu di
// 0,27), lengan 0,15 + 0,14, kaki 0,22 + 0,22. Posisi tangan/kaki yang
// menempel di lantai atau benda dibuat tetap antar pose supaya tidak
// "bergeser" saat dianimasikan.

// ----------------------------- Pose bersama -----------------------------

const _armsDown = Limb.angles(6, 10);

const _stand = Pose(
  hip: Offset(0, 0.44),
  arm: _armsDown,
  leg: Limb.reach(Offset(0.02, 0)),
);

const _standArmsUp = Pose(
  hip: Offset(0, 0.44),
  arm: Limb.angles(175, 178),
  leg: Limb.reach(Offset(0.02, 0)),
);

const _squatBottom = Pose(
  hip: Offset(-0.13, 0.23),
  torso: 38,
  arm: Limb.angles(85, 90),
  leg: Limb.reach(Offset(0.02, 0)),
);

// Push-up: badan lurus dari kaki ke bahu, tangan tetap di (0,30; 0).
const _pushUpUp = Pose(
  hip: Offset(0.054, 0.18),
  torso: 65.9,
  arm: Limb.reach(Offset(0.30, 0), bend: -1),
  leg: Limb.reach(Offset(-0.348, 0)),
);

const _pushUpDown = Pose(
  hip: Offset(0.088, 0.062),
  torso: 81.9,
  arm: Limb.reach(Offset(0.30, 0), bend: -1),
  leg: Limb.reach(Offset(-0.348, 0)),
);

const _pushUp = ExerciseAnimation(keyFrame: 0, [_pushUpUp, _pushUpDown]);

// Push-up lutut: lutut di lantai, tulang kering rebah ke belakang.
const _kneePushUp = ExerciseAnimation(keyFrame: 0, [
  Pose(
    hip: Offset(0.062, 0.130),
    torso: 53.7,
    arm: Limb.reach(Offset(0.28, 0), bend: -1),
    leg: Limb.reach(Offset(-0.335, 0)),
  ),
  Pose(
    hip: Offset(0.101, 0.040),
    torso: 79.4,
    arm: Limb.reach(Offset(0.28, 0), bend: -1),
    leg: Limb.reach(Offset(-0.335, 0)),
  ),
]);

// Pike push-up: pinggul tinggi, kepala turun ke depan tangan.
const _pikePushUp = ExerciseAnimation(keyFrame: 1, [
  Pose(
    hip: Offset(-0.183, 0.389),
    torso: 134,
    arm: Limb.reach(Offset(0.22, 0)),
    leg: Limb.reach(Offset(-0.36, 0)),
  ),
  Pose(
    hip: Offset(-0.10, 0.33),
    torso: 145,
    arm: Limb.reach(Offset(0.22, 0)),
    leg: Limb.reach(Offset(-0.36, 0)),
  ),
]);

const _plank = Pose(
  hip: Offset(0.036, 0.093),
  torso: 77.8,
  arm: Limb.angles(0, 90),
  leg: Limb.reach(Offset(-0.394, 0)),
);

// Lunge: kaki dekat = depan, kaki jauh = belakang.
const _standSplit = Pose(
  hip: Offset(0, 0.44),
  arm: _armsDown,
  leg: Limb.reach(Offset(0.02, 0)),
  farLeg: Limb.reach(Offset(-0.02, 0)),
);

const _lungeBottom = Pose(
  hip: Offset(-0.02, 0.25),
  arm: _armsDown,
  leg: Limb.reach(Offset(0.24, 0)),
  farLeg: Limb.reach(Offset(-0.30, 0)),
);

// Berbaring telentang, kepala di kiri.
const _lyingCrunchLegs = Limb.reach(Offset(0.28, 0));

const _bridgeDown = Pose(
  hip: Offset(0, 0.065),
  torso: -90,
  arm: Limb.angles(90, 90),
  leg: Limb.reach(Offset(0.30, 0)),
);

const _bridgeUp = Pose(
  hip: Offset(-0.01, 0.185),
  torso: -115.6,
  head: 30,
  arm: Limb.angles(90, 90),
  leg: Limb.reach(Offset(0.30, 0)),
);

// Tengkurap, kepala di kanan.
const _proneLegs = Limb.angles(-90, -90);

/// Lari/jalan di tempat: lengan berayun berlawanan dengan kaki yang diangkat.
Pose _stride({
  required double hipY,
  required Limb liftedLeg,
  required bool nearLifted,
  required Limb forwardArm,
  required Limb backArm,
}) {
  const support = Limb.reach(Offset(0, 0));
  return Pose(
    hip: Offset(0, hipY),
    arm: nearLifted ? backArm : forwardArm,
    farArm: nearLifted ? forwardArm : backArm,
    leg: nearLifted ? liftedLeg : support,
    farLeg: nearLifted ? support : liftedLeg,
  );
}

List<Pose> _strides({
  required double hipY,
  required Limb liftedLeg,
  required Limb forwardArm,
  required Limb backArm,
}) => [
  for (final near in [true, false])
    _stride(
      hipY: hipY,
      nearLifted: near,
      liftedLeg: liftedLeg,
      forwardArm: forwardArm,
      backArm: backArm,
    ),
];

// ------------------------------- Gerakan -------------------------------

final exerciseAnimations = <String, ExerciseAnimation>{
  // ---------- Kardio & seluruh tubuh ----------

  // Tampak depan: tungkai "jauh" = sisi kiri.
  'jumping_jack': const ExerciseAnimation(view: FigureView.front, [
    Pose(
      hip: Offset(0, 0.44),
      arm: Limb.angles(8, 4),
      farArm: Limb.angles(-8, -4),
      leg: Limb.reach(Offset(0.05, 0)),
      farLeg: Limb.reach(Offset(-0.05, 0), bend: -1),
    ),
    Pose(
      hip: Offset(0, 0.40),
      arm: Limb.angles(150, 165),
      farArm: Limb.angles(-150, -165),
      leg: Limb.reach(Offset(0.21, 0)),
      farLeg: Limb.reach(Offset(-0.21, 0), bend: -1),
    ),
  ]),

  'high_knees': ExerciseAnimation(
    keyFrame: 0,
    transition: const Duration(milliseconds: 420),
    _strides(
      hipY: 0.46,
      liftedLeg: const Limb.angles(95, -5),
      forwardArm: const Limb.angles(40, 130),
      backArm: const Limb.angles(-40, 50),
    ),
  ),

  'stationary_run': ExerciseAnimation(
    keyFrame: 0,
    transition: const Duration(milliseconds: 480),
    _strides(
      hipY: 0.45,
      liftedLeg: const Limb.angles(40, -25),
      forwardArm: const Limb.angles(20, 70),
      backArm: const Limb.angles(-20, 30),
    ),
  ),

  'walk_in_place': ExerciseAnimation(
    keyFrame: 0,
    transition: const Duration(milliseconds: 650),
    _strides(
      hipY: 0.44,
      liftedLeg: const Limb.angles(30, -15),
      forwardArm: const Limb.angles(20, 30),
      backArm: const Limb.angles(-20, -10),
    ),
  ),

  // Jalan di tempat dengan lutut tinggi dan lengan berputar.
  'warm_up_march': ExerciseAnimation(
    keyFrame: 0,
    transition: const Duration(milliseconds: 650),
    _strides(
      hipY: 0.44,
      liftedLeg: const Limb.angles(80, 0),
      forwardArm: const Limb.angles(150, 165),
      backArm: const Limb.angles(-35, -25),
    ),
  ),

  // Berdiri → jongkok, tangan ke lantai → plank → jongkok → lompat.
  'modified_burpee': const ExerciseAnimation(
    keyFrame: 2,
    transition: Duration(milliseconds: 600),
    [
      _stand,
      Pose(
        hip: Offset(-0.08, 0.20),
        torso: 70,
        arm: Limb.reach(Offset(0.22, 0), bend: -1),
        leg: Limb.reach(Offset(0.02, 0)),
      ),
      Pose(
        hip: Offset(-0.026, 0.18),
        torso: 65.9,
        arm: Limb.reach(Offset(0.22, 0), bend: -1),
        leg: Limb.reach(Offset(-0.428, 0)),
      ),
      Pose(
        hip: Offset(-0.08, 0.20),
        torso: 70,
        arm: Limb.reach(Offset(0.22, 0), bend: -1),
        leg: Limb.reach(Offset(0.02, 0)),
      ),
      Pose(
        hip: Offset(0, 0.54),
        arm: Limb.angles(170, 175),
        leg: Limb.reach(Offset(0.02, 0.10)),
      ),
    ],
  ),

  // Posisi push-up, lutut ditarik ke dada bergantian.
  'mountain_climber': const ExerciseAnimation(
    keyFrame: 0,
    transition: Duration(milliseconds: 420),
    [
      Pose(
        hip: Offset(0.054, 0.18),
        torso: 65.9,
        arm: Limb.reach(Offset(0.30, 0), bend: -1),
        leg: Limb.reach(Offset(0.10, 0.03)),
        farLeg: Limb.reach(Offset(-0.348, 0)),
      ),
      Pose(
        hip: Offset(0.054, 0.18),
        torso: 65.9,
        arm: Limb.reach(Offset(0.30, 0), bend: -1),
        leg: Limb.reach(Offset(-0.348, 0)),
        farLeg: Limb.reach(Offset(0.10, 0.03)),
      ),
    ],
  ),

  'cool_down_stretch':
      const ExerciseAnimation(transition: Duration(milliseconds: 1400), [
        _standArmsUp,
        Pose(
          hip: Offset(-0.06, 0.44),
          torso: 95,
          arm: Limb.angles(5, 0),
          leg: Limb.reach(Offset(0.02, 0)),
        ),
      ]),

  // ---------- Dada, bahu, lengan ----------

  // Lebar tangan tidak terlihat dari samping, jadi variasi ini memakai
  // figur push-up dasar.
  'push_up': _pushUp,
  'wide_push_up': _pushUp,
  'diamond_push_up': _pushUp,
  'knee_push_up': _kneePushUp,
  'knee_wide_push_up': _kneePushUp,

  // Tangan di tepi kasur/meja setinggi 0,28.
  'incline_push_up': const ExerciseAnimation(
    keyFrame: 0,
    props: [Prop.box(Rect.fromLTRB(0.28, 0, 0.62, 0.28))],
    [
      Pose(
        hip: Offset(0.135, 0.347),
        torso: 37.8,
        arm: Limb.reach(Offset(0.32, 0.28), bend: -1),
        leg: Limb.reach(Offset(-0.136, 0)),
      ),
      Pose(
        hip: Offset(0.219, 0.260),
        torso: 53.6,
        arm: Limb.reach(Offset(0.32, 0.28), bend: -1),
        leg: Limb.reach(Offset(-0.136, 0)),
      ),
    ],
  ),

  // Kaki di atas kursi.
  'decline_push_up': const ExerciseAnimation(
    keyFrame: 0,
    props: [Prop.box(Rect.fromLTRB(-0.62, 0, -0.32, 0.22))],
    [
      Pose(
        hip: Offset(0.032, 0.271),
        torso: 86,
        arm: Limb.reach(Offset(0.30, 0), bend: -1),
        leg: Limb.reach(Offset(-0.405, 0.24)),
      ),
      Pose(
        hip: Offset(0.0265, 0.153),
        torso: 101.3,
        arm: Limb.reach(Offset(0.30, 0), bend: -1),
        leg: Limb.reach(Offset(-0.405, 0.24)),
      ),
    ],
  ),

  // Turun, lalu dorong hingga tangan terangkat.
  'plyo_push_up': const ExerciseAnimation(
    keyFrame: 1,
    transition: Duration(milliseconds: 600),
    [
      _pushUpDown,
      Pose(
        hip: Offset(0.031, 0.223),
        torso: 59.5,
        arm: Limb.angles(0, 0),
        leg: Limb.reach(Offset(-0.348, 0)),
      ),
    ],
  ),

  // Push-up, lalu putar badan dan angkat satu tangan.
  'push_up_rotation': const ExerciseAnimation(keyFrame: 2, [
    _pushUpDown,
    _pushUpUp,
    Pose(
      hip: Offset(0.054, 0.18),
      torso: 65.9,
      arm: Limb.angles(180, 180),
      farArm: Limb.reach(Offset(0.30, 0), bend: -1),
      leg: Limb.reach(Offset(-0.348, 0)),
    ),
  ]),

  'pike_push_up': _pikePushUp,
  // Bentuk gerakannya sama dengan pike push-up dari samping.
  'elevated_pike_push_up': _pikePushUp,

  // Tangan di tepi kursi di belakang badan.
  'chair_dip': const ExerciseAnimation(
    keyFrame: 1,
    props: [Prop.box(Rect.fromLTRB(-0.35, 0, -0.03, 0.25))],
    [
      Pose(
        hip: Offset(-0.054, 0.271),
        torso: 5,
        arm: Limb.reach(Offset(-0.05, 0.25), bend: -1),
        leg: Limb.reach(Offset(0.20, 0)),
      ),
      Pose(
        hip: Offset(-0.0335, 0.131),
        torso: 5,
        arm: Limb.reach(Offset(-0.05, 0.25), bend: -1),
        leg: Limb.reach(Offset(0.20, 0)),
      ),
    ],
  ),

  // Tengkurap: tangan, dada, dan kaki terangkat bersamaan.
  'superman': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: 90,
      arm: Limb.angles(90, 90),
      leg: _proneLegs,
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: 80,
      arm: Limb.angles(105, 108),
      leg: Limb.angles(-100, -103),
    ),
  ]),

  // Tampak samping hanya memperlihatkan fase Y (lengan terangkat ke depan).
  'prone_yt_raise': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: 88,
      arm: Limb.angles(90, 90),
      leg: _proneLegs,
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: 84,
      arm: Limb.angles(115, 118),
      leg: _proneLegs,
    ),
  ]),

  'plank_shoulder_tap':
      const ExerciseAnimation(transition: Duration(milliseconds: 600), [
        _pushUpUp,
        Pose(
          hip: Offset(0.054, 0.18),
          torso: 65.9,
          arm: Limb.reach(Offset(0.27, 0.25), bend: -1),
          farArm: Limb.reach(Offset(0.30, 0), bend: -1),
          leg: Limb.reach(Offset(-0.348, 0)),
        ),
      ]),

  // ---------- Perut & inti ----------
  'crunch': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(90, 90),
      leg: _lyingCrunchLegs,
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: -70,
      head: 10,
      arm: Limb.angles(78, 82),
      leg: _lyingCrunchLegs,
    ),
  ]),

  // Lengan lurus sejajar badan, di atas kepala.
  'long_arm_crunch': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(-90, -90),
      leg: _lyingCrunchLegs,
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: -70,
      arm: Limb.angles(-110, -110),
      leg: _lyingCrunchLegs,
    ),
  ]),

  // Bahu terangkat, tangan di samping kepala, kaki mengayuh.
  'bicycle_crunch': const ExerciseAnimation(
    keyFrame: 0,
    transition: Duration(milliseconds: 650),
    [
      Pose(
        hip: Offset(0, 0.065),
        torso: -70,
        arm: Limb.reach(Offset(-0.33, 0.22), bend: -1),
        leg: Limb.angles(160, 90),
        farLeg: Limb.angles(115, 115),
      ),
      Pose(
        hip: Offset(0, 0.065),
        torso: -70,
        arm: Limb.reach(Offset(-0.33, 0.22), bend: -1),
        leg: Limb.angles(115, 115),
        farLeg: Limb.angles(160, 90),
      ),
    ],
  ),

  // Lutut 90°, lalu pinggul digulung ke arah dada.
  'reverse_crunch': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(90, 90),
      leg: Limb.angles(180, 90),
    ),
    Pose(
      hip: Offset(0, 0.11),
      torso: -97.4,
      head: 7,
      arm: Limb.angles(90, 90),
      leg: Limb.angles(-155, 175),
    ),
  ]),

  'vertical_leg_crunch': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(150, 160),
      leg: Limb.angles(175, 180),
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: -66,
      head: 10,
      arm: Limb.angles(160, 168),
      leg: Limb.angles(175, 180),
    ),
  ]),

  // Tangan & kaki berlawanan diturunkan bergantian.
  'dead_bug': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(180, 180),
      leg: Limb.angles(180, 90),
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(-100, -100),
      farArm: Limb.angles(180, 180),
      leg: Limb.angles(180, 90),
      farLeg: Limb.angles(100, 100),
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(180, 180),
      leg: Limb.angles(180, 90),
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(180, 180),
      farArm: Limb.angles(-100, -100),
      leg: Limb.angles(100, 100),
      farLeg: Limb.angles(180, 90),
    ),
  ]),

  // Tahan: satu pose saja.
  'plank': const ExerciseAnimation(keyFrame: 0, [_plank]),

  'side_plank': const ExerciseAnimation(keyFrame: 0, [
    Pose(
      hip: Offset(0.036, 0.093),
      torso: 77.8,
      arm: Limb.angles(180, 180),
      farArm: Limb.angles(0, 90),
      leg: Limb.reach(Offset(-0.394, 0)),
    ),
  ]),

  // ---------- Kaki & bokong ----------
  'squat': const ExerciseAnimation([_stand, _squatBottom]),

  'box_squat': const ExerciseAnimation(
    props: [Prop.box(Rect.fromLTRB(-0.42, 0, -0.13, 0.24))],
    [
      _stand,
      Pose(
        hip: Offset(-0.15, 0.27),
        torso: 35,
        arm: Limb.angles(85, 90),
        leg: Limb.reach(Offset(0.02, 0)),
      ),
    ],
  ),

  'squat_jump':
      const ExerciseAnimation(transition: Duration(milliseconds: 600), [
        Pose(
          hip: Offset(-0.13, 0.23),
          torso: 38,
          arm: Limb.angles(-30, -20),
          leg: Limb.reach(Offset(0.02, 0)),
        ),
        Pose(
          hip: Offset(0, 0.56),
          arm: Limb.angles(165, 172),
          leg: Limb.reach(Offset(0.02, 0.12)),
        ),
      ]),

  'lunge': const ExerciseAnimation([_standSplit, _lungeBottom]),

  // Kaki depan tetap, kaki belakang melangkah mundur.
  'reverse_lunge': const ExerciseAnimation([
    _standSplit,
    Pose(
      hip: Offset(-0.20, 0.25),
      arm: _armsDown,
      leg: Limb.reach(Offset(0.04, 0)),
      farLeg: Limb.reach(Offset(-0.52, 0)),
    ),
  ]),

  // Tampak depan: menekuk ke kanan, kaki kiri lurus.
  'side_lunge': const ExerciseAnimation(view: FigureView.front, [
    Pose(
      hip: Offset(0, 0.44),
      arm: Limb.angles(10, 10),
      farArm: Limb.angles(-10, -10),
      leg: Limb.reach(Offset(0.09, 0)),
      farLeg: Limb.reach(Offset(-0.09, 0), bend: -1),
    ),
    Pose(
      hip: Offset(0.10, 0.26),
      torso: 10,
      arm: Limb.angles(10, 10),
      farArm: Limb.angles(-10, -10),
      leg: Limb.reach(Offset(0.30, 0)),
      farLeg: Limb.reach(Offset(-0.28, 0), bend: -1),
    ),
  ]),

  // Punggung kaki belakang di atas kursi.
  'bulgarian_split_squat': const ExerciseAnimation(
    props: [Prop.box(Rect.fromLTRB(-0.66, 0, -0.36, 0.22))],
    [
      Pose(
        hip: Offset(-0.02, 0.40),
        torso: 10,
        arm: _armsDown,
        leg: Limb.reach(Offset(0.18, 0)),
        farLeg: Limb.reach(Offset(-0.40, 0.24)),
      ),
      Pose(
        hip: Offset(-0.06, 0.22),
        torso: 10,
        arm: _armsDown,
        leg: Limb.reach(Offset(0.18, 0)),
        farLeg: Limb.reach(Offset(-0.40, 0.24)),
      ),
    ],
  ),

  // Lunge → lompat & tukar kaki di udara → lunge sisi lain.
  'split_squat_jump': const ExerciseAnimation(
    keyFrame: 0,
    transition: Duration(milliseconds: 550),
    [
      _lungeBottom,
      Pose(
        hip: Offset(0, 0.50),
        arm: Limb.angles(30, 60),
        farArm: Limb.angles(-30, -10),
        leg: Limb.reach(Offset(0.10, 0.10)),
        farLeg: Limb.reach(Offset(-0.12, 0.10)),
      ),
      Pose(
        hip: Offset(-0.02, 0.25),
        arm: _armsDown,
        leg: Limb.reach(Offset(-0.30, 0)),
        farLeg: Limb.reach(Offset(0.24, 0)),
      ),
      Pose(
        hip: Offset(0, 0.50),
        arm: Limb.angles(-30, -10),
        farArm: Limb.angles(30, 60),
        leg: Limb.reach(Offset(-0.12, 0.10)),
        farLeg: Limb.reach(Offset(0.10, 0.10)),
      ),
    ],
  ),

  // Berdiri satu kaki, turun sampai menyentuh kursi di belakang.
  'single_leg_squat_chair': const ExerciseAnimation(
    props: [Prop.box(Rect.fromLTRB(-0.44, 0, -0.15, 0.24))],
    [
      Pose(
        hip: Offset(0, 0.44),
        arm: _armsDown,
        leg: Limb.reach(Offset(0, 0)),
        farLeg: Limb.angles(25, 25),
      ),
      Pose(
        hip: Offset(-0.16, 0.27),
        torso: 30,
        arm: Limb.angles(85, 90),
        leg: Limb.reach(Offset(0, 0)),
        farLeg: Limb.angles(80, 88),
      ),
    ],
  ),

  // Tahan: punggung menempel dinding, paha sejajar lantai.
  'wall_sit': const ExerciseAnimation(
    keyFrame: 0,
    props: [Prop.wall(-0.19)],
    [
      Pose(
        hip: Offset(-0.15, 0.22),
        arm: Limb.angles(10, 10),
        leg: Limb.reach(Offset(0.07, 0)),
      ),
    ],
  ),

  // Telapak digambar supaya tumit yang terangkat terlihat.
  'calf_raise': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.465),
      arm: _armsDown,
      leg: Limb.reach(Offset(0, 0.025)),
      foot: 90,
    ),
    Pose(
      hip: Offset(0, 0.525),
      arm: _armsDown,
      leg: Limb.reach(Offset(0, 0.085)),
      foot: 38,
    ),
  ]),

  'single_leg_calf_raise': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.465),
      arm: _armsDown,
      leg: Limb.reach(Offset(0, 0.025)),
      farLeg: Limb.angles(0, -90),
      foot: 90,
    ),
    Pose(
      hip: Offset(0, 0.525),
      arm: _armsDown,
      leg: Limb.reach(Offset(0, 0.085)),
      farLeg: Limb.angles(0, -90),
      foot: 38,
    ),
  ]),

  // Naik ke kursi dengan kaki depan.
  'step_up': const ExerciseAnimation(
    keyFrame: 1,
    props: [Prop.box(Rect.fromLTRB(0.10, 0, 0.42, 0.22))],
    [
      Pose(
        hip: Offset(-0.05, 0.44),
        torso: 5,
        arm: Limb.angles(-20, -10),
        farArm: Limb.angles(20, 30),
        leg: Limb.reach(Offset(0.20, 0.22)),
        farLeg: Limb.reach(Offset(-0.05, 0)),
      ),
      Pose(
        hip: Offset(0.20, 0.66),
        torso: 5,
        arm: Limb.angles(20, 30),
        farArm: Limb.angles(-20, -10),
        leg: Limb.reach(Offset(0.20, 0.22)),
        farLeg: Limb.angles(70, 0),
      ),
    ],
  ),

  'glute_bridge': const ExerciseAnimation([_bridgeDown, _bridgeUp]),

  'single_leg_glute_bridge': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(90, 90),
      leg: Limb.reach(Offset(0.30, 0)),
      farLeg: Limb.angles(120, 120),
    ),
    Pose(
      hip: Offset(-0.01, 0.185),
      torso: -115.6,
      head: 30,
      arm: Limb.angles(90, 90),
      leg: Limb.reach(Offset(0.30, 0)),
      farLeg: Limb.angles(100, 100),
    ),
  ]),

  // Merangkak, satu kaki diangkat ke belakang-atas, lutut 90°.
  'quadruped_hip_extension': const ExerciseAnimation([
    Pose(
      hip: Offset(-0.02, 0.22),
      torso: 75,
      arm: Limb.reach(Offset(0.241, 0), bend: -1),
      leg: Limb.reach(Offset(-0.24, 0)),
    ),
    Pose(
      hip: Offset(-0.02, 0.22),
      torso: 75,
      arm: Limb.reach(Offset(0.241, 0), bend: -1),
      leg: Limb.angles(-90, 180),
      farLeg: Limb.reach(Offset(-0.24, 0)),
    ),
  ]),

  // Tampak depan sambil berbaring miring: kaki atas diangkat.
  'side_lying_leg_raise': const ExerciseAnimation(view: FigureView.front, [
    Pose(
      hip: Offset(0, 0.08),
      torso: -90,
      arm: Limb.angles(90, 90),
      farArm: Limb.angles(-90, -90),
      leg: Limb.angles(90, 90),
      farLeg: Limb.angles(90, 90),
    ),
    Pose(
      hip: Offset(0, 0.08),
      torso: -90,
      arm: Limb.angles(90, 90),
      farArm: Limb.angles(-90, -90),
      leg: Limb.angles(118, 118),
      farLeg: Limb.angles(90, 90),
    ),
  ]),

  // ---------- 5BX Chart 1 ----------

  // Sentuh lantai, tegak, lalu lengkungkan badan ke belakang.
  'toe_touch_stretch':
      const ExerciseAnimation(transition: Duration(milliseconds: 1000), [
        _standArmsUp,
        Pose(
          hip: Offset(-0.08, 0.44),
          torso: 110,
          arm: Limb.angles(5, 0),
          leg: Limb.reach(Offset(0.02, 0)),
        ),
        _standArmsUp,
        Pose(
          hip: Offset(0.02, 0.44),
          torso: -15,
          arm: Limb.angles(-165, -170),
          leg: Limb.reach(Offset(0.02, 0)),
        ),
      ]),

  // Kaki lurus, bangun sampai bisa melihat tumit.
  'partial_sit_up': const ExerciseAnimation([
    Pose(
      hip: Offset(0, 0.065),
      torso: -90,
      arm: Limb.angles(90, 90),
      leg: Limb.angles(90, 90),
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: -68,
      head: 12,
      arm: Limb.angles(80, 82),
      leg: Limb.angles(90, 90),
    ),
  ]),

  // Tengkurap, kepala dan satu kaki diangkat bergantian.
  'back_extension': const ExerciseAnimation(keyFrame: 0, [
    Pose(
      hip: Offset(0, 0.065),
      torso: 85,
      head: -5,
      arm: Limb.angles(-90, -90),
      leg: Limb.angles(-105, -105),
      farLeg: _proneLegs,
    ),
    Pose(
      hip: Offset(0, 0.065),
      torso: 85,
      head: -5,
      arm: Limb.angles(-90, -90),
      leg: _proneLegs,
      farLeg: Limb.angles(-105, -105),
    ),
  ]),
};

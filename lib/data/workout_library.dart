import '../models/custom_workout.dart';
import '../models/exercise.dart';

// Nilai MET dari 2024 Adult Compendium of Physical Activities
// (Herrmann et al., J Sport Health Sci 2024;13(1):6–12), kategori calisthenics:
//   02020 berat  = 7.5 (jumping jack, burpee, dsb.)
//   02022 sedang = 3.8 (push-up, sit-up, lunge, dsb.)
//   02024 ringan = 2.8 (crunch, plank, dsb.)
// Setiap gerakan dipetakan ke kategori terdekat, jadi kalori tetap perkiraan
// dan cenderung konservatif.
const _metVigorous = 7.5;
const _metModerate = 3.8;
const _metLight = 2.8;

class Exercises {
  // ---------- Kardio & seluruh tubuh ----------
  static const jumpingJack = Exercise(
    id: 'jumping_jack',
    name: 'Jumping Jack',
    met: _metVigorous,
    cue: 'Lompat sambil membuka kaki dan mengangkat tangan ke atas kepala.',
  );
  static const highKnees = Exercise(
    id: 'high_knees',
    name: 'High Knees',
    met: _metVigorous,
    cue: 'Lari di tempat, angkat lutut setinggi pinggang.',
  );
  static const modifiedBurpee = Exercise(
    id: 'modified_burpee',
    name: 'Burpee (tanpa push-up)',
    met: _metVigorous,
    cue:
        'Jongkok, tangan ke lantai, lempar kaki ke belakang, kembali, lalu '
        'lompat.',
  );
  static const mountainClimber = Exercise(
    id: 'mountain_climber',
    name: 'Mountain Climber',
    met: _metVigorous,
    cue:
        'Posisi push-up, tarik lutut ke dada bergantian dengan cepat. '
        'Pinggul tetap rendah.',
  );
  static const walkInPlace = Exercise(
    id: 'walk_in_place',
    name: 'Jalan di Tempat',
    met: _metLight,
    cue: 'Jalan santai di tempat, atur napas.',
  );
  static const warmUpMarch = Exercise(
    id: 'warm_up_march',
    name: 'Jalan di Tempat & Putar Lengan',
    met: _metLight,
    cue:
        'Jalan di tempat sambil memutar lengan ke depan dan ke belakang '
        'untuk menghangatkan sendi.',
  );
  static const coolDownStretch = Exercise(
    id: 'cool_down_stretch',
    name: 'Peregangan Pendinginan',
    met: _metLight,
    cue:
        'Regangkan otot yang tadi dilatih, tahan tiap posisi 15–20 detik, '
        'napas pelan.',
  );

  // ---------- Dada, bahu, lengan ----------
  static const inclinePushUp = Exercise(
    id: 'incline_push_up',
    name: 'Incline Push-up',
    met: _metModerate,
    cue:
        'Tangan di tepi meja/kasur yang kokoh, badan lurus. Makin tinggi '
        'tumpuan, makin ringan.',
  );
  static const kneePushUp = Exercise(
    id: 'knee_push_up',
    name: 'Push-up Lutut',
    met: _metModerate,
    cue:
        'Lutut di lantai, badan lurus dari lutut ke kepala, turunkan dada '
        'mendekati lantai.',
  );
  static const kneeWidePushUp = Exercise(
    id: 'knee_wide_push_up',
    name: 'Push-up Lutut Lebar',
    met: _metModerate,
    cue: 'Seperti push-up lutut, tangan dibuka lebih lebar dari bahu.',
  );
  static const pushUp = Exercise(
    id: 'push_up',
    name: 'Push-up',
    met: _metModerate,
    cue:
        'Badan lurus dari kepala ke tumit, turunkan dada mendekati lantai. '
        'Terlalu berat? Tumpukan lutut di lantai.',
  );
  static const widePushUp = Exercise(
    id: 'wide_push_up',
    name: 'Push-up Lebar',
    met: _metModerate,
    cue: 'Tangan lebih lebar dari bahu, siku mengarah ke samping-belakang.',
  );
  static const diamondPushUp = Exercise(
    id: 'diamond_push_up',
    name: 'Diamond Push-up',
    met: _metModerate,
    cue:
        'Ibu jari dan telunjuk membentuk berlian di bawah dada. Lebih '
        'menekankan trisep. Boleh bertumpu lutut.',
  );
  static const declinePushUp = Exercise(
    id: 'decline_push_up',
    name: 'Decline Push-up',
    met: _metModerate,
    cue: 'Kaki di atas kursi, tangan di lantai. Badan tetap lurus.',
  );
  static const plyoPushUp = Exercise(
    id: 'plyo_push_up',
    name: 'Push-up Eksplosif',
    met: _metVigorous,
    cue:
        'Dorong lantai sekuat mungkin hingga tangan sedikit terangkat, '
        'mendarat dengan siku sedikit ditekuk.',
  );
  static const pushUpRotation = Exercise(
    id: 'push_up_rotation',
    name: 'Push-up + Rotasi',
    met: _metModerate,
    cue:
        'Setelah push-up, putar badan ke samping dan angkat satu tangan ke '
        'atas. Bergantian kiri-kanan.',
  );
  static const pikePushUp = Exercise(
    id: 'pike_push_up',
    name: 'Pike Push-up',
    met: _metModerate,
    cue:
        'Pinggul diangkat tinggi membentuk huruf V terbalik, tekuk siku '
        'hingga kepala mendekati lantai. Melatih bahu.',
  );
  static const elevatedPikePushUp = Exercise(
    id: 'elevated_pike_push_up',
    name: 'Pike Push-up Kaki di Kursi',
    met: _metModerate,
    cue:
        'Seperti pike push-up, tapi kaki di atas kursi agar beban bahu '
        'lebih besar.',
  );
  static const chairDip = Exercise(
    id: 'chair_dip',
    name: 'Tricep Dip (Kursi)',
    met: _metModerate,
    cue:
        'Tangan bertumpu di tepi kursi, turunkan badan dengan menekuk siku. '
        'Lutut ditekuk lebih ringan, kaki lurus lebih berat.',
  );
  static const superman = Exercise(
    id: 'superman',
    name: 'Superman',
    met: _metLight,
    cue: 'Tengkurap, angkat tangan, dada, dan kaki bersamaan, tahan 2 detik.',
  );
  static const proneYTRaise = Exercise(
    id: 'prone_yt_raise',
    name: 'Angkat Lengan Y-T',
    met: _metLight,
    cue:
        'Tengkurap, angkat lengan membentuk huruf Y lalu T. Rapatkan tulang '
        'belikat. Melatih punggung atas.',
  );
  static const plankShoulderTap = Exercise(
    id: 'plank_shoulder_tap',
    name: 'Plank Shoulder Tap',
    met: _metModerate,
    cue:
        'Posisi push-up, sentuh bahu berlawanan bergantian. Jaga pinggul '
        'tidak bergoyang.',
  );

  // ---------- Perut & inti ----------
  static const crunch = Exercise(
    id: 'crunch',
    name: 'Crunch',
    met: _metLight,
    cue: 'Berbaring, lutut ditekuk, angkat bahu dari lantai dengan otot perut.',
  );
  static const longArmCrunch = Exercise(
    id: 'long_arm_crunch',
    name: 'Long-arm Crunch',
    met: _metLight,
    cue: 'Seperti crunch, tapi lengan lurus di atas kepala sejajar telinga.',
  );
  static const bicycleCrunch = Exercise(
    id: 'bicycle_crunch',
    name: 'Bicycle Crunch',
    met: _metLight,
    cue:
        'Punggung bawah menempel lantai, lutut 45°. Sentuhkan siku ke lutut '
        'berlawanan seperti mengayuh, perlahan.',
  );
  static const reverseCrunch = Exercise(
    id: 'reverse_crunch',
    name: 'Reverse Crunch',
    met: _metLight,
    cue:
        'Lutut ditekuk 90°, kaki disilangkan. Tarik pinggul sedikit dari '
        'lantai dengan otot perut.',
  );
  static const verticalLegCrunch = Exercise(
    id: 'vertical_leg_crunch',
    name: 'Vertical Leg Crunch',
    met: _metLight,
    cue:
        'Kaki lurus ke atas, disilangkan di pergelangan. Angkat badan ke '
        'arah lutut, dagu tidak menempel dada.',
  );
  static const deadBug = Exercise(
    id: 'dead_bug',
    name: 'Dead Bug',
    met: _metLight,
    cue:
        'Berbaring, tangan ke atas, lutut 90°. Turunkan tangan dan kaki '
        'berlawanan perlahan, punggung bawah tetap menempel lantai.',
  );
  static const plank = Exercise(
    id: 'plank',
    name: 'Plank',
    met: _metLight,
    cue: 'Tahan badan lurus bertumpu pada siku, kencangkan perut.',
  );
  static const sidePlank = Exercise(
    id: 'side_plank',
    name: 'Side Plank',
    met: _metLight,
    cue: 'Bertumpu pada satu siku, angkat pinggul. Ganti sisi di tengah waktu.',
  );

  // ---------- Kaki & bokong ----------
  static const boxSquat = Exercise(
    id: 'box_squat',
    name: 'Squat ke Kursi',
    met: _metModerate,
    cue:
        'Turunkan pinggul hingga bokong menyentuh kursi, lalu berdiri lagi '
        'tanpa duduk penuh.',
  );
  static const squat = Exercise(
    id: 'squat',
    name: 'Squat',
    met: _metModerate,
    cue: 'Turunkan pinggul seperti mau duduk, lutut sejajar ujung kaki.',
  );
  static const jumpSquat = Exercise(
    id: 'squat_jump',
    name: 'Squat Jump',
    met: _metVigorous,
    cue: 'Squat, lalu lompat setinggi mungkin, mendarat dengan lutut ditekuk.',
  );
  static const lunge = Exercise(
    id: 'lunge',
    name: 'Lunge',
    met: _metModerate,
    cue: 'Langkah ke depan, turunkan lutut belakang. Bergantian kiri-kanan.',
  );
  static const reverseLunge = Exercise(
    id: 'reverse_lunge',
    name: 'Lunge Mundur',
    met: _metModerate,
    cue:
        'Langkah ke belakang, turunkan lutut belakang mendekati lantai. '
        'Lebih ramah lutut daripada lunge maju.',
  );
  static const sideLunge = Exercise(
    id: 'side_lunge',
    name: 'Side Lunge',
    met: _metModerate,
    cue: 'Langkah lebar ke samping, tekuk satu lutut, kaki lain tetap lurus.',
  );
  static const bulgarianSplitSquat = Exercise(
    id: 'bulgarian_split_squat',
    name: 'Bulgarian Split Squat',
    met: _metModerate,
    cue:
        'Punggung kaki belakang di atas kursi, turunkan badan dengan kaki '
        'depan.',
  );
  static const splitSquatJump = Exercise(
    id: 'split_squat_jump',
    name: 'Split Squat Jump',
    met: _metVigorous,
    cue: 'Posisi lunge, lompat dan tukar kaki di udara, mendarat pelan.',
  );
  static const singleLegSquatToChair = Exercise(
    id: 'single_leg_squat_chair',
    name: 'Squat 1 Kaki ke Kursi',
    met: _metModerate,
    cue:
        'Berdiri satu kaki di depan kursi, turun hingga menyentuh kursi, '
        'lalu berdiri dengan kaki yang sama.',
  );
  static const wallSit = Exercise(
    id: 'wall_sit',
    name: 'Wall Sit',
    met: _metModerate,
    cue: 'Bersandar di dinding dengan posisi duduk, paha sejajar lantai.',
  );
  static const calfRaise = Exercise(
    id: 'calf_raise',
    name: 'Calf Raise',
    met: _metLight,
    cue:
        'Berdiri, jinjitkan kaki setinggi mungkin, turunkan perlahan. Boleh '
        'berpegangan dinding.',
  );
  static const singleLegCalfRaise = Exercise(
    id: 'single_leg_calf_raise',
    name: 'Calf Raise 1 Kaki',
    met: _metLight,
    cue: 'Seperti calf raise, tapi bertumpu pada satu kaki.',
  );
  static const stepUp = Exercise(
    id: 'step_up',
    name: 'Step-up ke Kursi',
    met: _metModerate,
    cue:
        'Naik ke kursi yang kokoh dengan satu kaki, dorong lewat tumit, '
        'lalu turun.',
  );
  static const gluteBridge = Exercise(
    id: 'glute_bridge',
    name: 'Glute Bridge',
    met: _metLight,
    cue:
        'Berbaring, tekuk lutut, angkat pinggul hingga lurus dengan paha. '
        'Remas bokong di atas.',
  );
  static const singleLegGluteBridge = Exercise(
    id: 'single_leg_glute_bridge',
    name: 'Glute Bridge 1 Kaki',
    met: _metModerate,
    cue: 'Seperti glute bridge, satu kaki diangkat lurus.',
  );
  static const quadrupedHipExtension = Exercise(
    id: 'quadruped_hip_extension',
    name: 'Quadruped Hip Extension',
    met: _metLight,
    cue:
        'Posisi merangkak, angkat satu kaki ke belakang-atas dengan lutut '
        'ditekuk 90°. Punggung tetap rata.',
  );
  static const sideLyingLegRaise = Exercise(
    id: 'side_lying_leg_raise',
    name: 'Angkat Kaki Samping',
    met: _metLight,
    cue:
        'Berbaring miring, angkat kaki atas lurus ke atas lalu turunkan '
        'perlahan. Melatih bokong samping.',
  );

  // ---------- Gerakan 5BX Chart 1 ----------
  static const toeTouchStretch = Exercise(
    id: 'toe_touch_stretch',
    name: 'Peregangan Sentuh Lantai',
    met: _metLight,
    cue:
        'Kaki dibuka, tangan ke atas. Bungkuk sentuh lantai, lalu tegak dan '
        'lengkungkan badan ke belakang. Lutut lurus, jangan dipaksa.',
  );
  static const partialSitUp = Exercise(
    id: 'partial_sit_up',
    name: 'Sit-up Setengah',
    met: _metModerate,
    cue:
        'Berbaring, kaki lurus, tangan di samping. Bangun sampai bisa melihat '
        'tumit.',
  );
  static const backExtension = Exercise(
    id: 'back_extension',
    name: 'Angkat Kepala & Kaki',
    met: _metLight,
    cue:
        'Tengkurap, telapak tangan di bawah paha. Angkat kepala dan satu kaki '
        'lurus, bergantian.',
  );
  static const stationaryRun = Exercise(
    id: 'stationary_run',
    name: 'Lari di Tempat',
    met: _metModerate,
    cue: 'Angkat kaki ±10 cm. Setiap 75 langkah, lakukan 10 lompatan gunting.',
  );
}

// ======================= Rujukan =======================

const _acsm2009 =
    'American College of Sports Medicine. Progression models in '
    'resistance training for healthy adults. Med Sci Sports Exerc. '
    '2009;41(3):687–708.';
const _acsm2026 =
    'American College of Sports Medicine. Position stand '
    'latihan kekuatan (pembaruan pedoman 2009). Med Sci Sports Exerc. '
    '2026;58(4):851–872.';

const _strengthBasis =
    'Pedoman ACSM 2026 dan WHO: latih semua kelompok otot '
    'besar minimal 2 hari per minggu. Latihan di rumah dengan berat badan '
    'juga efektif, dan manfaat terbesar datang dari mulai rutin berlatih. '
    'Takaran repetisi mengikuti model progresi ACSM (pemula 8–12 repetisi), '
    'lalu level naik dengan variasi gerakan yang lebih berat dan volume '
    'lebih banyak.';

String _scheduleFor(Level level) {
  final frequency = switch (level) {
    Level.pemula => '2–3× per minggu',
    Level.menengah => '3–4× per minggu',
    Level.lanjutan => '4–5× per minggu',
  };
  return '$frequency (frekuensi ACSM untuk level ${level.label.toLowerCase()}),'
      ' bergantian bagian tubuh. Beri jeda sekitar 48 jam sebelum melatih '
      'otot yang sama. Naik level jika semua putaran terasa ringan dan masih '
      'sanggup 1–2 repetisi lebih.';
}

WorkoutSource _strengthSource(
  Level level, {
  String origin = 'Pedoman ACSM 2009 & 2026',
  String? finding,
  String? citation,
}) {
  return WorkoutSource(
    origin: origin,
    citation: [
      if (citation != null) citation,
      _acsm2009,
      _acsm2026,
    ].join('\n\n'),
    summary: [if (finding != null) finding, _strengthBasis].join(' '),
    schedule: _scheduleFor(level),
  );
}

const _absFinding =
    'Pilihan gerakan dari studi EMG San Diego State University '
    '(Francis & Davis, untuk ACE): dari 13 gerakan perut, bicycle crunch '
    'paling mengaktifkan otot perut depan, disusul gerakan seperti reverse '
    'crunch, vertical leg crunch, dan long-arm crunch. Studi yang sama '
    'menemukan perut "atas" dan "bawah" bekerja sebagai satu otot.';
const _absCitation =
    'Anders M. New study puts the crunch on ineffective ab '
    'exercises (studi oleh Francis P & Davis J, San Diego State University). '
    'ACE FitnessMatters. Mei/Juni 2001:9–11.';

const _glutesFinding =
    'Pilihan gerakan dari studi EMG ACE di University of '
    'Wisconsin–La Crosse (Porcari & Ristvedt): quadruped hip extension '
    'menghasilkan aktivasi bokong tertinggi, dan step-up, lunge, serta squat '
    'satu kaki terbukti efektif sebagai alternatif squat biasa.';
const _glutesCitation =
    'Studi ACE oleh Porcari JP & Ristvedt B, University '
    'of Wisconsin–La Crosse. American Council on Exercise, 2006.';

// ======================= Program =======================

const _warmUp = [WorkoutStep(Exercises.warmUpMarch, 60, kind: StepKind.warmUp)];
const _coolDown = [
  WorkoutStep(Exercises.coolDownStretch, 60, kind: StepKind.coolDown),
];

/// Istirahat di antara gerakan per level.
int _restFor(Level level) => level == Level.lanjutan ? 20 : 30;

WorkoutProgram _strength({
  required String id,
  required BodyFocus focus,
  required Level level,
  required String description,
  required int rounds,
  required List<WorkoutStep> steps,
  required WorkoutSource source,
}) {
  return WorkoutProgram(
    id: id,
    name: '${focus.label} ${level.label}',
    level: level,
    focus: focus,
    description: description,
    rounds: rounds,
    restSeconds: _restFor(level),
    warmUp: _warmUp,
    steps: steps,
    coolDown: _coolDown,
    source: source,
    progressive: true,
  );
}

const _hictSteps = [
  WorkoutStep(Exercises.jumpingJack, 30),
  WorkoutStep(Exercises.wallSit, 30),
  WorkoutStep(Exercises.pushUp, 30),
  WorkoutStep(Exercises.crunch, 30),
  WorkoutStep(Exercises.stepUp, 30),
  WorkoutStep(Exercises.squat, 30),
  WorkoutStep(Exercises.chairDip, 30),
  WorkoutStep(Exercises.plank, 30),
  WorkoutStep(Exercises.highKnees, 30),
  WorkoutStep(Exercises.lunge, 30),
  WorkoutStep(Exercises.pushUpRotation, 30),
  WorkoutStep(Exercises.sidePlank, 30),
];

const _hictSource = WorkoutSource(
  origin: "ACSM's Health & Fitness Journal, 2013",
  citation:
      'Klika B, Jordan C. High-intensity circuit training using body '
      'weight: maximum results with minimal investment. ACSM\'s Health & '
      'Fitness Journal. 2013;17(3):8–13.',
  summary:
      'Dirancang oleh Human Performance Institute berdasarkan tinjauan '
      'riset high-intensity circuit training. 12 gerakan untuk seluruh tubuh, '
      'masing-masing 30 detik dengan istirahat 10 detik, bergantian antara '
      'otot atas, bawah, dan inti supaya satu otot sempat pulih. Penulis '
      'menyarankan sirkuit diulang 2–3 kali.',
  schedule: 'Lakukan dengan intensitas tinggi (napas berat, sulit bicara).',
);

final workoutPrograms = <WorkoutProgram>[
  // ---------- Seluruh tubuh: protokol riset ----------
  const WorkoutProgram(
    id: 'rcaf_5bx_chart1',
    name: '5BX Level 1',
    level: Level.pemula,
    focus: BodyFocus.fullBody,
    description: 'Kebugaran dasar dari program Angkatan Udara Kanada',
    restSeconds: 0,
    steps: [
      WorkoutStep(Exercises.toeTouchStretch, 120),
      WorkoutStep(Exercises.partialSitUp, 60),
      WorkoutStep(Exercises.backExtension, 60),
      WorkoutStep(Exercises.kneePushUp, 60),
      WorkoutStep(Exercises.stationaryRun, 360),
    ],
    source: WorkoutSource(
      origin: 'Royal Canadian Air Force, 1961',
      citation:
          'Orban WAR. 5BX Plan for Physical Fitness. Royal Canadian Air '
          'Force, 1961.',
      summary:
          'Program 11 menit sehari untuk pilot di pangkalan terpencil, '
          'tanpa alat. Terdiri dari 6 tingkat (chart). Ini Chart 1, versi '
          'paling dasar. Pendekatannya menjadi model studi McMaster 2021.',
      schedule:
          'Setiap hari. Naik ke tingkat berikutnya jika semua gerakan '
          'sudah terasa ringan.',
    ),
  ),
  const WorkoutProgram(
    id: 'mcmaster_11min',
    name: 'Latihan 11 Menit McMaster',
    level: Level.pemula,
    focus: BodyFocus.fullBody,
    description: 'Interval kardio yang diuji pada orang dewasa kurang aktif',
    restSeconds: 0,
    warmUp: [WorkoutStep(Exercises.jumpingJack, 60, kind: StepKind.warmUp)],
    steps: [
      WorkoutStep(Exercises.modifiedBurpee, 60),
      WorkoutStep(Exercises.walkInPlace, 60, kind: StepKind.recovery),
      WorkoutStep(Exercises.highKnees, 60),
      WorkoutStep(Exercises.walkInPlace, 60, kind: StepKind.recovery),
      WorkoutStep(Exercises.splitSquatJump, 60),
      WorkoutStep(Exercises.walkInPlace, 60, kind: StepKind.recovery),
      WorkoutStep(Exercises.highKnees, 60),
      WorkoutStep(Exercises.walkInPlace, 60, kind: StepKind.recovery),
      WorkoutStep(Exercises.jumpSquat, 60),
    ],
    coolDown: [WorkoutStep(Exercises.walkInPlace, 60, kind: StepKind.coolDown)],
    source: WorkoutSource(
      origin: 'McMaster University, 2021',
      citation:
          'Archila LR, Bostad W, Joyner MJ, Gibala MJ. Simple bodyweight '
          'training improves cardiorespiratory fitness with minimal time '
          'commitment: a contemporary application of the 5BX approach. '
          'International Journal of Exercise Science. 2021;14(3):93–100.',
      summary:
          'Uji acak di McMaster University pada 20 orang dewasa yang '
          'kurang aktif. Setelah 6 minggu (3 sesi per minggu), kebugaran '
          'jantung-paru (VO₂peak) kelompok latihan lebih tinggi daripada '
          'kelompok kontrol. Kepatuhan peserta 100%.',
      schedule:
          '3× per minggu. Setiap gerakan 1 menit dengan tempo '
          '"menantang", diselingi 1 menit jalan di tempat.',
    ),
  ),
  const WorkoutProgram(
    id: 'hict_7min',
    name: '7-Minute Workout',
    level: Level.menengah,
    focus: BodyFocus.fullBody,
    description: 'Sirkuit intensitas tinggi seluruh tubuh',
    restSeconds: 10,
    steps: _hictSteps,
    source: _hictSource,
    // Penulis menyarankan 2–3 putaran, jadi boleh naik ke 2 putaran.
    progressive: true,
  ),
  const WorkoutProgram(
    id: 'hict_7min_x3',
    name: '7-Minute Workout × 3',
    level: Level.lanjutan,
    focus: BodyFocus.fullBody,
    description: 'Sirkuit intensitas tinggi, 3 putaran sesuai saran penulis',
    rounds: 3,
    restSeconds: 10,
    steps: _hictSteps,
    source: _hictSource,
  ),

  // ---------- Dada ----------
  _strength(
    id: 'chest_pemula',
    focus: BodyFocus.chest,
    level: Level.pemula,
    description: 'Push-up versi ringan untuk membangun dasar kekuatan dada',
    rounds: 2,
    steps: const [
      WorkoutStep.reps(Exercises.inclinePushUp, 10),
      WorkoutStep.reps(Exercises.kneePushUp, 8),
      WorkoutStep.reps(Exercises.kneeWidePushUp, 8),
      WorkoutStep(Exercises.plank, 20),
    ],
    source: _strengthSource(Level.pemula),
  ),
  _strength(
    id: 'chest_menengah',
    focus: BodyFocus.chest,
    level: Level.menengah,
    description: 'Push-up penuh dengan variasi lebar dan diamond',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.pushUp, 10),
      WorkoutStep.reps(Exercises.widePushUp, 10),
      WorkoutStep.reps(Exercises.diamondPushUp, 8),
      WorkoutStep(Exercises.plank, 30),
    ],
    source: _strengthSource(Level.menengah),
  ),
  _strength(
    id: 'chest_lanjutan',
    focus: BodyFocus.chest,
    level: Level.lanjutan,
    description: 'Decline, diamond, dan push-up eksplosif',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.declinePushUp, 12),
      WorkoutStep.reps(Exercises.pushUp, 15),
      WorkoutStep.reps(Exercises.diamondPushUp, 12),
      WorkoutStep.reps(Exercises.plyoPushUp, 8),
      WorkoutStep(Exercises.plank, 45),
    ],
    source: _strengthSource(Level.lanjutan),
  ),

  // ---------- Perut ----------
  _strength(
    id: 'abs_pemula',
    focus: BodyFocus.abs,
    level: Level.pemula,
    description: 'Gerakan perut dasar yang aman untuk punggung',
    rounds: 2,
    steps: const [
      WorkoutStep.reps(Exercises.crunch, 12),
      WorkoutStep.reps(Exercises.deadBug, 8, perSide: true),
      WorkoutStep.reps(Exercises.reverseCrunch, 10),
      WorkoutStep(Exercises.plank, 20),
    ],
    source: _strengthSource(
      Level.pemula,
      origin: 'ACE dan San Diego State University, 2001',
      finding: _absFinding,
      citation: _absCitation,
    ),
  ),
  _strength(
    id: 'abs_menengah',
    focus: BodyFocus.abs,
    level: Level.menengah,
    description: 'Bicycle crunch dan gerakan peringkat atas studi ACE',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.bicycleCrunch, 12, perSide: true),
      WorkoutStep.reps(Exercises.reverseCrunch, 12),
      WorkoutStep.reps(Exercises.longArmCrunch, 12),
      WorkoutStep(Exercises.sidePlank, 40),
      WorkoutStep(Exercises.plank, 30),
    ],
    source: _strengthSource(
      Level.menengah,
      origin: 'ACE dan San Diego State University, 2001',
      finding: _absFinding,
      citation: _absCitation,
    ),
  ),
  _strength(
    id: 'abs_lanjutan',
    focus: BodyFocus.abs,
    level: Level.lanjutan,
    description: 'Volume tinggi dengan gerakan perut paling menantang',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.bicycleCrunch, 20, perSide: true),
      WorkoutStep.reps(Exercises.verticalLegCrunch, 15),
      WorkoutStep.reps(Exercises.reverseCrunch, 15),
      WorkoutStep(Exercises.mountainClimber, 30),
      WorkoutStep(Exercises.plank, 60),
    ],
    source: _strengthSource(
      Level.lanjutan,
      origin: 'ACE dan San Diego State University, 2001',
      finding: _absFinding,
      citation: _absCitation,
    ),
  ),

  // ---------- Kaki ----------
  _strength(
    id: 'legs_pemula',
    focus: BodyFocus.legs,
    level: Level.pemula,
    description: 'Paha dan betis dengan bantuan kursi',
    rounds: 2,
    steps: const [
      WorkoutStep.reps(Exercises.boxSquat, 10),
      WorkoutStep.reps(Exercises.reverseLunge, 8, perSide: true),
      WorkoutStep(Exercises.wallSit, 20),
      WorkoutStep.reps(Exercises.calfRaise, 15),
    ],
    source: _strengthSource(Level.pemula),
  ),
  _strength(
    id: 'legs_menengah',
    focus: BodyFocus.legs,
    level: Level.menengah,
    description: 'Squat, lunge tiga arah, dan wall sit lebih lama',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.squat, 15),
      WorkoutStep.reps(Exercises.lunge, 10, perSide: true),
      WorkoutStep.reps(Exercises.sideLunge, 8, perSide: true),
      WorkoutStep(Exercises.wallSit, 40),
      WorkoutStep.reps(Exercises.calfRaise, 20),
    ],
    source: _strengthSource(Level.menengah),
  ),
  _strength(
    id: 'legs_lanjutan',
    focus: BodyFocus.legs,
    level: Level.lanjutan,
    description: 'Gerakan satu kaki dan plyometric',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.jumpSquat, 12),
      WorkoutStep.reps(Exercises.bulgarianSplitSquat, 10, perSide: true),
      WorkoutStep.reps(Exercises.splitSquatJump, 10),
      WorkoutStep.reps(Exercises.singleLegCalfRaise, 15, perSide: true),
      WorkoutStep(Exercises.wallSit, 60),
    ],
    source: _strengthSource(Level.lanjutan),
  ),

  // ---------- Tubuh atas ----------
  _strength(
    id: 'upper_pemula',
    focus: BodyFocus.upper,
    level: Level.pemula,
    description: 'Dada, lengan, bahu, dan punggung tanpa alat',
    rounds: 2,
    steps: const [
      WorkoutStep.reps(Exercises.inclinePushUp, 10),
      WorkoutStep.reps(Exercises.chairDip, 8),
      WorkoutStep.reps(Exercises.superman, 10),
      WorkoutStep(Exercises.plank, 20),
    ],
    source: _strengthSource(Level.pemula),
  ),
  _strength(
    id: 'upper_menengah',
    focus: BodyFocus.upper,
    level: Level.menengah,
    description: 'Push-up, pike push-up untuk bahu, dan punggung atas',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.pushUp, 10),
      WorkoutStep.reps(Exercises.pikePushUp, 8),
      WorkoutStep.reps(Exercises.chairDip, 12),
      WorkoutStep.reps(Exercises.proneYTRaise, 10),
      WorkoutStep.reps(Exercises.plankShoulderTap, 10, perSide: true),
    ],
    source: _strengthSource(Level.menengah),
  ),
  _strength(
    id: 'upper_lanjutan',
    focus: BodyFocus.upper,
    level: Level.lanjutan,
    description: 'Variasi berat untuk dada, bahu, dan trisep',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.declinePushUp, 12),
      WorkoutStep.reps(Exercises.elevatedPikePushUp, 10),
      WorkoutStep.reps(Exercises.diamondPushUp, 12),
      WorkoutStep.reps(Exercises.superman, 15),
      WorkoutStep.reps(Exercises.plankShoulderTap, 15, perSide: true),
    ],
    source: _strengthSource(Level.lanjutan),
  ),

  // ---------- Tubuh bawah ----------
  _strength(
    id: 'lower_pemula',
    focus: BodyFocus.lower,
    level: Level.pemula,
    description: 'Bokong dan kaki, gerakan pilihan studi ACE',
    rounds: 2,
    steps: const [
      WorkoutStep.reps(Exercises.gluteBridge, 12),
      WorkoutStep.reps(Exercises.quadrupedHipExtension, 10, perSide: true),
      WorkoutStep.reps(Exercises.boxSquat, 10),
      WorkoutStep.reps(Exercises.sideLyingLegRaise, 10, perSide: true),
    ],
    source: _strengthSource(
      Level.pemula,
      origin: 'ACE dan University of Wisconsin–La Crosse',
      finding: _glutesFinding,
      citation: _glutesCitation,
    ),
  ),
  _strength(
    id: 'lower_menengah',
    focus: BodyFocus.lower,
    level: Level.menengah,
    description: 'Step-up, lunge, dan glute bridge satu kaki',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.stepUp, 10, perSide: true),
      WorkoutStep.reps(Exercises.lunge, 10, perSide: true),
      WorkoutStep.reps(Exercises.singleLegGluteBridge, 10, perSide: true),
      WorkoutStep.reps(Exercises.quadrupedHipExtension, 15, perSide: true),
      WorkoutStep.reps(Exercises.squat, 15),
    ],
    source: _strengthSource(
      Level.menengah,
      origin: 'ACE dan University of Wisconsin–La Crosse',
      finding: _glutesFinding,
      citation: _glutesCitation,
    ),
  ),
  _strength(
    id: 'lower_lanjutan',
    focus: BodyFocus.lower,
    level: Level.lanjutan,
    description: 'Squat satu kaki, Bulgarian split squat, dan plyometric',
    rounds: 3,
    steps: const [
      WorkoutStep.reps(Exercises.singleLegSquatToChair, 8, perSide: true),
      WorkoutStep.reps(Exercises.bulgarianSplitSquat, 12, perSide: true),
      WorkoutStep.reps(Exercises.singleLegGluteBridge, 15, perSide: true),
      WorkoutStep.reps(Exercises.jumpSquat, 15),
      WorkoutStep.reps(Exercises.stepUp, 12, perSide: true),
    ],
    source: _strengthSource(
      Level.lanjutan,
      origin: 'ACE dan University of Wisconsin–La Crosse',
      finding: _glutesFinding,
      citation: _glutesCitation,
    ),
  ),
];

/// Program pustaka dari id. Varian program 4 minggu (`<id>@m2`) dikembalikan
/// ke program dasarnya.
WorkoutProgram? programById(String id) {
  final baseId = id.split('@').first;
  for (final p in workoutPrograms) {
    if (p.id == baseId) return p;
  }
  return null;
}

// ======================= Katalog gerakan =======================

/// Semua gerakan inti per kategori, untuk menyusun latihan sendiri.
/// Pemanasan & pendinginan tidak termasuk (ditambahkan lewat opsi terpisah).
const exerciseCategories = <(String, List<Exercise>)>[
  (
    'Kardio & seluruh tubuh',
    [
      Exercises.jumpingJack,
      Exercises.highKnees,
      Exercises.modifiedBurpee,
      Exercises.mountainClimber,
      Exercises.stationaryRun,
      Exercises.walkInPlace,
      Exercises.toeTouchStretch,
    ],
  ),
  (
    'Dada, bahu, lengan',
    [
      Exercises.inclinePushUp,
      Exercises.kneePushUp,
      Exercises.kneeWidePushUp,
      Exercises.pushUp,
      Exercises.widePushUp,
      Exercises.diamondPushUp,
      Exercises.declinePushUp,
      Exercises.plyoPushUp,
      Exercises.pushUpRotation,
      Exercises.pikePushUp,
      Exercises.elevatedPikePushUp,
      Exercises.chairDip,
      Exercises.plankShoulderTap,
    ],
  ),
  (
    'Punggung',
    [Exercises.superman, Exercises.proneYTRaise, Exercises.backExtension],
  ),
  (
    'Perut & inti',
    [
      Exercises.crunch,
      Exercises.longArmCrunch,
      Exercises.bicycleCrunch,
      Exercises.reverseCrunch,
      Exercises.verticalLegCrunch,
      Exercises.partialSitUp,
      Exercises.deadBug,
      Exercises.plank,
      Exercises.sidePlank,
    ],
  ),
  (
    'Kaki & bokong',
    [
      Exercises.squat,
      Exercises.boxSquat,
      Exercises.jumpSquat,
      Exercises.lunge,
      Exercises.reverseLunge,
      Exercises.sideLunge,
      Exercises.bulgarianSplitSquat,
      Exercises.splitSquatJump,
      Exercises.singleLegSquatToChair,
      Exercises.wallSit,
      Exercises.stepUp,
      Exercises.calfRaise,
      Exercises.singleLegCalfRaise,
      Exercises.gluteBridge,
      Exercises.singleLegGluteBridge,
      Exercises.quadrupedHipExtension,
      Exercises.sideLyingLegRaise,
    ],
  ),
];

Exercise? exerciseById(String id) {
  for (final (_, list) in exerciseCategories) {
    for (final e in list) {
      if (e.id == id) return e;
    }
  }
  return null;
}

/// Takaran awal saat gerakan ditambahkan ke latihan buatan: ikuti cara
/// gerakan itu dipakai di pustaka (repetisi atau waktu).
WorkoutStep defaultStepFor(Exercise exercise) {
  for (final program in workoutPrograms) {
    for (final step in program.steps) {
      if (step.exercise.id == exercise.id && step.isReps) {
        return WorkoutStep.reps(exercise, 10, perSide: step.perSide);
      }
    }
  }
  return WorkoutStep(exercise, 30);
}

// ======================= Latihan buatan =======================

const _customSource = WorkoutSource(
  origin: 'Latihan buatanmu',
  citation: '$_acsm2009\n\n$_acsm2026',
  summary:
      'Panduan ACSM untuk menyusun latihan kekuatan: latih semua kelompok '
      'otot besar (dada, punggung, bahu, perut, kaki) minimal 2 hari per '
      'minggu. Pemula cukup 8–12 repetisi per gerakan dengan 2–4 putaran. '
      'Selang-seling gerakan tubuh atas, bawah, dan inti supaya otot sempat '
      'pulih, dan beri jeda sekitar 48 jam sebelum melatih otot yang sama.',
  schedule:
      'Tambah repetisi atau putaran jika semua putaran terasa ringan dan '
      'masih sanggup 1–2 repetisi lebih.',
);

/// Ubah latihan buatan jadi program yang bisa diputar. Gerakan yang tidak
/// dikenal (mis. data lama) dilewati.
WorkoutProgram programFromCustom(CustomWorkout workout) {
  final steps = <WorkoutStep>[
    for (final item in workout.items)
      if (exerciseById(item.exerciseId) case final exercise?)
        item.isReps
            ? WorkoutStep.reps(exercise, item.amount, perSide: item.perSide)
            : WorkoutStep(exercise, item.amount),
  ];
  final count = steps.length;
  return WorkoutProgram(
    id: workout.programId,
    name: workout.name,
    level: Level.pemula,
    focus: BodyFocus.fullBody,
    description: '$count gerakan, ${workout.rounds} putaran, buatan sendiri',
    rounds: workout.rounds,
    restSeconds: workout.restSeconds,
    warmUp: workout.withWarmUp ? _warmUp : const [],
    steps: steps,
    coolDown: workout.withWarmUp ? _coolDown : const [],
    source: _customSource,
    isCustom: true,
  );
}

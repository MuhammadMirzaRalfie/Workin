/// Satu gerakan di latihan buatan pengguna.
class CustomItem {
  const CustomItem({
    required this.exerciseId,
    required this.amount,
    required this.isReps,
    this.perSide = false,
  });

  final String exerciseId;

  /// Jumlah repetisi jika [isReps], selain itu detik.
  final int amount;
  final bool isReps;
  final bool perSide;

  CustomItem copyWith({int? amount, bool? isReps}) => CustomItem(
    exerciseId: exerciseId,
    amount: amount ?? this.amount,
    isReps: isReps ?? this.isReps,
    perSide: perSide,
  );

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'amount': amount,
    'isReps': isReps,
    'perSide': perSide,
  };

  factory CustomItem.fromJson(Map<String, dynamic> json) => CustomItem(
    exerciseId: json['exerciseId'] as String,
    amount: json['amount'] as int,
    isReps: json['isReps'] as bool,
    perSide: json['perSide'] as bool? ?? false,
  );
}

/// Latihan yang disusun sendiri. Diubah jadi program lewat
/// `programFromCustom` supaya bisa diputar seperti program pustaka.
class CustomWorkout {
  const CustomWorkout({
    required this.id,
    required this.name,
    required this.items,
    this.rounds = 2,
    this.restSeconds = 30,
    this.withWarmUp = true,
  });

  /// Awalan id program, supaya sesi latihan buatan mudah dikenali.
  static const programPrefix = 'custom:';

  final String id;
  final String name;
  final List<CustomItem> items;
  final int rounds;
  final int restSeconds;

  /// Tambahkan pemanasan & pendinginan 1 menit.
  final bool withWarmUp;

  String get programId => '$programPrefix$id';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((i) => i.toJson()).toList(),
    'rounds': rounds,
    'restSeconds': restSeconds,
    'withWarmUp': withWarmUp,
  };

  factory CustomWorkout.fromJson(Map<String, dynamic> json) => CustomWorkout(
    id: json['id'] as String,
    name: json['name'] as String,
    items: [
      for (final i in json['items'] as List<dynamic>)
        CustomItem.fromJson(i as Map<String, dynamic>),
    ],
    rounds: json['rounds'] as int? ?? 2,
    restSeconds: json['restSeconds'] as int? ?? 30,
    withWarmUp: json['withWarmUp'] as bool? ?? true,
  );
}

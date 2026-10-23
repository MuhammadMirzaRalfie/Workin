import 'package:flutter/material.dart';

import '../data/workout_library.dart';
import '../models/custom_workout.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/exercise_figure.dart';

void openCustomWorkoutEditor(BuildContext context, [CustomWorkout? existing]) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => CustomWorkoutScreen(existing: existing)),
  );
}

/// Menyusun latihan sendiri dari katalog gerakan.
class CustomWorkoutScreen extends StatefulWidget {
  const CustomWorkoutScreen({super.key, this.existing});

  final CustomWorkout? existing;

  @override
  State<CustomWorkoutScreen> createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  static const _restOptions = [0, 10, 15, 20, 30, 45, 60];
  static const _maxRounds = 5;

  late final TextEditingController _name;
  late List<CustomItem> _items;

  /// Kunci stabil per baris untuk daftar yang bisa digeser urutannya
  /// (gerakan yang sama boleh muncul dua kali).
  late List<int> _keys;
  int _nextKey = 0;
  late int _rounds;
  late int _rest;
  late bool _withWarmUp;

  @override
  void initState() {
    super.initState();
    final w = widget.existing;
    _name = TextEditingController(text: w?.name ?? '');
    _items = [...?w?.items];
    _keys = [for (final _ in _items) _nextKey++];
    _rounds = w?.rounds ?? 2;
    _rest = w?.restSeconds ?? 30;
    _withWarmUp = w?.withWarmUp ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  CustomWorkout _draft() => CustomWorkout(
    id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
    name: _name.text.trim().isEmpty ? 'Latihanku' : _name.text.trim(),
    items: _items,
    rounds: _rounds,
    restSeconds: _rest,
    withWarmUp: _withWarmUp,
  );

  Future<void> _addExercise() async {
    final exercise = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ExercisePicker(),
    );
    if (exercise == null) return;
    final step = defaultStepFor(exercise);
    setState(() {
      _items = [
        ..._items,
        CustomItem(
          exerciseId: exercise.id,
          amount: step.isReps ? step.reps! : step.seconds,
          isReps: step.isReps,
          perSide: step.perSide,
        ),
      ];
      _keys = [..._keys, _nextKey++];
    });
  }

  void _update(int index, CustomItem item) {
    setState(() => _items = [..._items]..[index] = item);
  }

  void _remove(int index) {
    setState(() {
      _items = [..._items]..removeAt(index);
      _keys = [..._keys]..removeAt(index);
    });
  }

  void _reorder(int from, int to) {
    if (to > from) to--;
    setState(() {
      _items = [..._items];
      _keys = [..._keys];
      _items.insert(to, _items.removeAt(from));
      _keys.insert(to, _keys.removeAt(from));
    });
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu gerakan')),
      );
      return;
    }
    await AppScope.read(context).saveCustomWorkout(_draft());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final weight = AppScope.of(context).weightKg ?? 60;
    final program = programFromCustom(_draft());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Buat latihan' : 'Ubah latihan'),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        onReorder: _reorder,
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama latihan',
                hintText: 'contoh: Pagi singkat',
              ),
            ),
            const SizedBox(height: 24),
            Text('Gerakan', style: textTheme.titleLarge),
            Text(
              _items.isEmpty
                  ? 'Belum ada gerakan. Tambahkan dari katalog di bawah.'
                  : 'Tahan lalu geser untuk mengubah urutan.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
          ],
        ),
        itemCount: _items.length,
        itemBuilder:
            (context, i) => _ItemRow(
              key: ValueKey(_keys[i]),
              item: _items[i],
              onChanged: (item) => _update(i, item),
              onRemove: () => _remove(i),
            ),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Tambah gerakan'),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(child: Text('Putaran', style: textTheme.titleMedium)),
                _Stepper(
                  value: '$_rounds×',
                  onMinus: _rounds > 1 ? () => setState(() => _rounds--) : null,
                  onPlus:
                      _rounds < _maxRounds
                          ? () => setState(() => _rounds++)
                          : null,
                  label: 'putaran',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Istirahat antar gerakan', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in _restOptions)
                  ChoiceChip(
                    label: Text(r == 0 ? 'Tanpa' : '$r dtk'),
                    selected: _rest == r,
                    onSelected: (_) => setState(() => _rest = r),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pemanasan & pendinginan'),
              subtitle: const Text('1 menit di awal dan di akhir'),
              value: _withWarmUp,
              onChanged: (v) => setState(() => _withWarmUp = v),
            ),
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Perkiraan ${program.totalMinutes} menit, '
                '±${formatNumber(program.estimateCalories(weight))} kkal',
                style: textTheme.bodyMedium?.copyWith(
                  color: context.palette.tintaPudar,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(onPressed: _save, child: const Text('Simpan')),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final CustomItem item;
  final ValueChanged<CustomItem> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final exercise = exerciseById(item.exerciseId);
    final step = item.isReps ? 1 : 5;
    final min = item.isReps ? 1 : 5;
    final max = item.isReps ? 100 : 600;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 6),
      decoration: BoxDecoration(
        color: context.palette.permukaan,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.garis),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (exercise != null && ExerciseFigure.hasPose(exercise.id))
                SizedBox(
                  width: 52,
                  height: 40,
                  child: ExerciseFigure(
                    exerciseId: exercise.id,
                    animate: false,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  exercise?.name ?? item.exerciseId,
                  style: textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Hapus gerakan',
                icon: const Icon(Icons.close, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
          Row(
            children: [
              _Stepper(
                value: '${item.amount}',
                label:
                    item.isReps
                        ? (item.perSide ? 'kali/sisi' : 'kali')
                        : 'detik',
                onMinus:
                    item.amount - step >= min
                        ? () =>
                            onChanged(item.copyWith(amount: item.amount - step))
                        : null,
                onPlus:
                    item.amount + step <= max
                        ? () =>
                            onChanged(item.copyWith(amount: item.amount + step))
                        : null,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        () => onChanged(
                          item.copyWith(
                            isReps: !item.isReps,
                            amount: item.isReps ? 30 : 10,
                          ),
                        ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(item.isReps ? 'Pakai detik' : 'Pakai kali'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tombol − angka + yang ringkas.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.label,
    required this.onMinus,
    required this.onPlus,
  });

  final String value;
  final String label;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Kurangi',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onMinus,
        ),
        Semantics(
          label: '$value $label',
          child: ExcludeSemantics(
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Text(value, style: numeralStyle(24)),
                  Text(label, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Tambah',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onPlus,
        ),
      ],
    );
  }
}

class _ExercisePicker extends StatelessWidget {
  const _ExercisePicker();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder:
          (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Text('Pilih gerakan', style: textTheme.titleLarge),
              for (final (category, exercises) in exerciseCategories) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 4),
                  child: Text(
                    category,
                    style: textTheme.titleSmall?.copyWith(
                      color: context.palette.matrasTeks,
                    ),
                  ),
                ),
                for (final e in exercises)
                  InkWell(
                    onTap: () => Navigator.of(context).pop(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 44,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: context.palette.permukaan,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ExerciseFigure(
                              exerciseId: e.id,
                              animate: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name, style: textTheme.titleMedium),
                                Text(
                                  e.cue,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';

class RubricState {
  final Rubric activeRubric;
  final List<Rubric> allRubrics;

  const RubricState({
    required this.activeRubric,
    required this.allRubrics,
  });

  RubricState copyWith({
    Rubric? activeRubric,
    List<Rubric>? allRubrics,
  }) {
    return RubricState(
      activeRubric: activeRubric ?? this.activeRubric,
      allRubrics: allRubrics ?? this.allRubrics,
    );
  }
}

class RubricNotifier extends Notifier<RubricState> {
  @override
  RubricState build() {
    return const RubricState(
      activeRubric: Rubric.fptCapstone,
      allRubrics: Rubric.defaultRubrics,
    );
  }

  void selectRubric(Rubric rubric) {
    state = state.copyWith(activeRubric: rubric);
  }

  void updateRubric(Rubric updatedRubric) {
    final updatedList = state.allRubrics.map((r) {
      if (r.id == updatedRubric.id) {
        return updatedRubric;
      }
      return r;
    }).toList();

    // If it's a new custom rubric not currently in list, append it
    if (!updatedList.any((r) => r.id == updatedRubric.id)) {
      updatedList.add(updatedRubric);
    }

    final isCurrentlyActive = state.activeRubric.id == updatedRubric.id;

    state = state.copyWith(
      allRubrics: updatedList,
      activeRubric: isCurrentlyActive ? updatedRubric : state.activeRubric,
    );
  }

  void addCustomRubric(Rubric customRubric) {
    final updatedList = List<Rubric>.from(state.allRubrics)..add(customRubric);
    state = state.copyWith(
      allRubrics: updatedList,
      activeRubric: customRubric,
    );
  }

  void resetToDefaults() {
    state = const RubricState(
      activeRubric: Rubric.fptCapstone,
      allRubrics: Rubric.defaultRubrics,
    );
  }
}

final rubricProvider = NotifierProvider<RubricNotifier, RubricState>(RubricNotifier.new);

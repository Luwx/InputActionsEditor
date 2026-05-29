enum DirtyMarkState { clean, newUnsaved, changedFromSaved }

extension DirtyMarkStateX on DirtyMarkState {
  bool get isDirty => this != DirtyMarkState.clean;

  bool get canRevert => this == DirtyMarkState.changedFromSaved;
}

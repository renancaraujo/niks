import 'package:rebloc/rebloc.dart';

import 'core.dart';

mixin NiksHistoryAction implements Action {
  NiksHistoryState execute(NiksHistoryState state);
}

class AddHistoryAction with NiksHistoryAction implements Action {
  const AddHistoryAction(this.historyItem);

  final NiksHistoryItem historyItem;

  @override
  NiksHistoryState execute(NiksHistoryState state) {
    final historyBuffer = [
      ...state.historyBuffer.sublist(0, state.activeIndex + 1),
      historyItem
    ];

    final int newActiveIndex = historyBuffer.length - 1;

    return NiksHistoryState(historyBuffer, newActiveIndex, true);
  }
}

class UndoAction with NiksHistoryAction implements Action {
  const UndoAction(this.backwards);

  final int backwards;

  @override
  NiksHistoryState execute(NiksHistoryState state) {
    final int newActiveIndex = state.activeIndex - backwards;
    return NiksHistoryState(state.historyBuffer,
        newActiveIndex.clamp(0, state.historyBuffer.length - 1), false);
  }
}

class RedoAction with NiksHistoryAction implements Action {
  const RedoAction(this.forwards);

  final int forwards;

  @override
  NiksHistoryState execute(NiksHistoryState state) {
    final int newActiveIndex = state.activeIndex + forwards;
    return NiksHistoryState(state.historyBuffer,
        newActiveIndex.clamp(0, state.historyBuffer.length - 1), false);
  }
}

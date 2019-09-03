import 'package:niks/state/state.dart';
import 'package:rebloc/rebloc.dart';

import 'actions.dart';

class NiksHistoryItem {
  const NiksHistoryItem(this.name, this.snapshot, this.timestamp);

  final String name;
  final DateTime timestamp;
  final NiksStateSnapshot snapshot;
}

class NiksHistoryState {
  const NiksHistoryState(this.historyBuffer, this.activeIndex, this.updated);

  final int activeIndex;
  final List<NiksHistoryItem> historyBuffer;
  final bool updated;

  NiksHistoryItem get activeSnapshot {
    return historyBuffer[activeIndex];
  }
}

class NiksHistoryBloc extends SimpleBloc<NiksHistoryState> {
  NiksHistoryBloc(this.bufferSize);

  final int bufferSize;

  @override
  NiksHistoryState reducer(NiksHistoryState state, final Action action) {
    final actionState = (action as NiksHistoryAction).execute(state);
    final currentBufferSize = actionState.historyBuffer.length;
    final start = currentBufferSize - bufferSize;
    if (start <= 0) {
      return actionState;
    }

    final newHistoryBuffer = actionState.historyBuffer.sublist(start);

    final newActiveIndex = actionState.activeIndex.clamp(
      0,
      newHistoryBuffer.length - 1,
    );

    final newState = NiksHistoryState(
      newHistoryBuffer,
      newActiveIndex,
      actionState.updated,
    );

    return newState;
  }
}

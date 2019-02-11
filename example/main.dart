import 'package:redurx/redurx.dart';

class State {
  State(this.count);
  final int count;

  @override
  String toString() => count.toString();
}

class Increment extends Action<State> {
  Increment([this.by = 1]);
  final int by;
  State reduce(state) {
    print('REDUCE');
    return State(state.count + by);
  }

  @override
  void afterReduce(Store<State> store, State state) {
    print('AFTERREDUCE');
    if (state.count < 10) {
      store.dispatch(Increment(by + 1));
    }
    super.afterReduce(store, state);
  }
}

void main() {
  final store = Store<State>(State(0));

  store.add(LogMiddleware<State>());
  print(store.state.count); // 0

  store.dispatch(Increment());
  // Before action: Increment: 0 (from LogMiddleware)
  // After action: Increment: 1 (from LogMiddleware)
  print(store.state.count); // 1

//  store.dispatch(Increment(2));
//  // Before action: Increment: 1 (from LogMiddleware)
//  // After action: Increment: 3 (from LogMiddleware)
//  print(store.state.count); // 3
}

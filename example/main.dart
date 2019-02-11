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
  State reduce(state) => State(state.count + by);

  @override
  void afterReduce(Store<State> store, State state) {
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
  print(store.state.count); // 1
}

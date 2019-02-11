# ReduRx (https://github.com/feilfeilundfeil/ReduRx)

A thin layer of a Redux-based state manager on top of RxDart.

## Usage

```dart
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
    if (state.count < 3) {
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

//0
//MIDDLEWARE before: Increment: 0
//MIDDLEWARE after: Increment: 1
//MIDDLEWARE before: Increment: 1
//MIDDLEWARE after: Increment: 3
//3
```

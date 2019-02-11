import 'dart:async';

import 'package:redurx/redurx.dart';

class State {
  State(this.count);
  final int count;

  @override
  bool operator ==(other) => count == other.count;

  @override
  String toString() => count.toString();
}

class Increment extends Action<State> {
  @override
  State reduce(State state) => State(state.count + 1);
}

class AsyncIncrement extends AsyncAction<State> {
  @override
  Future<Computation<State>> reduce(State state) async {
    await Future.delayed(const Duration(seconds: 2));
    return (State state) => State(state.count + 1);
  }
}

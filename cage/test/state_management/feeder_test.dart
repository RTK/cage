// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyFeeder myFeeder;
  MyStore myStore;

  setUp(() {
    myFeeder = MyFeeder();
    myStore = MyStore();
  });

  group('setFeederState', () {
    test('It should set the state of given feeder to given state', () {
      final MyState myState = MyState('test');

      setFeederState(myFeeder, myState);

      expect(myFeeder.state, myState);
    });

    test('It should add a new value to the feeders update stream', () async {
      myFeeder.streamController.stream.listen((String output) {
        expect(output, 'test');
      });

      final MyState myState = MyState('test');

      setFeederState(myFeeder, myState);
    });

    test(
        'It should not add a new value to the feeders update stream, if the feed output is identical to last value',
        () async {
      final MyState myState = MyState('test');

      setFeederState(myFeeder, myState);

      myFeeder.streamController.stream.listen((String output) {
        expect(output, 'abc');
      });

      setFeederState(myFeeder, myState);
      setFeederState(myFeeder, MyState('abc'));
    });
  });

  group('setFeederStore', () {
    test('It should set the store of given feeder to given state', () {
      expect(myFeeder.store, null);

      setFeederStore(myFeeder, myStore);

      expect(myFeeder.store, myStore);
    });

    test(
        'It should throw an AssertionError when setting the store more than once',
        () {
      expect(myFeeder.store, null);

      setFeederStore(myFeeder, myStore);
      expect(() => setFeederStore(myFeeder, myStore), throwsAssertionError);
    });

    test(
        'It should not throw, when the store is set more than once but with null',
        () {
      setFeederStore(myFeeder, myStore);
      setFeederStore(myFeeder, null);

      expect(myFeeder.store, null);
    });
  });

  group('class Feeder', () {
    test('It should create', () {
      expect(myFeeder, isNotNull);
    });

    group('get updates', () {
      test('It should return the stream from the update stream controller', () {
        expect(myFeeder.updates, myFeeder.streamController.stream);
      });
    });

    group('dispose()', () {
      test('It should remove itself from its store and close its update stream',
          () {
        myStore.addFeeder(myFeeder);

        expect(myFeeder.streamController.isClosed, false);
        expect(myStore.feeders.contains(myFeeder), true);

        myFeeder.dispose();

        expect(myFeeder.streamController.isClosed, true);
        expect(myStore.feeders.contains(myFeeder), false);
      });
    });

    group('getFeed()', () {
      test('It should return the correct value from the state', () {
        setFeederState(myFeeder, MyState('123'));

        expect(myFeeder.getFeed(), '123');
      });
    });
  });
}

class MyState extends State {
  final value;

  const MyState(this.value);
}

class MyStore extends Store<MyState> {
  MyStore() : super(MyState('initial'));
}

class MyFeeder extends Feeder<MyState, String> {
  @override
  String getFeed() => state.value;
}

// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('createStoreModuleAccessor()', () {
    test('It should create a Store', () {
      final Public.Store store = createPublicStore(MyStore());

      expect(store, isNotNull);
      expect(store, isInstanceOf<Public.Store>());
    });
  });

  group('Store', () {
    group('dispatch()', () {
      test('It should call the internal stores dispatch method', () {
        final MyStore myStore = MyStore();
        final Public.Store store = createPublicStore(myStore);

        store.dispatch(const ActionToken('abc'), 'test');

        expect(myStore.dispatchedToken, const ActionToken('abc'));
        expect(myStore.dispatchedPayload, 'test');
      });
    });

    group('getFeeder()', () {
      test('It should return the registered feeder', () {
        final MyStore myStore = MyStore();
        final MyFeeder myFeeder = MyFeeder();

        myStore.addFeeder(myFeeder);

        final Public.Store store = createPublicStore(myStore);

        expect(store.getFeeder<MyFeeder>().contains(myFeeder), true);
      });
    });
  });
}

class MyState extends State {}

class MyStore extends Store<MyState> {
  ActionToken dispatchedToken;

  dynamic dispatchedPayload;

  MyStore() : super(MyState());

  @override
  void dispatch<String>(final Public.ActionToken actionToken,
      [final String payload]) {
    dispatchedToken = actionToken;
    dispatchedPayload = payload;

    super.dispatch(actionToken, payload);
  }
}

class MyFeeder extends Feeder<MyState, void> {
  @override
  void getFeed() {}
}

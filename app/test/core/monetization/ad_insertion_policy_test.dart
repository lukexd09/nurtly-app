import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/monetization/ad_insertion_policy.dart';

void main() {
  const policy = AdInsertionPolicy();

  test('no ad for zero items', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 0,
        totalVisibleItems: 0,
        isFiltered: false,
      ),
      isFalse,
    );
  });

  test('unfiltered 1 item inserts ad after item 1', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 1,
        totalVisibleItems: 1,
        isFiltered: false,
      ),
      isTrue,
    );
  });

  test('unfiltered 2 items inserts ad after item 2', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 1,
        totalVisibleItems: 2,
        isFiltered: false,
      ),
      isFalse,
    );
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 2,
        totalVisibleItems: 2,
        isFiltered: false,
      ),
      isTrue,
    );
  });

  test('filtered 1 item inserts no ad', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 1,
        totalVisibleItems: 1,
        isFiltered: true,
      ),
      isFalse,
    );
  });

  test('filtered 2 items inserts no ad', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 2,
        totalVisibleItems: 2,
        isFiltered: true,
      ),
      isFalse,
    );
  });

  test('3 items inserts after item 3', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 3,
        totalVisibleItems: 3,
        isFiltered: false,
      ),
      isTrue,
    );
  });

  test('4 items inserts only after item 3', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 3,
        totalVisibleItems: 4,
        isFiltered: false,
      ),
      isTrue,
    );
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 4,
        totalVisibleItems: 4,
        isFiltered: false,
      ),
      isFalse,
    );
  });

  test('22 items inserts only after item 3', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 3,
        totalVisibleItems: 22,
        isFiltered: false,
      ),
      isTrue,
    );
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 22,
        totalVisibleItems: 22,
        isFiltered: false,
      ),
      isFalse,
    );
  });

  test('23 items inserts after 3 and 23', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 3,
        totalVisibleItems: 23,
        isFiltered: false,
      ),
      isTrue,
    );
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 23,
        totalVisibleItems: 23,
        isFiltered: false,
      ),
      isTrue,
    );
  });

  test('43 items inserts after 3, 23, 43', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 3,
        totalVisibleItems: 43,
        isFiltered: false,
      ),
      isTrue,
    );
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 23,
        totalVisibleItems: 43,
        isFiltered: false,
      ),
      isTrue,
    );
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 43,
        totalVisibleItems: 43,
        isFiltered: false,
      ),
      isTrue,
    );
  });

  test('ad positions depend on content index, not list index', () {
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 3,
        totalVisibleItems: 4,
        isFiltered: false,
      ),
      isTrue,
    );
    expect(
      policy.shouldInsertAdAfterContentIndex(
        contentIndexOneBased: 4,
        totalVisibleItems: 23,
        isFiltered: false,
      ),
      isFalse,
    );
  });
}

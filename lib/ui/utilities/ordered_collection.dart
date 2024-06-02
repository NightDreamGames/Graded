// Dart imports:
import "dart:math";

// Package imports:
import "package:quiver/collection.dart";

class OrderedCollection<T> implements List<T>, Iterable<T> {
  late final List<T>? list;
  late final TreeSet<T>? treeSet;

  late final bool isList;

  OrderedCollection(dynamic data) : assert(data is List<T> || data is TreeSet<T> || data is AvlTreeSet<T>) {
    if (data is TreeSet<T>) {
      treeSet = TreeSet<T>();
      isList = false;
    } else if (data is List<T>) {
      list = [];
      isList = true;
    } else {
      throw ArgumentError("Invalid data type.");
    }
  }

  OrderedCollection.newList([Iterable<T>? data]) {
    list = List<T>.empty(growable: true)..addAll(data ?? []);
    isList = true;
  }

  OrderedCollection.newTreeSet([Iterable<T>? data]) {
    treeSet = TreeSet<T>()..addAll(data ?? []);
    isList = false;
  }

  @override
  void add(T item) {
    if (isList) {
      list!.add(item);
    } else {
      treeSet!.add(item);
    }
  }

  @override
  T operator [](int index) {
    if (isList) {
      return list![index];
    } else {
      return treeSet!.elementAt(index);
    }
  }

  @override
  int indexOf(T item, [int start = 0]) {
    if (isList) {
      return list!.indexOf(item, start);
    } else {
      final list = treeSet!.toList();
      return list.indexOf(item, start);
    }
  }

  @override
  Iterator<T> get iterator {
    if (isList) {
      return list!.iterator;
    } else {
      return treeSet!.iterator;
    }
  }

  @override
  void clear() {
    if (isList) {
      list!.clear();
    } else {
      treeSet!.clear();
    }
  }

  @override
  bool remove(Object? item) {
    if (isList) {
      return list!.remove(item);
    } else {
      return treeSet!.remove(item);
    }
  }

  @override
  T removeAt(int index) {
    if (isList) {
      return list!.removeAt(index);
    } else {
      final item = treeSet!.elementAt(index);
      treeSet!.remove(item);
      return item;
    }
  }

  @override
  void addAll(Iterable<T> iterable) {
    if (isList) {
      list!.addAll(iterable);
    } else {
      treeSet!.addAll(iterable);
    }
  }

  @override
  int indexWhere(bool Function(T) test, [int start = 0]) {
    if (isList) {
      return list!.indexWhere(test, start);
    } else {
      final list = treeSet!.toList();
      return list.indexWhere(test, start);
    }
  }

  @override
  int get length {
    if (isList) {
      return list!.length;
    } else {
      return treeSet!.length;
    }
  }

  @override
  bool get isEmpty {
    if (isList) {
      return list!.isEmpty;
    } else {
      return treeSet!.isEmpty;
    }
  }

  @override
  bool get isNotEmpty {
    return !isEmpty;
  }

  @override
  List<T> operator +(List<T> other) {
    if (isList) {
      return list! + other;
    } else {
      return treeSet!.toList() + other;
    }
  }

  @override
  void operator []=(int index, T value) {
    if (isList) {
      list![index] = value;
    } else {
      treeSet!.remove(treeSet!.elementAt(index));
      treeSet!.add(value);
    }
  }

  @override
  Map<int, T> asMap() {
    if (isList) {
      return list!.asMap();
    } else {
      return treeSet!.toList().asMap();
    }
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    if (isList) {
      list!.fillRange(start, end, fillValue);
    } else {
      removeRange(start, end);
      for (int i = start; i < end; i++) {
        add(fillValue as T);
      }
    }
  }

  @override
  set first(T value) {
    if (isList) {
      list![0] = value;
    } else {
      treeSet!.remove(treeSet!.first);
      treeSet!.add(value);
    }
  }

  @override
  Iterable<T> getRange(int start, int end) {
    if (isList) {
      return list!.getRange(start, end);
    } else {
      return treeSet!.toList().getRange(start, end);
    }
  }

  @override
  void insert(int index, T element) {
    if (isList) {
      list!.insert(index, element);
    } else {
      treeSet!.add(element);
    }
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    if (isList) {
      list!.insertAll(index, iterable);
    } else {
      treeSet!.addAll(iterable);
    }
  }

  @override
  set last(T value) {
    if (isList) {
      list![list!.length - 1] = value;
    } else {
      treeSet!.remove(treeSet!.last);
      treeSet!.add(value);
    }
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    if (isList) {
      return list!.lastIndexOf(element, start);
    } else {
      final list = treeSet!.toList();
      return list.lastIndexOf(element, start);
    }
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    if (isList) {
      return list!.lastIndexWhere(test, start);
    } else {
      final list = treeSet!.toList();
      return list.lastIndexWhere(test, start);
    }
  }

  @override
  set length(int newLength) {
    if (isList) {
      list!.length = newLength;
    } else {
      throw UnsupportedError("TreeSet does not support setting length.");
    }
  }

  @override
  T removeLast() {
    if (isList) {
      return list!.removeLast();
    } else {
      final last = treeSet!.last;
      treeSet!.remove(last);
      return last;
    }
  }

  @override
  void removeRange(int start, int end) {
    if (isList) {
      list!.removeRange(start, end);
    } else {
      for (int i = start; i < end; i++) {
        removeAt(start);
      }
    }
  }

  @override
  void removeWhere(bool Function(T element) test) {
    if (isList) {
      list!.removeWhere(test);
    } else {
      treeSet!.removeWhere(test);
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) {
    if (isList) {
      list!.replaceRange(start, end, replacements);
    } else {
      removeRange(start, end);
      addAll(replacements);
    }
  }

  @override
  void retainWhere(bool Function(T element) test) {
    if (isList) {
      list!.retainWhere(test);
    } else {
      treeSet!.retainWhere(test);
    }
  }

  @override
  Iterable<T> get reversed {
    if (isList) {
      return list!.reversed;
    } else {
      return treeSet!.toList().reversed;
    }
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    if (isList) {
      list!.setAll(index, iterable);
    } else {
      removeRange(index, iterable.length);
      addAll(iterable);
    }
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    if (isList) {
      list!.setRange(start, end, iterable, skipCount);
    } else {
      removeRange(start, end);
      addAll(iterable);
    }
  }

  @override
  void shuffle([Random? random]) {
    if (isList) {
      list!.shuffle(random);
    } else {
      throw UnsupportedError("TreeSet does not support shuffle operation.");
    }
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    if (isList) {
      list!.sort(compare);
    } else {
      throw UnsupportedError("TreeSet does not support sort operation.");
    }
  }

  @override
  List<T> sublist(int start, [int? end]) {
    if (isList) {
      return list!.sublist(start, end);
    } else {
      return treeSet!.toList().sublist(start, end);
    }
  }

  @override
  bool any(bool Function(T element) test) {
    if (isList) {
      return list!.any(test);
    } else {
      return treeSet!.any(test);
    }
  }

  @override
  List<R> cast<R>() {
    if (isList) {
      return list!.cast<R>();
    } else {
      return treeSet!.toList().cast<R>();
    }
  }

  @override
  bool contains(Object? element) {
    if (isList) {
      return list!.contains(element);
    } else {
      return treeSet!.contains(element);
    }
  }

  @override
  T elementAt(int index) {
    if (isList) {
      return list![index];
    } else {
      return treeSet!.elementAt(index);
    }
  }

  @override
  bool every(bool Function(T element) test) {
    if (isList) {
      return list!.every(test);
    } else {
      return treeSet!.every(test);
    }
  }

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T element) toElements) {
    if (isList) {
      return list!.expand(toElements);
    } else {
      return treeSet!.expand(toElements);
    }
  }

  @override
  T get first {
    if (isList) {
      return list!.first;
    } else {
      return treeSet!.first;
    }
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    if (isList) {
      return list!.firstWhere(test, orElse: orElse);
    } else {
      return treeSet!.firstWhere(test, orElse: orElse);
    }
  }

  @override
  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) {
    if (isList) {
      return list!.fold(initialValue, combine);
    } else {
      return treeSet!.fold(initialValue, combine);
    }
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    if (isList) {
      return list!.followedBy(other);
    } else {
      return treeSet!.followedBy(other);
    }
  }

  @override
  void forEach(void Function(T element) action) {
    if (isList) {
      list!.forEach(action);
    } else {
      treeSet!.forEach(action);
    }
  }

  @override
  String join([String separator = ""]) {
    if (isList) {
      return list!.join(separator);
    } else {
      return treeSet!.join(separator);
    }
  }

  @override
  T get last {
    if (isList) {
      return list!.last;
    } else {
      return treeSet!.last;
    }
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    if (isList) {
      return list!.lastWhere(test, orElse: orElse);
    } else {
      return treeSet!.lastWhere(test, orElse: orElse);
    }
  }

  @override
  Iterable<E> map<E>(E Function(T e) toElement) {
    if (isList) {
      return list!.map(toElement);
    } else {
      return treeSet!.map(toElement);
    }
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    if (isList) {
      return list!.reduce(combine);
    } else {
      return treeSet!.reduce(combine);
    }
  }

  @override
  T get single {
    if (isList) {
      return list!.single;
    } else {
      return treeSet!.single;
    }
  }

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    if (isList) {
      return list!.singleWhere(test, orElse: orElse);
    } else {
      return treeSet!.singleWhere(test, orElse: orElse);
    }
  }

  @override
  Iterable<T> skip(int count) {
    if (isList) {
      return list!.skip(count);
    } else {
      return treeSet!.skip(count);
    }
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    if (isList) {
      return list!.skipWhile(test);
    } else {
      return treeSet!.skipWhile(test);
    }
  }

  @override
  Iterable<T> take(int count) {
    if (isList) {
      return list!.take(count);
    } else {
      return treeSet!.take(count);
    }
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    if (isList) {
      return list!.takeWhile(test);
    } else {
      return treeSet!.takeWhile(test);
    }
  }

  @override
  List<T> toList({bool growable = true}) {
    if (isList) {
      return list!.toList(growable: growable);
    } else {
      return treeSet!.toList(growable: growable);
    }
  }

  @override
  Set<T> toSet() {
    if (isList) {
      return list!.toSet();
    } else {
      return treeSet!.toSet();
    }
  }

  @override
  Iterable<T> where(bool Function(T element) test) {
    if (isList) {
      return list!.where(test);
    } else {
      return treeSet!.where(test);
    }
  }

  @override
  Iterable<E> whereType<E>() {
    if (isList) {
      return list!.whereType<E>();
    } else {
      return treeSet!.whereType<E>();
    }
  }
}

import 'package:meta/meta.dart';

typedef Getter<S, T> = T Function(S);
typedef Updater<S, T> = S Function(S, T);

@immutable
class Lens<S, T> {
  final Getter<S, T> get;
  final Updater<S, T> update;

  const Lens(this.get, this.update);

  Lens<S, Q> then<Q>(Lens<T, Q> lens) => Lens<S, Q>(
        (s) => lens.get(get(s)),
        (s, q) => update(s, lens.update(get(s), q)),
      );

  Lens<S, Q> thenWithContext<Q>(Lens<T, Q> Function(S context) lensMaker) => Lens<S, Q>(
        (s) => lensMaker(s).get(get(s)),
        (s, q) => update(s, lensMaker(s).update(get(s), q)),
      );

  S map(T Function(T) f, S s) => update(s, f(get(s)));

  /// Not type safe!
  Lens<S, dynamic> operator >>(Lens<T, dynamic> lens) => then(lens);

  FocusedLens<S, T> of(S s) => FocusedLens<S, T>._(s, this);
}

@immutable
class FocusedLens<S, T> {
  final S _subject;
  final Lens<S, T> _lens;

  const FocusedLens._(this._subject, this._lens);

  FocusedLens<S, Q> then<Q>(Lens<T, Q> lens) => FocusedLens<S, Q>._(_subject, _lens.then(lens));

  FocusedLens<S, Q> thenWithContext<Q>(Lens<T, Q> Function(S context) lensMaker) =>
      FocusedLens<S, Q>._(_subject, _lens.thenWithContext(lensMaker));

  T get value => _lens.get(_subject);

  S update(T t) => _lens.update(_subject, t);

  S map(T Function(T) f) => update(f(value));
}

class List$ {
  List$._();

  static Lens<List<T>, T> atIndex<T>(int i) => Lens<List<T>, T>(
        (s) => s[i],
        (s, t) {
          assert(i >= 0 && i < s.length);
          final newS = List<T>.from(s);
          newS.replaceRange(i, i + 1, [t]);
          return newS;
        },
      );

  static Lens<List<T>, T> first<T>() => atIndex(0);

  static Lens<List<T>, T> where<T>(bool Function(T) predicate) => Lens<List<T>, T>(
        (s) => s.firstWhere(predicate),
        (s, t) {
          final index = s.indexWhere(predicate);
          final newS = List<T>.from(s);
          newS.replaceRange(index, index + 1, [t]);
          return newS;
        },
      );

  static Lens<List<T>, Optional<T>> whereOptional<T>(bool Function(T) predicate) => Lens<List<T>, Optional<T>>(
        (s) => Optional<T>(s.firstWhere(predicate, orElse: () => null)),
        (s, t) {
          if (!t.hasValue) return s;
          final index = s.indexWhere(predicate);
          if (index < 0) return s;
          final newS = List<T>.from(s);
          newS.replaceRange(index, index + 1, [t.raw]);
        },
      );
}

@immutable
class Optional<T> {
  final T raw;

  const Optional(this.raw);

  const Optional.none() : raw = null;

  bool get hasValue => raw != null;

  Optional<R> map<R>(R Function(T) f) => Optional<R>(raw != null ? f(raw) : null);

  T valueOr(T fallback) => raw != null ? raw : fallback;
}

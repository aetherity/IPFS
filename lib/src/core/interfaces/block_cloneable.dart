import 'package:meta/meta.dart';

mixin BlockCloneable<T extends BlockCloneable<T>> {
  T clone();
  T copyWith(void Function(T) updates);

  @protected
  T baseClone() {
    return (this as T).clone();
  }

  @protected
  T baseCopyWith(void Function(T) updates) {
    final clone = baseClone();
    updates(clone);
    return clone;
  }
}

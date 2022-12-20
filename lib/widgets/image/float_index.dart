extension FloatIndex on List<num> {
  double atFloatIndex(double index) {
    if (index < 0 || index > length - 1) throw RangeError('Index out of range: index should be less than $length: $index');
    return this[index.floor()] + (this[index.ceil()] - this[index.floor()]) * (index - index.floor());
  }
}
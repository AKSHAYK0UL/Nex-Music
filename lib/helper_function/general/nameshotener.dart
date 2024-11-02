String nameShotener({required String name, required int length}) {
  if (name.length < length) {
    return name;
  }
  final sName = "${name.substring(0, length)}...";
  return sName;
}

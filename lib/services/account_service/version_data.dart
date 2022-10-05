class VersionData {
  VersionData({
    required this.oldVersion,
    required this.newVersion,
  });

  final int oldVersion;
  final int newVersion;

  @override
  operator ==(Object other) =>
      other is VersionData &&
      other.oldVersion == oldVersion &&
      other.newVersion == newVersion;

  @override
  int get hashCode => Object.hashAll([
        oldVersion,
        newVersion,
      ]);
}

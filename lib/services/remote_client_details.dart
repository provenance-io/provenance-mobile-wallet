class RemoteClientDetails {
  RemoteClientDetails(
    this.id,
    this.description,
    this.url,
    this.name,
    this.icons,
  );
  final String id;
  final String description;
  final Uri? url;
  final String name;
  final List<String> icons;
}

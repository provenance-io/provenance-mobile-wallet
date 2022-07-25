class SignRequest {
  SignRequest({
    required this.id,
    required this.requestId,
    required this.message,
    required this.description,
    required this.address,
  });

  final String id;
  final int requestId;
  final String message;
  final String description;
  final String address;
}

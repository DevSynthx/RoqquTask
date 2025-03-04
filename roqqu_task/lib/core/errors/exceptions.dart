class WebSocketException implements Exception {
  final String message;

  const WebSocketException({required this.message});

  @override
  String toString() => 'WebSocketException: $message';
}

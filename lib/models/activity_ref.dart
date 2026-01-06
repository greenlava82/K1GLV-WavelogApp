class ActivityRef {
  final String type;      // 'POTA' or 'SOTA'
  final String reference; // 'K-1234'
  final String name;      // 'Blue Hills Reservation'

  ActivityRef({required this.type, required this.reference, required this.name});

  @override
  String toString() => reference;
}
class ReceiptTotal {
  ReceiptTotal({
    required this.total,
  });

  int total;

  factory ReceiptTotal.fromJson(Map<String, dynamic> map) {
    return ReceiptTotal(
      total: map['total'],
    );
  }
}

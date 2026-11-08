class ImportResult {
  const ImportResult({
    required this.status,
    required this.message,
    required this.importedCount,
  });

  final String status;
  final String message;
  final int importedCount;

  factory ImportResult.fromJson(Map<String, dynamic> json) {
    return ImportResult(
      status: json['status'] as String? ?? 'success',
      message: json['message'] as String? ?? '',
      importedCount: (json['importedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

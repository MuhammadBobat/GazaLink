enum SyncStatus {
  idle,
  inProgress,
  completed,
  error,
}

class SyncProgress {
  final SyncStatus status;
  final double progress;
  final String message;
  final String? error;

  SyncProgress({
    required this.status,
    this.progress = 0.0,
    required this.message,
    this.error,
  });
}
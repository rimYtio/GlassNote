abstract interface class AudioInputService {
  Future<bool> requestPermission();

  Stream<List<int>> startPcm16Stream();

  Future<void> stop();
}

abstract interface class AudioInputService {
  Future<bool> checkPermission();

  Future<bool> requestPermission();

  Stream<List<int>> startPcm16Stream();

  Stream<double> get amplitudeStream;

  Future<void> stop();
}

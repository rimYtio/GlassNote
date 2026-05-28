abstract interface class AudioInputService {
  Future<bool> requestPermission();

  Stream<List<int>> startPcm16Stream();

  Stream<double> get amplitudeStream;

  Future<void> stop();
}

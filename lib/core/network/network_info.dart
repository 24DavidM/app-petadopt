abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Implementación simple - puedes usar connectivity_plus si lo necesitas
    try {
      return true; // Por ahora asumimos que hay conexión
    } catch (e) {
      return false;
    }
  }
}

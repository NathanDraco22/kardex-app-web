class AppEnv {
  static const String serverUrl = String.fromEnvironment("SERVER_URL", defaultValue: "http://localhost:8000");
}

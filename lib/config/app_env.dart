class AppEnv {
  static const String serverUrl = String.fromEnvironment("SERVER_URL", defaultValue: "http://localhost:8000");
  static const String practiceUrl = String.fromEnvironment("PRACTICE_URL", defaultValue: "");
}

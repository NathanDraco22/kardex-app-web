import 'package:kardex_business/src/domain/models/user/user_model.dart';

class LoginResponse {
  final UserInDbWithRole user;
  final String accessToken;

  LoginResponse({
    required this.user,
    required this.accessToken,
  });

  bool get isAdmin => user.role == "Admin";

  factory LoginResponse.fromJson(dynamic json) {
    return LoginResponse(
      user: UserInDbWithRole.fromJson(json['user']),
      accessToken: json['accessToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
    };
  }
}

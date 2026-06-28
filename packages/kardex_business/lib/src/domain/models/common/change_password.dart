class ChangePasswordBody {
  String userId;
  String oldPassword;
  String newPassword;

  ChangePasswordBody({
    required this.userId,
    required this.oldPassword,
    required this.newPassword,
  });

  ChangePasswordBody.fromJson(Map<String, dynamic> json)
    : userId = json['userId'],
      oldPassword = json['oldPassword'],
      newPassword = json['newPassword'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userId'] = userId;
    data['oldPassword'] = oldPassword;
    data['newPassword'] = newPassword;
    return data;
  }
}

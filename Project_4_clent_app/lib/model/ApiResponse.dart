
class ApiResponse {
  final String accessToken;
  final String refreshToken;

  ApiResponse({required this.accessToken, required this.refreshToken});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    return data;
  }
}

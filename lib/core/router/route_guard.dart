class RouteGuard {
  static bool isAuthenticated(String? token) {
    return token != null && token.isNotEmpty;
  }
}

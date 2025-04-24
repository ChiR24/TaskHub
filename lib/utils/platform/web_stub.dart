// This file provides stub implementations of dart:io classes for web platform

/// A stub implementation of InternetAddress for web
class InternetAddress {
  final String address;
  
  InternetAddress(this.address);
  
  /// A stub implementation of lookup that always throws an exception on web
  static Future<List<InternetAddress>> lookup(String host) {
    throw UnsupportedError('InternetAddress.lookup');
  }
}

/// A stub implementation of Socket for web
class Socket {
  /// A stub implementation of connect that always throws an exception on web
  static Future<Socket> connect(String host, int port, {Duration? timeout}) {
    throw UnsupportedError('Socket constructor');
  }
  
  /// A stub implementation of close
  Future<void> close() async {}
}

/// A stub implementation of HttpClient for web
class HttpClient {
  Duration? connectionTimeout;
  
  /// A stub implementation of getUrl that always throws an exception on web
  Future<HttpClientRequest> getUrl(Uri url) {
    throw UnsupportedError('HttpClient.getUrl');
  }
  
  /// A stub implementation of close
  void close() {}
}

/// A stub implementation of HttpClientRequest for web
class HttpClientRequest {
  /// A stub implementation of close that always throws an exception on web
  Future<HttpClientResponse> close() {
    throw UnsupportedError('HttpClientRequest.close');
  }
}

/// A stub implementation of HttpClientResponse for web
class HttpClientResponse {
  /// A stub implementation of drain that always throws an exception on web
  Future<T> drain<T>() {
    throw UnsupportedError('HttpClientResponse.drain');
  }
}

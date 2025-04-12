import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://api.mplan.ashesi.edu.gh/api';
  final http.Client _client;
  final int _maxRetries = 2;
  final Duration _retryDelay = const Duration(seconds: 1);

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Generic GET request handler with retry logic
  Future<dynamic> _get(String endpoint) async {
    int attempt = 0;
    while (attempt <= _maxRetries) {
      try {
        final response = await _client.get(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 503) {
          throw ServerBusyException('Server is busy. Please try again later.');
        }

        return _handleResponse(response);
      } catch (e) {
        if (attempt == _maxRetries) {
          if (e is ServerBusyException) {
            rethrow;
          }
          throw _handleError(e);
        }
        await Future.delayed(_retryDelay);
        attempt++;
      }
    }
    throw FetchDataException('Failed after $_maxRetries attempts');
  }

  // Response handler
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw InvalidResponseException('Invalid JSON response');
        }
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorizedException(response.body.toString());
      case 404:
        throw NotFoundException(response.body.toString());
      case 500:
        throw ServerException(response.body.toString());
      case 503:
        throw ServerBusyException('Server is busy. Please try again later.');
      default:
        throw FetchDataException(
          'Error occurred while communicating with server: ${response.statusCode}',
        );
    }
  }

  // Error handler
  dynamic _handleError(dynamic error) {
    if (error is Exception) {
      throw error;
    } else {
      throw FetchDataException('Unexpected error: $error');
    }
  }

  // ===================
  // Specific API Methods
  // ===================

  /// Get current meal plan balance
  Future<double> getCurrentBalance(String studentId) async {
    try {
      final response = await _get('getCurrentBalance/$studentId');
      if (response is Map && response.containsKey('current_balance')) {
        return response['current_balance']?.toDouble() ?? 1111;
      }
      throw InvalidResponseException('Invalid balance response format');
    } on ServerBusyException {
      rethrow;
    } catch (e) {
      throw FetchDataException('Failed to get balance: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getMealPlanData(String studentId) async {
    if (studentId.isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }

    try {
      final response = await _get('getCurrentBalance/$studentId');

      if (response is! Map<String, dynamic>) {
        throw InvalidResponseException(
          'Expected Map<String, dynamic> but got ${response.runtimeType}',
        );
      }

      if (response.isEmpty) {
        throw InvalidResponseException('Response is empty');
      }

      return response;
    } on ServerBusyException {
      rethrow;
    } on InvalidResponseException {
      rethrow;
    } catch (e) {
      throw FetchDataException(
        'Failed to fetch meal plan data for student $studentId: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> getMelaPlanHistory(
      String studentId, String startDate, String endDate) async {
    if (studentId.isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }

    try {
      final response =
          await _get('getCurrentBalance/$studentId/$startDate/$endDate');

      if (response is! Map<String, dynamic>) {
        throw InvalidResponseException(
          'Expected Map<String, dynamic> but got ${response.runtimeType}',
        );
      }

      if (response.isEmpty) {
        throw InvalidResponseException('Response is empty');
      }

      return response;
    } on ServerBusyException {
      rethrow;
    } on InvalidResponseException {
      rethrow;
    } catch (e) {
      throw FetchDataException(
        'Failed to fetch meal plan history for student $studentId: ${e.toString()}',
      );
    }
  }
}

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message);
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message);
}

class ServerException extends AppException {
  ServerException(String message) : super(message);
}

class ServerBusyException extends AppException {
  ServerBusyException(String message) : super(message);
}

class InvalidResponseException extends AppException {
  InvalidResponseException(String message) : super(message);
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class UserResponse {
  final int idPregunta;
  final String idAlternativaSeleccionada;
  final bool esCorrecta;
  final DateTime fechaRespuesta;

  UserResponse({
    required this.idPregunta,
    required this.idAlternativaSeleccionada,
    required this.esCorrecta,
    required this.fechaRespuesta,
  });

  Map<String, dynamic> toJson() {
    return {
      'idPregunta': idPregunta,
      'idAlternativaSeleccionada': idAlternativaSeleccionada,
      'esCorrecta': esCorrecta,
      'fechaRespuesta': fechaRespuesta.toIso8601String(),
    };
  }

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      idPregunta: json['idPregunta'],
      idAlternativaSeleccionada: json['idAlternativaSeleccionada'],
      esCorrecta: json['esCorrecta'],
      fechaRespuesta: DateTime.parse(json['fechaRespuesta']),
    );
  }
}

class UserProfile {
  final String userId;
  final List<UserResponse> responses;

  UserProfile({
    required this.userId,
    required this.responses,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'responses': responses.map((response) => response.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var responsesList = json['responses'] as List;
    List<UserResponse> responses = responsesList
        .map((resp) => UserResponse.fromJson(resp))
        .toList();

    return UserProfile(
      userId: json['userId'],
      responses: responses,
    );
  }
}

class UserProfileService {
  static const String _fileName = 'user_profile.json';
  static UserProfile? _cachedProfile;

  static Future<UserProfile> loadUserProfile() async {
    if (_cachedProfile != null) {
      return _cachedProfile!;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        _cachedProfile = UserProfile.fromJson(json.decode(jsonString));
      } else {
        // Create a new profile if none exists
        _cachedProfile = UserProfile(
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          responses: [],
        );
        await saveUserProfile(_cachedProfile!);
      }
    } catch (e) {
      print('Error loading user profile: $e');
      _cachedProfile = UserProfile(
        userId: 'default_user',
        responses: [],
      );
    }

    return _cachedProfile!;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      await file.writeAsString(json.encode(profile.toJson()));
      _cachedProfile = profile;
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  static Future<void> addResponse(UserResponse response) async {
    final profile = await loadUserProfile();
    
    // Check if there's already a response for this question
    final existingIndex = profile.responses.indexWhere(
      (r) => r.idPregunta == response.idPregunta
    );
    
    if (existingIndex >= 0) {
      // If we already have a response, don't replace it
      // (keeping only the first answer as specified)
      return;
    }
    
    final updatedResponses = List<UserResponse>.from(profile.responses)..add(response);
    final updatedProfile = UserProfile(
      userId: profile.userId,
      responses: updatedResponses,
    );
    
    await saveUserProfile(updatedProfile);
  }

  static Future<UserResponse?> getResponseForQuestion(int idPregunta) async {
    final profile = await loadUserProfile();
    try {
      return profile.responses.firstWhere(
        (response) => response.idPregunta == idPregunta
      );
    } catch (e) {
      return null; // No response found for this question
    }
  }
}

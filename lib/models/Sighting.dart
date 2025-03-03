/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the Sighting type in your schema. */
class Sighting extends amplify_core.Model {
  static const classType = const _SightingModelType();
  final String id;
  final String? _species;
  final String? _photo;
  final double? _latitude;
  final double? _longitude;
  final amplify_core.TemporalDateTime? _timestamp;
  final String? _notes;
  final User? _user;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SightingModelIdentifier get modelIdentifier {
      return SightingModelIdentifier(
        id: id
      );
  }
  
  String get species {
    try {
      return _species!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get photo {
    return _photo;
  }
  
  double get latitude {
    try {
      return _latitude!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get longitude {
    try {
      return _longitude!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get timestamp {
    try {
      return _timestamp!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get notes {
    return _notes;
  }
  
  User? get user {
    return _user;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Sighting._internal({required this.id, required species, photo, required latitude, required longitude, required timestamp, notes, user, createdAt, updatedAt}): _species = species, _photo = photo, _latitude = latitude, _longitude = longitude, _timestamp = timestamp, _notes = notes, _user = user, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Sighting({String? id, required String species, String? photo, required double latitude, required double longitude, required amplify_core.TemporalDateTime timestamp, String? notes, User? user}) {
    return Sighting._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      species: species,
      photo: photo,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      notes: notes,
      user: user);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Sighting &&
      id == other.id &&
      _species == other._species &&
      _photo == other._photo &&
      _latitude == other._latitude &&
      _longitude == other._longitude &&
      _timestamp == other._timestamp &&
      _notes == other._notes &&
      _user == other._user;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Sighting {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("species=" + "$_species" + ", ");
    buffer.write("photo=" + "$_photo" + ", ");
    buffer.write("latitude=" + (_latitude != null ? _latitude!.toString() : "null") + ", ");
    buffer.write("longitude=" + (_longitude != null ? _longitude!.toString() : "null") + ", ");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.format() : "null") + ", ");
    buffer.write("notes=" + "$_notes" + ", ");
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Sighting copyWith({String? species, String? photo, double? latitude, double? longitude, amplify_core.TemporalDateTime? timestamp, String? notes, User? user}) {
    return Sighting._internal(
      id: id,
      species: species ?? this.species,
      photo: photo ?? this.photo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      user: user ?? this.user);
  }
  
  Sighting copyWithModelFieldValues({
    ModelFieldValue<String>? species,
    ModelFieldValue<String?>? photo,
    ModelFieldValue<double>? latitude,
    ModelFieldValue<double>? longitude,
    ModelFieldValue<amplify_core.TemporalDateTime>? timestamp,
    ModelFieldValue<String?>? notes,
    ModelFieldValue<User?>? user
  }) {
    return Sighting._internal(
      id: id,
      species: species == null ? this.species : species.value,
      photo: photo == null ? this.photo : photo.value,
      latitude: latitude == null ? this.latitude : latitude.value,
      longitude: longitude == null ? this.longitude : longitude.value,
      timestamp: timestamp == null ? this.timestamp : timestamp.value,
      notes: notes == null ? this.notes : notes.value,
      user: user == null ? this.user : user.value
    );
  }
  
  Sighting.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _species = json['species'],
      _photo = json['photo'],
      _latitude = (json['latitude'] as num?)?.toDouble(),
      _longitude = (json['longitude'] as num?)?.toDouble(),
      _timestamp = json['timestamp'] != null ? amplify_core.TemporalDateTime.fromString(json['timestamp']) : null,
      _notes = json['notes'],
      _user = json['user'] != null
        ? json['user']['serializedData'] != null
          ? User.fromJson(new Map<String, dynamic>.from(json['user']['serializedData']))
          : User.fromJson(new Map<String, dynamic>.from(json['user']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'species': _species, 'photo': _photo, 'latitude': _latitude, 'longitude': _longitude, 'timestamp': _timestamp?.format(), 'notes': _notes, 'user': _user?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'species': _species,
    'photo': _photo,
    'latitude': _latitude,
    'longitude': _longitude,
    'timestamp': _timestamp,
    'notes': _notes,
    'user': _user,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<SightingModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<SightingModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final SPECIES = amplify_core.QueryField(fieldName: "species");
  static final PHOTO = amplify_core.QueryField(fieldName: "photo");
  static final LATITUDE = amplify_core.QueryField(fieldName: "latitude");
  static final LONGITUDE = amplify_core.QueryField(fieldName: "longitude");
  static final TIMESTAMP = amplify_core.QueryField(fieldName: "timestamp");
  static final NOTES = amplify_core.QueryField(fieldName: "notes");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Sighting";
    modelSchemaDefinition.pluralName = "Sightings";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Sighting.SPECIES,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Sighting.PHOTO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Sighting.LATITUDE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Sighting.LONGITUDE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Sighting.TIMESTAMP,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Sighting.NOTES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Sighting.USER,
      isRequired: false,
      targetNames: ['userSightingsId'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _SightingModelType extends amplify_core.ModelType<Sighting> {
  const _SightingModelType();
  
  @override
  Sighting fromJson(Map<String, dynamic> jsonData) {
    return Sighting.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Sighting';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Sighting] in your schema.
 */
class SightingModelIdentifier implements amplify_core.ModelIdentifier<Sighting> {
  final String id;

  /** Create an instance of SightingModelIdentifier using [id] the primary key. */
  const SightingModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'SightingModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SightingModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}
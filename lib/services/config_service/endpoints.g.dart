// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'endpoints.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Endpoints _$EndpointsFromJson(Map<String, dynamic> json) => Endpoints(
      version: json['version'] as int,
      figureTech: Endpoint.fromJson(json['figureTech'] as Map<String, dynamic>),
      chain: Endpoint.fromJson(json['chain'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EndpointsToJson(Endpoints instance) => <String, dynamic>{
      'version': instance.version,
      'figureTech': instance.figureTech,
      'chain': instance.chain,
    };

Endpoint _$EndpointFromJson(Map<String, dynamic> json) => Endpoint(
      mainUrl: json['mainUrl'] as String,
      testUrl: json['testUrl'] as String,
    );

Map<String, dynamic> _$EndpointToJson(Endpoint instance) => <String, dynamic>{
      'mainUrl': instance.mainUrl,
      'testUrl': instance.testUrl,
    };

import 'package:json_annotation/json_annotation.dart';

import 'nullable_extensions.dart';

class const DurationSecondsConverter() extends JsonConverter<Duration, int> {
  @override
  Duration fromJson(int json) => Duration(seconds: json);

  @override
  int toJson(Duration object) => object.inSeconds;
}

class const NullableDurationSecondsConverter()
    extends JsonConverter<Duration?, int?> {
  @override
  Duration? fromJson(int? json) =>
      json.map((durationSeconds) => Duration(seconds: durationSeconds));

  @override
  int? toJson(Duration? object) => object?.inSeconds;
}

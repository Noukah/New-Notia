import 'package:equatable/equatable.dart';

abstract class AudioRecorderEvent extends Equatable {
  const AudioRecorderEvent();

  @override
  List<Object?> get props => [];
}

class CheckRecordingPermissionEvent extends AudioRecorderEvent {}

class StartRecordingEvent extends AudioRecorderEvent {
  final String? outputPath;

  const StartRecordingEvent([this.outputPath]);

  @override
  List<Object?> get props => [outputPath];
}

class StopRecordingAndTranscribeEvent extends AudioRecorderEvent {}

class CancelRecordingEvent extends AudioRecorderEvent {}

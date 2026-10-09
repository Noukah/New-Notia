import 'package:equatable/equatable.dart';

abstract class AudioRecorderState extends Equatable {
  const AudioRecorderState();

  @override
  List<Object?> get props => [];
}

class AudioRecorderIdle extends AudioRecorderState {
  const AudioRecorderIdle();
}

class AudioRecordingInProgress extends AudioRecorderState {
  final String recordingPath;
  final DateTime startTime;

  const AudioRecordingInProgress({
    required this.recordingPath,
    required this.startTime,
  });

  @override
  List<Object?> get props => [recordingPath, startTime];
}

class AudioTranscribingInProgress extends AudioRecorderState {
  final String recordingPath;

  const AudioTranscribingInProgress({required this.recordingPath});

  @override
  List<Object?> get props => [recordingPath];
}

class AudioTranscriptionSuccess extends AudioRecorderState {
  final String transcribedText;
  final String recordingPath;

  const AudioTranscriptionSuccess({
    required this.transcribedText,
    required this.recordingPath,
  });

  @override
  List<Object?> get props => [transcribedText, recordingPath];
}

class AudioRecorderFailure extends AudioRecorderState {
  final String errorMessage;

  const AudioRecorderFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

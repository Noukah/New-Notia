import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notia/core/storage/secure_storage_service.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_bloc.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_event.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_state.dart';
import 'package:notia/features/home/presentation/widgets/dual_circle_switcher.dart';
import 'package:notia/features/home/presentation/widgets/floating_dock.dart';
import 'package:notia/features/home/presentation/widgets/profile_selector_row.dart';
import 'package:notia/features/home/presentation/widgets/recording_controls_bar.dart';
import 'package:notia/features/home/presentation/widgets/top_bar.dart';
import 'package:notia/features/notes/domain/models/recording_profile.dart';
import 'package:notia/features/notes/presentation/screens/notes_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  final SecureStorageService secureStorageService;

  const HomeScreen({
    super.key,
    required this.secureStorageService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeIndex = 0; // 0 = Audio, 1 = Escribir texto
  bool _isSubmenuOpen = false;
  RecordingProfile _currentProfile = RecordingProfile.general;

  Timer? _recordTimer;
  Duration _duration = Duration.zero;
  bool _isPaused = false;

  void _startDurationTimer() {
    _duration = Duration.zero;
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _duration += const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopDurationTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
    _duration = Duration.zero;
  }

  void _toggleSubmenu() {
    setState(() {
      _isSubmenuOpen = !_isSubmenuOpen;
    });
  }

  void _startInstantAction() {
    if (_activeIndex == 0) {
      // Modo Audio: Iniciar grabación con perfil general (doble tap)
      _currentProfile = RecordingProfile.general;
      context.read<AudioRecorderBloc>().add(StartRecordingEvent());
      _startDurationTimer();
      setState(() {
        _isSubmenuOpen = false;
      });
    } else {
      // Modo Escritura: Abrir editor de nota en blanco
      _openBlankNoteEditor();
    }
  }

  void _startProfileRecording(RecordingProfile profile) {
    _currentProfile = profile;
    context.read<AudioRecorderBloc>().add(StartRecordingEvent());
    _startDurationTimer();
    setState(() {
      _isSubmenuOpen = false;
    });
  }

  void _openBlankNoteEditor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo editor de notas en blanco...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showMissingApiKeyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('API Key Requerida'),
          ],
        ),
        content: const Text(
          'Para utilizar los perfiles inteligentes con Inteligencia Artificial, '
          'necesitas configurar tu API Key (Gemini, OpenAI o DeepSeek) en los Ajustes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSettingsModal();
            },
            child: const Text('Ir a Ajustes'),
          ),
        ],
      ),
    );
  }

  void _showSettingsModal() {
    final keyController = TextEditingController();
    String selectedProvider = 'gemini';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuración de IA',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Proveedor de Inteligencia Artificial:'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'gemini', label: Text('Gemini')),
                    ButtonSegment(value: 'openai', label: Text('OpenAI')),
                    ButtonSegment(value: 'deepseek', label: Text('DeepSeek')),
                  ],
                  selected: {selectedProvider},
                  onSelectionChanged: (val) {
                    setModalState(() => selectedProvider = val.first);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: keyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API Key del proveedor',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final key = keyController.text.trim();
                      if (key.isNotEmpty) {
                        await widget.secureStorageService.saveApiKey(key);
                        await widget.secureStorageService.saveAiProvider(selectedProvider);
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('API Key guardada de forma segura.')),
                        );
                      }
                    },
                    child: const Text('Guardar Configuración'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioRecorderBloc, AudioRecorderState>(
      listener: (context, state) {
        if (state is AudioTranscriptionSuccess) {
          _stopDurationTimer();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Nota Procesada (${_currentProfile.name})'),
              content: SingleChildScrollView(
                child: Text(
                  state.transcribedText.isNotEmpty
                      ? state.transcribedText
                      : 'No se detectó voz clara en el audio.',
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        } else if (state is AudioRecorderFailure) {
          _stopDurationTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        final isRecording = state is AudioRecordingInProgress;
        final isTranscribing = state is AudioTranscribingInProgress;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // 1. Barra Superior (Solo visible si NO está grabando)
                AnimatedOpacity(
                  opacity: isRecording ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: isRecording
                      ? const SizedBox(height: 52)
                      : HomeTopBar(
                          onNotesTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotesViewerScreen(),
                              ),
                            );
                          },
                          onSettingsTap: _showSettingsModal,
                        ),
                ),

                const Spacer(flex: 1),

                // 2. Centro: Selector de Círculos Superpuestos con Swipe
                if (isTranscribing)
                  const Column(
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Transcribiendo con Sherpa ONNX...',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  )
                else
                  DualCircleSwitcher(
                    activeIndex: _activeIndex,
                    isRecording: isRecording,
                    recordingDuration: _duration,
                    onIndexChanged: (newIdx) {
                      setState(() {
                        _activeIndex = newIdx;
                        _isSubmenuOpen = false;
                      });
                    },
                    onSingleTap: _toggleSubmenu,
                    onDoubleTap: _startInstantAction,
                  ),

                const SizedBox(height: 20),

                // 3. Fila de Perfiles (Submenú desplegable al tocar 1 vez)
                AnimatedOpacity(
                  opacity: (_isSubmenuOpen && !isRecording && !isTranscribing) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: (_isSubmenuOpen && !isRecording && !isTranscribing)
                      ? ProfileSelectorRow(
                          secureStorageService: widget.secureStorageService,
                          onMissingApiKey: _showMissingApiKeyDialog,
                          onProfileSelected: _startProfileRecording,
                        )
                      : const SizedBox(height: 54),
                ),

                const Spacer(flex: 2),

                // 4. Barra Inferior: Dock normal O Controles de Grabación activa
                if (isRecording)
                  RecordingControlsBar(
                    isPaused: _isPaused,
                    onDiscard: () {
                      _stopDurationTimer();
                      context.read<AudioRecorderBloc>().add(CancelRecordingEvent());
                    },
                    onPauseResume: () {
                      setState(() {
                        _isPaused = !_isPaused;
                      });
                    },
                    onStop: () {
                      _stopDurationTimer();
                      context.read<AudioRecorderBloc>().add(StopRecordingAndTranscribeEvent());
                    },
                  )
                else
                  FloatingDock(
                    onCreateFolderTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Crear nueva carpeta o grupo')),
                      );
                    },
                    onNotificationsTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificaciones (próximamente)')),
                      );
                    },
                    onSearchTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Búsqueda rápida de notas')),
                      );
                    },
                    onImportAudioTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Importar archivo de audio externo')),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

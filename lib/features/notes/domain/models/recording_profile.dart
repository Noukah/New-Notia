import 'package:flutter/material.dart';

class RecordingProfile {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String systemPrompt;

  const RecordingProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.systemPrompt,
  });

  static List<RecordingProfile> get defaultProfiles => const [
        RecordingProfile(
          id: 'escuela',
          name: 'Escuela',
          description: 'Estructura clases, conceptos clave y preguntas de repaso.',
          icon: Icons.school_outlined,
          systemPrompt:
              'Organiza esta transcripción como apuntes de clase. Identifica tema principal, conceptos clave explicados, definiciones importantes y posibles preguntas de examen.',
        ),
        RecordingProfile(
          id: 'reuniones',
          name: 'Reuniones',
          description: 'Minuta ejecutiva, acuerdos tomados y responsables.',
          icon: Icons.groups_outlined,
          systemPrompt:
              'Estructura esta transcripción como minuta de reunión: Objetivo, participantes/intervenciones clave, acuerdos formales y lista de tareas con responsables.',
        ),
        RecordingProfile(
          id: 'trabajo',
          name: 'Trabajo',
          description: 'Actualizaciones de estado, bloqueos y planes de acción.',
          icon: Icons.work_outline_rounded,
          systemPrompt:
              'Estructura esta nota en formato profesional de trabajo: Resumen de estado, decisiones técnicas/operativas, bloqueos identificados y siguientes pasos inmediatos.',
        ),
        RecordingProfile(
          id: 'ideas',
          name: 'Ideas',
          description: 'Lluvia de ideas, desarrollo de conceptos y visión.',
          icon: Icons.lightbulb_outline_rounded,
          systemPrompt:
              'Transforma este pensamiento o lluvia de ideas en una propuesta estructurada: Idea central, puntos fuertes, posibles ángulos y plan de experimentación.',
        ),
        RecordingProfile(
          id: 'proyectos',
          name: 'Proyectos',
          description: 'Hitos, alcance, entregables y cronograma.',
          icon: Icons.rocket_launch_outlined,
          systemPrompt:
              'Estructura esta nota con enfoque de gestión de proyecto: Alcance, entregables clave, dependencias, riesgos y cronograma estimado.',
        ),
      ];

  static const RecordingProfile general = RecordingProfile(
    id: 'general',
    name: 'General',
    description: 'Transcripción limpia organizada por títulos y puntos clave.',
    icon: Icons.auto_awesome_rounded,
    systemPrompt:
        'Organiza y limpia esta nota en formato Markdown legible con un título descriptivo, resumen conciso y viñetas de puntos clave.',
  );
}

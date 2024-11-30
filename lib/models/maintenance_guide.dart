class MaintenanceGuide {
  final int? id;
  final String title;
  final String description;
  final List<String> steps;
  final int estimatedDuration; // in minutes
  final double estimatedCost;
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final List<String> tools;
  final List<String> parts;
  final String? videoUrl;

  MaintenanceGuide({
    this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.estimatedDuration,
    required this.estimatedCost,
    required this.difficulty,
    required this.tools,
    required this.parts,
    this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps': steps,
      'estimatedDuration': estimatedDuration,
      'estimatedCost': estimatedCost,
      'difficulty': difficulty,
      'tools': tools,
      'parts': parts,
      'videoUrl': videoUrl,
    };
  }

  factory MaintenanceGuide.fromMap(Map<String, dynamic> map) {
    return MaintenanceGuide(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      steps: List<String>.from(map['steps']),
      estimatedDuration: map['estimatedDuration'],
      estimatedCost: map['estimatedCost'],
      difficulty: map['difficulty'],
      tools: List<String>.from(map['tools']),
      parts: List<String>.from(map['parts']),
      videoUrl: map['videoUrl'],
    );
  }
}

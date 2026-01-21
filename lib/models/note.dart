class Note {
  final int? id;
  final String contenu;

  const Note({this.id, required this.contenu});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'contenu': contenu,
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int?,
      contenu: map['contenu'] as String? ?? '',
    );
  }

  Note copyWith({int? id, String? contenu}) {
    return Note(
      id: id ?? this.id,
      contenu: contenu ?? this.contenu,
    );
  }
}

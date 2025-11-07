/// A lightweight model representing a freezone recommendation from AI.
/// Contains the human-readable name from AI and optional normalized ID.
class FreezoneRec {
  /// Human-readable name from AI (e.g., "RAK Free Trade Zone")
  final String name;

  /// Optional canonical ID/slug used by our dataset (e.g., "RAKEZ")
  final String? id;

  const FreezoneRec({required this.name, this.id});

  /// Create from AI recommendation with auto-normalization
  factory FreezoneRec.fromAiName(String aiName) {
    return FreezoneRec(
      name: aiName,
      id: null, // Will be normalized later when needed
    );
  }

  @override
  String toString() => 'FreezoneRec(name: $name, id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreezoneRec &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

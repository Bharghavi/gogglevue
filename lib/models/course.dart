class Course {
  final String? courseId; // Nullable because it might not be assigned yet
  final String name;
  final Category category;
  final String adminId;

  Course({
    this.courseId, // Nullable, can be omitted when creating a Course
    required this.name,
    required this.category,
    required this.adminId,
  });

  // Factory method to create a Course from Firestore document
  factory Course.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Course(
      courseId: documentId, // Assign document ID
      name: data['name'] ?? '',
      adminId: data['adminId'] ?? '',
      category: _categoryFromString(data['category'] ?? 'academics'),
    );
  }

  // Method to convert a Course to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminId': adminId,
      'category': _categoryToString(category),
    };
  }

  // Helper method to convert Category enum to string
  static String _categoryToString(Category category) {
    switch (category) {
      case Category.academics:
        return 'academics';
      case Category.sports:
        return 'sports';
    }
  }

  // Helper method to convert string to Category enum
  static Category _categoryFromString(String category) {
    switch (category) {
      case 'academics':
        return Category.academics;
      case 'sports':
        return Category.sports;
      default:
        return Category.academics;
    }
  }
}

enum Category {
  academics,
  sports,
}

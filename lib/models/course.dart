class Course {
  final String? courseId;
  final String name;
  final Category category;

  Course({
    this.courseId,
    required this.name,
    required this.category,
  });

  // Factory method to create a Course from Firestore document
  factory Course.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Course(
      courseId: documentId, // Assign document ID
      name: data['name'] ?? '',
      category: _categoryFromString(data['category'] ?? 'academics'),
    );
  }

  // Method to convert a Course to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
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
      case Category.therapy:
        return 'therapy';
      case Category.others:
        return 'others';
    }
  }

  // Helper method to convert string to Category enum
  static Category _categoryFromString(String category) {
    switch (category) {
      case 'academics':
        return Category.academics;
      case 'sports':
        return Category.sports;
      case 'therapy':
        return Category.therapy;
      case 'others':
        return Category.others;
      default:
        return Category.academics;
    }
  }
}

enum Category {
  academics,
  sports,
  therapy,
  others,
}

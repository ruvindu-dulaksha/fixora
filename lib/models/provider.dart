class ServiceCategory {
  const ServiceCategory({required this.id, required this.name});
  final String id;
  final String name;
}

class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.rating,
    required this.reviewCount,
    required this.completedJobs,
    required this.experienceYears,
    required this.hourlyRate,
    required this.location,
    required this.isAvailable,
    required this.description,
    required this.skills,
    this.reviews = const [],
  });

  final String id;
  final String name;
  final String categoryId;
  final double rating;
  final int reviewCount;
  final int completedJobs;
  final int experienceYears;
  final int hourlyRate;
  final String location;
  final bool isAvailable;
  final String description;
  final List<String> skills;
  final List<Review> reviews;

  factory ProviderProfile.fromJson(Map<String, dynamic> json) => ProviderProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        categoryId: json['categoryId'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        completedJobs: json['completedJobs'] as int,
        experienceYears: json['experienceYears'] as int,
        hourlyRate: json['hourlyRate'] as int,
        location: json['location'] as String,
        isAvailable: json['isAvailable'] as bool,
        description: json['description'] as String,
        skills: List<String>.from(json['skills'] as List),
      );

  ProviderProfile copyWith({List<Review>? reviews, double? rating, int? reviewCount}) =>
      ProviderProfile(
        id: id,
        name: name,
        categoryId: categoryId,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        completedJobs: completedJobs,
        experienceYears: experienceYears,
        hourlyRate: hourlyRate,
        location: location,
        isAvailable: isAvailable,
        description: description,
        skills: skills,
        reviews: reviews ?? this.reviews,
      );
}

class Review {
  const Review({required this.rating, required this.comment, required this.author});
  final int rating;
  final String comment;
  final String author;
}

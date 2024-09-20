
class Places{
  final String name;
  final String description;
  final String imagePath;
  final PlaceCategory category;
  final PlaceCity city;

  Places({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.category,
    required this.city,
  });
}

enum PlaceCategory{
  Mountains,
  Beaches,
  Forest,
  Desert,
}

enum PlaceCity{
  Karachi,
  Islamabad,
  Lahore,
  Chitral,
  Skardu,
  Gwadar,
  Abbottabad,
  Hyderabad,
  Bahawalpur,
  Quetta,
  Mianwali,
}




class SplashContents {
  final String title;
  final String image;
  final String desc;

  SplashContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<SplashContents> contents = [
  SplashContents(
    title: "Your Ultimate Travel Companion",
    image: "./images/img3.png",
    desc: "Navigate effortlessly with insider tips and personalized recommendations.",
  ),
  SplashContents(
    title: "Unlock Your Adventure",
    image: "./images/img1.png",
    desc: "Embark on unforgettable journeys with tailored itineraries.",
  ),
  SplashContents(
    title: "Discover Local Wonders",
    image: "./images/img4.png",
    desc:"Explore hidden treasures and iconic landmarks in your city.",
  ),
];
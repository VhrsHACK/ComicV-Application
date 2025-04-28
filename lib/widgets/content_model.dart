class unboardingContent {
  String image;
  String title;
  String description;
  unboardingContent({
    required this.description,
    required this.image,
    required this.title,
  });
}

List<unboardingContent> contents = [
  // PAGE 1
  unboardingContent(
    description:
        'Solusi Terbaik untuk anda yang ingin membeli\n                           komik secara online',
    image: 'images/logocomicv.png',
    title: 'ComicV',
  ),
  // PAGE 2
  unboardingContent(
    description:
        ' Komik dan Light Novel terlengkap dan terupdate\n             dengan harga yang terjangkau',
    image: 'images/logocomicv2.png',
    title: 'Complete ',
  ),
  // PAGE 3
  unboardingContent(
    description:
        ' Mencari komik yang anda inginkan\n           dengan mudah dan cepat',
    image: 'images/logocomicv3.png',
    title: 'Online Searching',
  ),
];

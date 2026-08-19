enum Flavor { school, coaching, trainingCenter }

class FlavorConfig {
  final Flavor flavor;
  final String title;

  const FlavorConfig({
    required this.flavor,
    required this.title,
  });

  static FlavorConfig current = const FlavorConfig(
    flavor: Flavor.school,
    title: 'Alphie Core - Education SaaS',
  );
}

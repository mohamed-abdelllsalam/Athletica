class CoachPlanClient {
  const CoachPlanClient({
    required this.id,
    required this.name,
    required this.fatGrams,
    required this.carbGrams,
    required this.proteinGrams,
    this.imageAsset,
  });

  final String id;
  final String name;
  final int fatGrams;
  final int carbGrams;
  final int proteinGrams;
  final String? imageAsset;
}

abstract class CoachPlanData {
  static const List<CoachPlanClient> clients = [
    CoachPlanClient(
      id: '1',
      name: 'Salem Ahmed',
      fatGrams: 60,
      carbGrams: 200,
      proteinGrams: 100,
    ),
    CoachPlanClient(
      id: '2',
      name: 'Ali Ahmed',
      fatGrams: 60,
      carbGrams: 200,
      proteinGrams: 100,
    ),
    CoachPlanClient(
      id: '3',
      name: 'Anas Ahmed',
      fatGrams: 60,
      carbGrams: 200,
      proteinGrams: 100,
    ),
    CoachPlanClient(
      id: '4',
      name: 'Nour Mohamed',
      fatGrams: 60,
      carbGrams: 200,
      proteinGrams: 100,
    ),
    CoachPlanClient(
      id: '5',
      name: 'Rayan Ali',
      fatGrams: 60,
      carbGrams: 200,
      proteinGrams: 100,
    ),
  ];
}

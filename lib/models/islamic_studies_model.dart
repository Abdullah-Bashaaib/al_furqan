class IslamicStudiesModel {
  String? islamicStudiesID;
  String? elhalagatID;
  String? subject;
  String? plannedContent;
  String? executedContent;
  String? planMonth;
  int? isSync;

  IslamicStudiesModel({
    this.islamicStudiesID,
    required this.elhalagatID,
    required this.subject,
    required this.plannedContent,
    this.executedContent,
    this.planMonth,
    this.isSync,
  });

  // Convert The Plan Map To IslamicStudiesModel
  factory IslamicStudiesModel.fromMap(Map<String, dynamic> plan) {
    return IslamicStudiesModel(
        islamicStudiesID: plan['IslamicStudiesID'],
        elhalagatID: plan['ElhalagatID'],
        subject: plan['Subject'],
        plannedContent: plan['PlannedContent'],
        executedContent: plan['ExecutedContent'],
        planMonth: plan['PlanMonth'],
        isSync: plan['isSync']);
  }

  // Convert The IslamicStudiesModel To Plan Map
  Map<String, dynamic> toMap() {
    return {
      'IslamicStudiesID': islamicStudiesID,
      'ElhalagatID': elhalagatID,
      'Subject': subject,
      'PlannedContent': plannedContent,
      'ExecutedContent': executedContent,
      'PlanMonth': planMonth,
      'isSync': isSync
    };
  }
}

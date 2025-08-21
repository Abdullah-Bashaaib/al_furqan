import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/report_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> getData({
    required String collection,
    String? field,
    dynamic id,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      if (field != null && id != null) {
        query = query.where(field, isEqualTo: id);
      }
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot;
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  Future<List<ReportModel>> loadReportHalaga(int schoolID) async {
    // جلب كل الحلقات التابعة للمدرسة
    final halagaSnapshot =
        await getData(collection: 'Elhalaga', field: 'SchoolID', id: schoolID);
    final List<HalagaModel> halagaModels = halagaSnapshot.docs
        .map((doc) => HalagaModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    List<ReportModel> reports = [];

    for (var halagaModel in halagaModels) {
      // جلب المعلم
      final teacherSnapshot = await getData(
          collection: 'Users', field: 'ElhalagatID', id: halagaModel.halagaID);
      final teacherModel = UserModel.fromJson(
          teacherSnapshot.docs.first.data() as Map<String, dynamic>);

      // جلب كل خطط المحافظة
      final conPlanSnapshot = await getData(
          collection: 'ConservationPlans',
          field: 'ElhalagatID',
          id: halagaModel.halagaID,
          orderByField: 'PlanMonth',
          descending: true);
      final List<ConservationPlanModel> conservationPlans = conPlanSnapshot.docs
          .map((doc) =>
              ConservationPlanModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // حساب نسبة تنفيذ خطط المحافظة المرجحة حسب عدد الطلاب
      double calculateWeightedConservationRate(
          List<ConservationPlanModel> plans) {
        int totalStudents = 0;
        double weightedSum = 0;

        for (var plan in plans) {
          if (plan.executedRate != null && halagaModel.NumberStudent != null) {
            weightedSum += plan.executedRate! * halagaModel.NumberStudent!;
            totalStudents += halagaModel.NumberStudent!;
          }
        }
        return totalStudents > 0 ? weightedSum / totalStudents : 0;
      }

      final double conservationRate =
          calculateWeightedConservationRate(conservationPlans);

      // جلب آخر خطة تلاوة
      final eltPlanSnapshot = await getData(
          collection: 'EltlawahPlans',
          field: 'ElhalagatID',
          id: halagaModel.halagaID,
          orderByField: 'PlanMonth',
          descending: true,
          limit: 1);
      final double eltRate = eltPlanSnapshot.docs.isNotEmpty
          ? EltlawahPlanModel.fromMap(
                      eltPlanSnapshot.docs.first.data() as Map<String, dynamic>)
                  .executedRate ??
              0
          : 0;

      // جلب آخر خطة دراسات إسلامية
      final islPlanSnapshot = await getData(
          collection: 'IslamicStudies',
          field: 'ElhalagatID',
          id: halagaModel.halagaID,
          orderByField: 'PlanMonth',
          descending: true,
          limit: 1);
      final double islRate = 0;
      // islPlanSnapshot.docs.isNotEmpty
      //     ? IslamicStudiesModel.fromMap(
      //                 islPlanSnapshot.docs.first.data() as Map<String, dynamic>)
      //             .executedRate ??
      //         0
      //     : 0;

      // إنشاء تقرير لكل حلقة
      reports.add(ReportModel(
        '${teacherModel.first_name} ${teacherModel.middle_name} ${teacherModel.last_name}',
        halagaModel.NumberStudent ?? 0,
        eltRate,
        conservationRate,
        islRate,
        halagaModel.Name ?? '',
        '',
        0,
      ));
    }

    return reports;
  }
}

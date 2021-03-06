enum PlanId {
  p50,
  p30,
}

class _PlanData {
  int gb;
  int totalDays;
  PlanId planId;

  _PlanData(this.gb, this.totalDays, this.planId);
}

class PlanData extends _PlanData {
  String label;

  PlanData(int gb, int totalDays, PlanId planId, this.label) : super(gb, totalDays, planId);
}

List<PlanData> plans = [
  _PlanData(50, 28, PlanId.p50),
  _PlanData(30, 28, PlanId.p30),
].map((plan) => PlanData(plan.gb, plan.totalDays, plan.planId, "${plan.gb}Gb Pre-Paid | ${plan.totalDays} days")).toList();

class MobileDataFormFields {
  DateTime startDate;
  PlanData plan;
  int spentDataMb;

  MobileDataFormFields(this.startDate, this.plan, this.spentDataMb);

  @override
  String toString() {
    return "${plan.label}, $spentDataMb, $startDate";
  }
}

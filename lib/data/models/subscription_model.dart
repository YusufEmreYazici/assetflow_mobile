class Subscription {
  final String id;
  final String serviceName;
  final String? provider;
  final String billingCycle;
  final String billingCycleName;
  final double monthlyCost;
  final double effectiveAnnualCost;
  final String? nextRenewalDate;
  final bool autoRenew;
  final String subscriptionStatus;
  final String subscriptionStatusName;
  final String? costCenter;
  final String currency;
  final String? notes;
  final int? daysUntilRenewal;
  final bool isRenewingSoon;
  final String createdAt;

  const Subscription({
    required this.id,
    required this.serviceName,
    this.provider,
    required this.billingCycle,
    required this.billingCycleName,
    required this.monthlyCost,
    required this.effectiveAnnualCost,
    this.nextRenewalDate,
    required this.autoRenew,
    required this.subscriptionStatus,
    required this.subscriptionStatusName,
    this.costCenter,
    required this.currency,
    this.notes,
    this.daysUntilRenewal,
    required this.isRenewingSoon,
    required this.createdAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        serviceName: json['serviceName'] as String,
        provider: json['provider'] as String?,
        billingCycle: json['billingCycle'] as String,
        billingCycleName: json['billingCycleName'] as String? ?? json['billingCycle'] as String,
        monthlyCost: (json['monthlyCost'] as num).toDouble(),
        effectiveAnnualCost: (json['effectiveAnnualCost'] as num).toDouble(),
        nextRenewalDate: json['nextRenewalDate'] as String?,
        autoRenew: json['autoRenew'] as bool? ?? false,
        subscriptionStatus: json['subscriptionStatus'] as String,
        subscriptionStatusName: json['subscriptionStatusName'] as String? ?? json['subscriptionStatus'] as String,
        costCenter: json['costCenter'] as String?,
        currency: json['currency'] as String? ?? 'TRY',
        notes: json['notes'] as String?,
        daysUntilRenewal: json['daysUntilRenewal'] as int?,
        isRenewingSoon: json['isRenewingSoon'] as bool? ?? false,
        createdAt: json['createdAt'] as String,
      );
}

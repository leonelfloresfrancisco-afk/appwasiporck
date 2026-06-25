import 'package:flutter/foundation.dart';

class DashboardState {
  final int totalAnimalsActive;

  final int totalBatchesActive;

  final double totalStockFeedKg;

  final double netProfitMonthly;

  final double marginPercentageMonthly;

  final List<dynamic> unresolvedAlerts;

  final bool isLoading;

  final String? errorMessage;

  const DashboardState({
    required this.totalAnimalsActive,
    required this.totalBatchesActive,
    required this.totalStockFeedKg,
    required this.netProfitMonthly,
    required this.marginPercentageMonthly,
    required this.unresolvedAlerts,
    required this.isLoading,
    required this.errorMessage,
  });

  factory DashboardState.initial() {
    return const DashboardState(
      totalAnimalsActive: 0,
      totalBatchesActive: 0,
      totalStockFeedKg: 0.00,
      netProfitMonthly: 0.00,
      marginPercentageMonthly: 0.00,
      unresolvedAlerts: [],
      isLoading: true,
      errorMessage: null,
    );
  }

  DashboardState copyWith({
    int? totalAnimalsActive,
    int? totalBatchesActive,
    double? totalStockFeedKg,
    double? netProfitMonthly,
    double? marginPercentageMonthly,
    List<dynamic>? unresolvedAlerts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      totalAnimalsActive: totalAnimalsActive ?? this.totalAnimalsActive,
      totalBatchesActive: totalBatchesActive ?? this.totalBatchesActive,
      totalStockFeedKg: totalStockFeedKg ?? this.totalStockFeedKg,
      netProfitMonthly: netProfitMonthly ?? this.netProfitMonthly,
      marginPercentageMonthly:
          marginPercentageMonthly ?? this.marginPercentageMonthly,
      unresolvedAlerts: unresolvedAlerts ?? this.unresolvedAlerts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return '''
DashboardState(
totalAnimalsActive: $totalAnimalsActive,
totalBatchesActive: $totalBatchesActive,
totalStockFeedKg: $totalStockFeedKg,
netProfitMonthly: $netProfitMonthly,
marginPercentageMonthly: $marginPercentageMonthly,
unresolvedAlerts: ${unresolvedAlerts.length},
isLoading: $isLoading,
errorMessage: $errorMessage
)
''';
  }
}

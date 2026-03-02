import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../domain/repositories/emi_repository.dart';
import '../../domain/entities/emi_schedule_item.dart';
import '../../domain/use_cases/emi/get_emi_schedule_use_case.dart';
import '../../core/utils/date_formatter.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as error_widget;

/// EMI Schedule screen
class EmiScheduleScreen extends StatefulWidget {
  const EmiScheduleScreen({super.key});

  @override
  State<EmiScheduleScreen> createState() => _EmiScheduleScreenState();
}

class _EmiScheduleScreenState extends State<EmiScheduleScreen> {
  bool _isLoading = true;
  List<EmiScheduleItem>? _schedule;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = GetEmiScheduleUseCase(sl<EmiRepository>());
    final result = await useCase.call();

    setState(() {
      _isLoading = false;
      if (result.failure != null) {
        _errorMessage = result.failure!.message;
      } else {
        _schedule = result.schedule ?? [];
      }
    });
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'paid':
        return Theme.of(context).colorScheme.primaryContainer;
      case 'overdue':
        return Theme.of(context).colorScheme.errorContainer;
      case 'pending':
        return Colors.amber.withValues(alpha: 0.2);
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Color _getStatusTextColor(BuildContext context, String status) {
    switch (status) {
      case 'paid':
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case 'overdue':
        return Theme.of(context).colorScheme.onErrorContainer;
      case 'pending':
        return Colors.amber.shade700;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.emiSchedule),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _errorMessage != null
              ? error_widget.ErrorDisplayWidget(
                  message: _errorMessage!,
                  onRetry: _loadSchedule,
                )
              : _schedule == null || _schedule!.isEmpty
                  ? Center(
                      child: Text(
                        'No schedule available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSchedule,
                      child: ListView.builder(
                        itemCount: _schedule!.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final item = _schedule![index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(context, item.status),
                                child: Text(
                                  '${item.installmentNumber}',
                                  style: TextStyle(
                                    color: _getStatusTextColor(context, item.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                currencyFormat.format(item.amount),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Due: ${DateFormatter.formatDate(item.dueDate)}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (item.paidDate != null)
                                    Text(
                                      'Paid: ${DateFormatter.formatDate(item.paidDate!)}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(
                                  item.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getStatusTextColor(context, item.status),
                                  ),
                                ),
                                backgroundColor: _getStatusColor(context, item.status),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

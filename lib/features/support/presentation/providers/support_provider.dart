import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/support_remote_data_source.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/models/support_ticket_model.dart';
import '../../domain/repositories/support_repository.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SupportRemoteDataSourceImpl(apiClient);
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final remoteDataSource = ref.watch(supportRemoteDataSourceProvider);
  return SupportRepositoryImpl(remoteDataSource: remoteDataSource);
});

final customerTicketsProvider = FutureProvider<List<SupportTicketModel>>((ref) async {
  final repo = ref.watch(supportRepositoryProvider);
  return await repo.getCustomerTickets();
});

final supportTicketDetailProvider =
    FutureProvider.family<SupportTicketModel, String>((ref, ticketUuid) async {
  final repo = ref.watch(supportRepositoryProvider);
  return await repo.getTicketDetails(ticketUuid);
});

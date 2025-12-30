import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/transfer_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/transfers_repository.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'read_transfers_state.dart';

enum TransferFilterType { sent, received }

class ReadTransfersCubit extends Cubit<ReadTransfersState> {
  ReadTransfersCubit({required this.transfersRepository}) : super(ReadTransfersInitial());

  final TransfersRepository transfersRepository;

  List<TransferInDb> _cache = [];
  bool isLastPage = false;
  TransferFilterType? _currentFilterType;

  TransferQueryParams _buildParams({int offset = 0}) {
    final currentBranchId = BranchesTool.getCurrentBranchId();
    String? origin;
    String? destination;

    if (_currentFilterType == TransferFilterType.sent) {
      origin = currentBranchId;
    } else {
      destination = currentBranchId;
    }

    return TransferQueryParams(
      offset: offset,
      limit: 50,
      origin: origin,
      destination: destination,
    );
  }

  Future<void> loadPaginatedTransfers() async {
    emit(ReadTransfersLoading());
    try {
      _cache.clear();
      isLastPage = false;
      final params = _buildParams(offset: 0);
      final response = await transfersRepository.getAllTransfers(params);

      _cache = response;
      if (response.length < 50) {
        isLastPage = true;
      }

      if (isClosed) return;

      emit(ReadTransfersSuccess(_cache, _cache.length));
    } catch (e) {
      if (isClosed) return;

      emit(ReadTransfersError(e.toString()));
    }
  }

  Future<void> getNextPage() async {
    if (isLastPage) return;
    try {
      final params = _buildParams(offset: _cache.length);
      final response = await transfersRepository.getAllTransfers(params);

      _cache.addAll(response);
      if (response.length < 50) {
        isLastPage = true;
      }
      if (isClosed) return;

      emit(ReadTransfersSuccess(_cache, _cache.length));
    } catch (e) {
      // Silent error or notify? for pagination usually silent or snackbar
    }
  }

  void setFilterType(TransferFilterType type) {
    if (_currentFilterType == type) return;
    _currentFilterType = type;
    loadPaginatedTransfers();
  }

  TransferFilterType? get currentFilterType => _currentFilterType;
}

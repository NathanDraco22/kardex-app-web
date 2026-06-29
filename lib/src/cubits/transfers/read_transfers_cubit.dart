import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_transfers_state.dart';

enum TransferFilterType { sent, received }

class ReadTransfersCubit extends Cubit<ReadTransfersState> {
  ReadTransfersCubit({required this.transfersRepository}) : super(ReadTransfersInitial());

  final TransfersRepository transfersRepository;

  List<TransferInDb> _cache = [];
  bool isLastPage = false;
  TransferFilterType? _currentFilterType;

  TransferQueryParams _buildParams(String branchId, {int offset = 0}) {
    String? origin;
    String? destination;

    if (_currentFilterType == TransferFilterType.sent) {
      origin = branchId;
    } else {
      destination = branchId;
    }

    return TransferQueryParams(
      offset: offset,
      limit: 50,
      origin: origin,
      destination: destination,
    );
  }

  Future<void> loadPaginatedTransfers(String branchId) async {
    emit(ReadTransfersLoading());
    try {
      _cache.clear();
      isLastPage = false;
      final params = _buildParams(branchId, offset: 0);
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

  Future<void> getNextPage(String branchId) async {
    if (isLastPage) return;
    try {
      final params = _buildParams(branchId, offset: _cache.length);
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

  void setFilterType(TransferFilterType type, String branchId) {
    if (_currentFilterType == type) return;
    _currentFilterType = type;
    loadPaginatedTransfers(branchId);
  }

  TransferFilterType? get currentFilterType => _currentFilterType;
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/entry_history/entry_history_model.dart';
import 'package:kardex_app_front/src/domain/repositories/entry_histories_repository.dart';

part 'read_product_entry_history_state.dart';

class ReadProductEntryHistoryCubit extends Cubit<ReadProductEntryHistoryState> {
  final EntryHistoriesRepository entryHistoriesRepository;

  ReadProductEntryHistoryCubit({required this.entryHistoriesRepository})
      : super(ReadProductEntryHistoryInitial());

  Future<void> loadEntryHistory({required ProductInDb product}) async {
    emit(ReadProductEntryHistoryLoading());
    try {
      final response = await entryHistoriesRepository.getEntryDocsByProductId(product.id);
      emit(ReadProductEntryHistorySuccess(response.data, product));
    } catch (e) {
      emit(ReadProductEntryHistoryError(e.toString()));
    }
  }
}

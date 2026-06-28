import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_product_sale_profile_state.dart';

class WriteProductSaleProfileCubit extends Cubit<WriteProductSaleProfileState> {
  WriteProductSaleProfileCubit({required this.profilesRepository}) : super(WriteProductSaleProfileInitial());

  final ProductSaleProfilesRepository profilesRepository;

  Future<void> updateProfile(String branchId, String productId, UpdateProductSaleProfile updateProfile) async {
    emit(WriteProductSaleProfileInProgress());
    try {
      final profile = await profilesRepository.updateProductSaleProfileByProductId(productId, updateProfile, branchId);
      emit(WriteProductSaleProfileSuccess(profile!));
      emit(WriteProductSaleProfileInitial());
    } catch (error) {
      emit(WriteProductSaleProfileError(error.toString()));
    }
  }
}

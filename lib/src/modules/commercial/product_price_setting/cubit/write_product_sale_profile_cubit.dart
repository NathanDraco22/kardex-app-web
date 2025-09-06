import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';
import 'package:kardex_app_front/src/domain/repositories/product_sale_profile_repository.dart';

part 'write_product_sale_profile_state.dart';

class WriteProductSaleProfileCubit extends Cubit<WriteProductSaleProfileState> {
  WriteProductSaleProfileCubit({required this.profilesRepository}) : super(WriteProductSaleProfileInitial());

  final ProductSaleProfilesRepository profilesRepository;

  Future<void> updateProfile(String productId, UpdateProductSaleProfile updateProfile) async {
    emit(WriteProductSaleProfileInProgress());
    try {
      final profile = await profilesRepository.updateProductSaleProfileByProductId(productId, updateProfile);
      emit(WriteProductSaleProfileSuccess(profile!));
      emit(WriteProductSaleProfileInitial());
    } catch (error) {
      emit(WriteProductSaleProfileError(error.toString()));
    }
  }
}

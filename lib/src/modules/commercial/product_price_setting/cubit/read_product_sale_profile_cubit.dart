import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_product_sale_profile_state.dart';

class ReadProductSaleProfileCubit extends Cubit<ReadProductSaleProfileState> {
  ReadProductSaleProfileCubit({required this.profilesRepository}) : super(ReadProductSaleProfileInitial());

  final ProductSaleProfilesRepository profilesRepository;
  List<ProductSaleProfileInDbWithProduct> _profilesCache = [];

  Future<void> loadCurrentBranchProfiles(String branchId) async {
    emit(ReadProductSaleProfileLoading());
    try {
      final profiles = await profilesRepository.getAllProductSaleProfilesCurrentBranch(branchId);
      _profilesCache = profiles;
      if (isClosed) return;
      emit(ReadProductSaleProfileSuccess(profiles));
    } catch (error) {
      if (isClosed) return;
      emit(ReadProductSaleProfileError(error.toString()));
    }
  }

  void searchProfile(String keyword) {
    if (state is! ReadProductSaleProfileSuccess) return;
    final currentState = state as ReadProductSaleProfileSuccess;
    if (keyword.isEmpty) {
      if (currentState is HighlightedProductSaleProfile) {
        emit(currentState.copyWith(profiles: _profilesCache));
        return;
      }
      emit(ReadProductSaleProfileSuccess(_profilesCache));
      return;
    }
    final filteredList = _profilesCache.where((profile) {
      return profile.product.name.toLowerCase().contains(keyword.toLowerCase());
    }).toList();

    if (currentState is HighlightedProductSaleProfile) {
      emit(currentState.copyWith(profiles: filteredList));
      return;
    }

    emit(ReadProductSaleProfileSuccess(filteredList));
  }

  Future<void> markProductUpdated(ProductSaleProfileInDb profile) async {
    final currentState = state;
    if (currentState is! ReadProductSaleProfileSuccess) return;

    // Actualiza la caché interna
    final index = _profilesCache.indexWhere(
      (p) => p.productId == profile.productId && p.branchId == profile.branchId,
    );
    if (index == -1) return;

    final updateProfile = _profilesCache[index];
    _profilesCache[index] = updateProfile.copyWith(
      salePrice: profile.salePrice,
      discounts: profile.discounts,
    );

    final currentStateIndex = currentState.profiles.indexWhere(
      (p) => p.productId == profile.productId && p.branchId == profile.branchId,
    );
    if (currentStateIndex == -1) return;

    final currentStateProfile = currentState.profiles[currentStateIndex];
    currentState.profiles[currentStateIndex] = currentStateProfile.copyWith(
      salePrice: profile.salePrice,
      discounts: profile.discounts,
    );

    final freshList = currentState.profiles;
    List<ProductSaleProfileInDbWithProduct> updatedList = [];

    if (currentState is HighlightedProductSaleProfile) {
      updatedList = [...currentState.updatedProfiles, updateProfile];
    } else {
      updatedList = [updateProfile];
    }

    emit(
      HighlightedProductSaleProfile(
        freshList,
        updatedProfiles: updatedList,
      ),
    );
  }

  Future<void> refreshProfile() async {
    final currentState = state;
    if (currentState is! ReadProductSaleProfileSuccess) return;

    final freshList = _profilesCache;
    emit(ReadProductSaleProfileSuccess(freshList));
  }
}

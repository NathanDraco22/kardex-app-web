part of 'read_product_sale_profile_cubit.dart';

sealed class ReadProductSaleProfileState {}

final class ReadProductSaleProfileInitial extends ReadProductSaleProfileState {}

final class ReadProductSaleProfileLoading extends ReadProductSaleProfileState {}

class ReadProductSaleProfileSuccess extends ReadProductSaleProfileState {
  final List<ProductSaleProfileInDbWithProduct> profiles;
  ReadProductSaleProfileSuccess(this.profiles);
}

// Estado para resaltar perfiles actualizados
class HighlightedProductSaleProfile extends ReadProductSaleProfileSuccess {
  final List<ProductSaleProfileInDbWithProduct> updatedProfiles;

  HighlightedProductSaleProfile(
    super.profiles, {
    this.updatedProfiles = const [],
  });

  HighlightedProductSaleProfile copyWith({
    List<ProductSaleProfileInDbWithProduct>? profiles,
    List<ProductSaleProfileInDbWithProduct>? updatedProfiles,
  }) {
    return HighlightedProductSaleProfile(
      profiles ?? this.profiles,
      updatedProfiles: updatedProfiles ?? this.updatedProfiles,
    );
  }
}

final class ReadProductSaleProfileError extends ReadProductSaleProfileState {
  final String message;
  ReadProductSaleProfileError(this.message);
}

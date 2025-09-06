part of 'write_product_sale_profile_cubit.dart';

sealed class WriteProductSaleProfileState {}

final class WriteProductSaleProfileInitial extends WriteProductSaleProfileState {}

final class WriteProductSaleProfileInProgress extends WriteProductSaleProfileState {}

final class WriteProductSaleProfileSuccess extends WriteProductSaleProfileState {
  final ProductSaleProfileInDb profile;
  WriteProductSaleProfileSuccess(this.profile);
}

final class WriteProductSaleProfileError extends WriteProductSaleProfileState {
  final String error;
  WriteProductSaleProfileError(this.error);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_order_state.dart';

class WriteOrderCubit extends Cubit<WriteOrderState> {
  WriteOrderCubit({required this.ordersRepository}) : super(WriteOrderInitial());

  final OrdersRepository ordersRepository;

  Future<void> createNewOrder(CreateOrder createOrder) async {
    emit(WriteOrderInProgress());
    try {
      final order = await ordersRepository.createOrder(createOrder);
      emit(WriteOrderSuccess(order));
      emit(WriteOrderInitial());
    } catch (error) {
      emit(WriteOrderError(error.toString()));
    }
  }

  Future<void> updateOrder(String orderId, UpdateOrder updateOrder) async {
    emit(WriteOrderInProgress());
    try {
      final order = await ordersRepository.updateOrderById(orderId, updateOrder);
      emit(WriteOrderSuccess(order!));
      emit(WriteOrderInitial());
    } catch (error) {
      emit(WriteOrderError(error.toString()));
    }
  }

  Future<void> convertOrderToInvoice(String orderId) async {
    emit(WriteOrderInProgress());
    try {
      final res = await ordersRepository.convertOrderToInvoice(orderId);

      if (res == null) {
        throw "Error al generar la factura";
      }

      emit(WriteOrderToInvoiceSuccess(res.invoice, res.order));
      emit(WriteOrderInitial());
    } catch (error) {
      emit(WriteOrderError(error.toString()));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    emit(WriteOrderInProgress());
    try {
      final order = await ordersRepository.cancelOrderById(orderId);
      emit(WriteOrderSuccess(order!));
      emit(WriteOrderInitial());
    } catch (error) {
      emit(WriteOrderError(error.toString()));
    }
  }

  Future<void> deleteOrderDraft(String orderId) async {
    emit(WriteOrderInProgress());
    try {
      final order = await ordersRepository.deleteOrderDraft(orderId);
      emit(WriteOrderDraftDeleted(order));
      emit(WriteOrderInitial());
    } catch (error) {
      emit(WriteOrderError(error.toString()));
    }
  }
}

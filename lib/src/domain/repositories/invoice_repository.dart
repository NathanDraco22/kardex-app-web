import 'package:kardex_app_front/constants/default_values.dart';
import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/models/common/product_sale_total.dart';
import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/responses/invoice_devolution_response.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class InvoicesRepository {
  final InvoicesDataSource invoicesDataSource;
  final InvoiceDevolutionsDataSource invoiceDevolutionsDataSource;

  InvoicesRepository(this.invoicesDataSource, this.invoiceDevolutionsDataSource);

  Future<InvoiceInDb> createInvoice(CreateInvoice createInvoice) async {
    late Map<String, dynamic> result;

    if (createInvoice.clientId == kSaleClientId) {
      result = await invoicesDataSource.createAnonInvoice(createInvoice.toJson());
    } else {
      result = await invoicesDataSource.createInvoice(createInvoice.toJson());
    }
    final invoice = result["invoice"];
    return InvoiceInDb.fromJson(invoice);
  }

  Future<ListResponse<InvoiceInDb>> getAllInvoices(InvoiceQueryParams params) async {
    final res = await invoicesDataSource.getAllInvoices(params.toMap());
    final result = ListResponse<InvoiceInDb>.fromJson(res, InvoiceInDb.fromJson);
    return result;
  }

  Future<ListResponse<InvoiceInDb>> getInvoicesByClientId(String clientId) async {
    final res = await invoicesDataSource.getInvoicesByClientId(clientId);
    final result = ListResponse<InvoiceInDb>.fromJson(res, InvoiceInDb.fromJson);
    return result;
  }

  Future<ListResponse<InvoiceInDb>> getPendingInvoices(String clientId) async {
    final res = await invoicesDataSource.getPendingInvoices(clientId);
    final result = ListResponse<InvoiceInDb>.fromJson(res, InvoiceInDb.fromJson);
    return result;
  }

  Future<ListResponse<InvoiceInDb>> getPaidInvoices({
    String? clientId,
    int? startDate,
    int? endDate,
    String? userCreatorId,
    required int offset,
  }) async {
    final res = await invoicesDataSource.getPaidInvoices(
      clientId: clientId,
      startDate: startDate,
      endDate: endDate,
      userCreatorId: userCreatorId,
      offset: offset,
    );
    final result = ListResponse<InvoiceInDb>.fromJson(res, InvoiceInDb.fromJson);
    return result;
  }

  Future<InvoiceTotals> getTotalFromPaidInvoices({
    String? clientId,
    int? startDate,
    int? endDate,
    String? userCreatorId,
  }) async {
    final res = await invoicesDataSource.getTotalFromPaidInvoices(
      clientId: clientId,
      startDate: startDate,
      endDate: endDate,
      userCreatorId: userCreatorId,
    );
    final result = InvoiceTotals.fromJson(res);
    return result;
  }

  Future<ListResponse<InvoiceInDb>> getClientInvoices({
    String? clientId,
    int? startDate,
    int? endDate,
    required int offset,
  }) async {
    final res = await invoicesDataSource.getClientInvoices(
      clientId: clientId,
      startDate: startDate,
      endDate: endDate,
      offset: offset,
    );
    final result = ListResponse<InvoiceInDb>.fromJson(res, InvoiceInDb.fromJson);
    return result;
  }

  Future<InvoiceTotals> getTotalFromInvoices(InvoiceQueryParams params) async {
    final res = await invoicesDataSource.getTotalFromClientInvoices(params.toMap());
    final result = InvoiceTotals.fromJson(res);
    return result;
  }

  Future<List<ProductSalesTotal>> getAllProductSales(InvoiceQueryParams params) async {
    final res = await invoicesDataSource.getAllProductSales(params.toMap());
    final result = ListResponse<ProductSalesTotal>.fromJson(res, ProductSalesTotal.fromJson);
    return result.data;
  }

  Future<InvoiceInDb?> getInvoiceById(String invoiceId) async {
    final result = await invoicesDataSource.getInvoiceById(invoiceId);
    if (result == null) return null;
    return InvoiceInDb.fromJson(result);
  }

  Future<InvoiceInDb?> updateInvoiceById(
    String invoiceId,
    UpdateInvoice invoice,
  ) async {
    final result = await invoicesDataSource.updateInvoiceById(invoiceId, invoice.toJson());
    if (result == null) return null;
    return InvoiceInDb.fromJson(result);
  }

  Future<List<InvoiceInDb>> getInvoicesHistory(InvoiceQueryParams params) async {
    final res = await invoicesDataSource.getInvoicesHistory(params.toMap());
    final result = ListResponse<InvoiceInDb>.fromJson(res, InvoiceInDb.fromJson);
    return result.data;
  }

  Future<InvoiceInDb> getInvoiceByDocNumber(String docNumber) async {
    final result = await invoicesDataSource.getInvoiceByDocNumber(docNumber);
    return InvoiceInDb.fromJson(result);
  }

  Future<InvoiceDevolutionResponse> getAnonInvoiceDevolutionByDocNumber(String docNumber) async {
    final result = await invoiceDevolutionsDataSource.getAnonInvoicesWithDevlutions(docNumber);
    return InvoiceDevolutionResponse.fromJson(result);
  }
}

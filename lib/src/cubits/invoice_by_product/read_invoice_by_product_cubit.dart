import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_invoice_by_product_state.dart';

class ReadInvoiceByProductCubit extends Cubit<ReadInvoiceByProductState> {
  ReadInvoiceByProductCubit({
    required this.invoicesRepository,
    this.defaultCreatorId,
  }) : super(ReadInvoiceByProductInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    endDate = todayMidnight;
    userCreatorId = defaultCreatorId;
  }

  String? defaultCreatorId;
  DateTime? startDate;
  DateTime? endDate;
  String? userCreatorId;
  String? clientId;
  String? productId;

  String? _branchId;
  bool _isLastPage = false;
  int _requestGeneration = 0;
  InvoiceQueryParams? _lastLoadedParams;

  final InvoicesRepository invoicesRepository;

  DateTime? _endOfDay(DateTime? date) {
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  InvoiceQueryParams _buildParams({int offset = 0}) {
    return InvoiceQueryParams()
      ..branchId = _branchId
      ..clientId = clientId
      ..startDate = startDate
      ..endDate = _endOfDay(endDate)
      ..createdBy = defaultCreatorId ?? userCreatorId
      ..offset = offset;
  }

  InvoiceQueryParams _copyParams(
    InvoiceQueryParams base, {
    required int offset,
    int? limit,
    int? cursorDate,
    String? cursorId,
  }) {
    return InvoiceQueryParams()
      ..branchId = base.branchId
      ..clientId = base.clientId
      ..startDate = base.startDate
      ..endDate = base.endDate
      ..createdBy = base.createdBy
      ..offset = offset
      ..limit = limit ?? base.limit
      ..cursorDate = cursorDate
      ..cursorId = cursorId;
  }

  bool _isStale(int generation) => isClosed || generation != _requestGeneration;

  Future<void> loadInvoicesByProduct({
    required String productId,
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
    String? userCreatorId,
    String? clientId,
    bool clearUserCreator = false,
    bool clearClient = false,
  }) async {
    final generation = ++_requestGeneration;

    emit(ReadInvoiceByProductLoading());
    this.productId = productId;
    _branchId = branchId;

    if (startDate != null) {
      this.startDate = startDate;
    }
    if (endDate != null) {
      this.endDate = endDate;
    }

    if (defaultCreatorId == null) {
      if (clearUserCreator) {
        this.userCreatorId = null;
      } else if (userCreatorId != null) {
        this.userCreatorId = userCreatorId;
      }
    } else {
      this.userCreatorId = defaultCreatorId;
    }

    if (clearClient) {
      this.clientId = null;
    } else if (clientId != null) {
      this.clientId = clientId;
    }

    _isLastPage = false;
    final params = _buildParams();
    _lastLoadedParams = params;

    try {
      final responses = await Future.wait<Object>([
        invoicesRepository.getInvoicesByProduct(productId, params),
        invoicesRepository.getProductSalesSummary(productId, params),
      ]);

      if (_isStale(generation)) return;

      final listResponse = responses[0] as ListResponse<InvoiceInDb>;
      final summary = responses[1] as ProductSalesSummary;
      final invoices = listResponse.data;

      _isLastPage = invoices.length < params.limit;

      emit(
        ReadInvoiceByProductSuccess(
          invoices: invoices,
          summary: summary,
          count: summary.invoiceCount,
          startDate: params.startDate,
          endDate: params.endDate,
          clientId: params.clientId,
          userCreatorId: params.createdBy,
        ),
      );
    } catch (error) {
      if (_isStale(generation)) return;
      emit(ReadInvoiceByProductError(error.toString()));
    }
  }

  Future<void> nextPage() async {
    final currentState = state;
    if (_isLastPage) return;
    if (currentState is FetchingNextPageInvoiceByProduct) return;
    if (currentState is! ReadInvoiceByProductSuccess) return;
    if (productId == null || currentState.invoices.isEmpty) return;

    final baseParams = _lastLoadedParams;
    if (baseParams == null) return;

    final generation = _requestGeneration;
    final lastInvoice = currentState.invoices.last;

    try {
      emit(
        FetchingNextPageInvoiceByProduct(
          invoices: currentState.invoices,
          summary: currentState.summary,
          count: currentState.count,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          clientId: currentState.clientId,
          userCreatorId: currentState.userCreatorId,
        ),
      );

      final params = _copyParams(
        baseParams,
        offset: 0,
        cursorDate: lastInvoice.createdAt.millisecondsSinceEpoch,
        cursorId: lastInvoice.id,
      );
      final listResponse = await invoicesRepository.getInvoicesByProduct(
        productId!,
        params,
      );

      if (_isStale(generation)) return;

      final invoices = listResponse.data;
      _isLastPage = invoices.length < params.limit;

      emit(
        ReadInvoiceByProductSuccess(
          invoices: [...currentState.invoices, ...invoices],
          summary: currentState.summary,
          count: currentState.count,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          clientId: currentState.clientId,
          userCreatorId: currentState.userCreatorId,
        ),
      );
    } catch (error) {
      if (_isStale(generation)) return;

      emit(
        ReadInvoiceByProductLoadMoreError(
          invoices: currentState.invoices,
          summary: currentState.summary,
          count: currentState.count,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          clientId: currentState.clientId,
          userCreatorId: currentState.userCreatorId,
          message: error.toString(),
        ),
      );
    }
  }

  void resetResults() {
    if (isClosed) return;
    _requestGeneration++;
    _isLastPage = false;
    _lastLoadedParams = null;
    emit(ReadInvoiceByProductInitial());
  }

  Future<List<InvoiceInDb>> fetchAllInvoicesForExport() async {
    if (isClosed) {
      throw StateError('El módulo se cerró durante la exportación.');
    }

    final currentProductId = productId;
    final baseParams = _lastLoadedParams;
    if (currentProductId == null || baseParams == null) {
      throw StateError('No hay una consulta aplicada para exportar.');
    }

    final generation = _requestGeneration;
    const pageLimit = 200;
    final uniqueInvoices = <String, InvoiceInDb>{};
    var params = _copyParams(baseParams, offset: 0, limit: pageLimit);

    while (true) {
      final response = await invoicesRepository.getInvoicesByProduct(
        currentProductId,
        params,
      );

      if (_isStale(generation)) {
        throw StateError('La consulta cambió durante la exportación.');
      }

      for (final invoice in response.data) {
        uniqueInvoices[invoice.id] = invoice;
      }

      if (response.data.length < pageLimit) break;

      final lastInvoice = response.data.last;
      params = _copyParams(
        baseParams,
        offset: 0,
        limit: pageLimit,
        cursorDate: lastInvoice.createdAt.millisecondsSinceEpoch,
        cursorId: lastInvoice.id,
      );
    }

    return uniqueInvoices.values.toList();
  }

  void clearFilters(String branchId) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    endDate = todayMidnight;
    userCreatorId = defaultCreatorId;
    clientId = null;
    productId = null;
    _branchId = branchId;
    resetResults();
  }
}

import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ProductSaleProfilesDataSource with HttpService {
  ProductSaleProfilesDataSource._();
  static final ProductSaleProfilesDataSource instance = ProductSaleProfilesDataSource._();
  factory ProductSaleProfilesDataSource() {
    return instance;
  }

  final _endpoint = "/product-sale-profiles";

  Future<Map<String, dynamic>> createProductSaleProfile(Map<String, dynamic> profile) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, profile, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllProductSaleProfilesCurrentBranch() async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      "$_endpoint/$currentBranch",
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getProductSaleProfileByProductId(String productId) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      "$_endpoint/$productId",
      queryParameters: {'branchId': currentBranch},
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateProductSaleProfileByProductId(
    String productId,
    Map<String, dynamic> profile,
  ) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri("$_endpoint/$currentBranch/$productId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: profile, headers: headers);
    return res;
  }
}

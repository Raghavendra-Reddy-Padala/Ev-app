import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'package:mjollnir/core/utils/logger.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/transaction/transaction.dart';
import '../../../shared/models/wallet/wallet_models.dart';

class WalletController extends BaseController {
  final Rxn<WalletData> walletData = Rxn<WalletData>();
  final RxList<Transaction> transactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshWalletData();
  }

  // Combined method to refresh all wallet data
  Future<void> refreshWalletData() async {
    await Future.wait([
      fetchWalletBalance(),
      fetchTransactions(),
    ]);
  }

  Future<void> fetchWalletBalance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: ApiConstants.walletGet,
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn',
            },
          );

          if (response != null) {
            // response is already the parsed JSON Map, not a response object with .data
            final balanceResponse = WalletBalanceResponse.fromJson(response);
            walletData.value = balanceResponse.data;
            
            // Force UI update
            walletData.refresh();
            
            AppLogger.i('Wallet balance fetched: ${walletData.value?.balance}');
            AppLogger.i('Raw API balance: ${response['data']['balance']}');
            return true;
          }
          return false;
        },
      );
    } catch (e) {
      AppLogger.e('Error fetching wallet balance: $e');
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.get(
            endpoint: ApiConstants.transactionsGetAll,
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn',
            },
          );

          if (response != null) {
            final transactionsResponse = TransactionResponse.fromJson(response);
            transactions.assignAll(transactionsResponse.transactions);
            AppLogger.i('Transactions fetched: ${transactions.length}');
            return true;
          }
          return false;
        },
      );
    } catch (e) {
      AppLogger.e('Error fetching transactions: $e');
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

 Future<String> topUp(String value) async {
    try {
          final String? authToken = await getToken();
          if (authToken == null) {
      return '';
    }
      
          final response = await apiService.post(
            endpoint: 'wallet/topup',
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn',
            },
            body: {
              "balance": value
            }
          );
          print('Top-up response: $response');
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        return '';
      }
    } catch (e) {

      return '';
    }
  }
  Future<String?> topUpWallet(String amount) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await useApiOrDummy(
        apiCall: () async {
          final String? authToken = await getToken();
          if (authToken == null) {
            throw Exception('Authentication token not found');
          }

          final response = await apiService.post(
            endpoint: 'wallet/topup',
            headers: {
              'Authorization': 'Bearer $authToken',
              'X-Karma-App': 'dafjcnalnsjn',
            },
            body: {
              "balance": amount
            }
          );

          if (response != null) {
            if (response['success'] == true && response['data'] != null) {
              // Refresh wallet balance after successful top-up
              await fetchWalletBalance();
              return response['data'].toString();
            } else {
              throw Exception(response['message'] ?? 'Payment initiation failed');
            }
          }
          throw Exception('No response from server');
        },
      );

      return result;
    } catch (e) {
      AppLogger.e('Error in topUpWallet: $e');
      handleError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Method to manually refresh balance (useful for pull-to-refresh)
  Future<void> onRefresh() async {
    await refreshWalletData();
  }
}
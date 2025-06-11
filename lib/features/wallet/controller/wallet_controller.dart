import 'package:get/get.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import '../../../core/api/base/base_controller.dart';
import '../../../main.dart';
import '../../../shared/models/transaction/transaction.dart';
import '../../../shared/models/wallet/wallet_models.dart';
import '../../../shared/services/dummy_data_service.dart';

class WalletController extends BaseController {
  final Rxn<WalletData> walletData = Rxn<WalletData>();
  final RxList<Transaction> transactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletBalance();
    fetchTransactions();
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
            final balanceResponse =
                WalletBalanceResponse.fromJson(response.data);
            walletData.value = balanceResponse.data;
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getWalletBalanceResponse();
          final balanceResponse = WalletBalanceResponse.fromJson(dummyData);
          walletData.value = balanceResponse.data;
          return true;
        },
      );
    } catch (e) {
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
            final transactionsResponse =
                TransactionResponse.fromJson(response.data);
            transactions.assignAll(transactionsResponse.transactions);
            return true;
          }
          return false;
        },
        dummyData: () {
          final dummyData = DummyDataService.getTransactionsResponse();
          final transactionsResponse = TransactionResponse.fromJson(dummyData);
          transactions.assignAll(transactionsResponse.transactions);
          return true;
        },
      );
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
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

        print("Full API Response: $response"); // Debug print
        print("Response type: ${response.runtimeType}"); // Debug print

        if (response != null) {
          // The response is already the parsed JSON Map, not a response object with .data
          if (response['success'] == true && response['data'] != null) {
            await fetchWalletBalance();
            return response['data'].toString(); // Access directly from the Map
          } else {
            throw Exception(response['message'] ?? 'Payment initiation failed');
          }
        }
        throw Exception('No response from server');
      },
      dummyData: () {
        final dummyData = DummyDataService.getWalletTopupResponse();

        if (walletData.value != null) {
          walletData.value = WalletData(
            userId: walletData.value!.userId,
            balance: walletData.value!.balance + double.parse(amount)
          );
        }
        return dummyData['data']?.toString();
      },
    );

    return result;
  } catch (e) {
    print("Error in topUpWallet: $e"); // Debug print
    handleError(e);
    return null;
  } finally {
    isLoading.value = false;
  }
}

}

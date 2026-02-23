import 'dart:async';
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

  // Billing address state
  final RxBool hasBillingAddress = false.obs;
  final RxMap<String, String> billingAddress = <String, String>{}.obs;

  // Dodo payment state
  final RxString currentPaymentId = ''.obs;
  final RxString currentPaymentStatus = ''.obs;
  Timer? _statusPollTimer;

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

  @override
  void onClose() {
    _statusPollTimer?.cancel();
    super.onClose();
  }

  // ============ Billing Address Methods ============

  Future<void> fetchBillingAddress() async {
    try {
      final String? authToken = await getToken();
      if (authToken == null) return;

      final response = await apiService.get(
        endpoint: ApiConstants.billingAddressGet,
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Karma-App': 'dafjcnalnsjn',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        hasBillingAddress.value = data['has_billing'] ?? false;
        billingAddress.value = {
          'street': data['street']?.toString() ?? '',
          'city': data['city']?.toString() ?? '',
          'state': data['state']?.toString() ?? '',
          'zipcode': data['zipcode']?.toString() ?? '',
          'country': data['country']?.toString() ?? '',
        };
      }
    } catch (e) {
      AppLogger.e('Error fetching billing address: $e');
    }
  }

  Future<bool> updateBillingAddress({
    required String street,
    required String city,
    required String state,
    required String zipcode,
    required String country,
  }) async {
    try {
      isLoading.value = true;
      final String? authToken = await getToken();
      if (authToken == null) return false;

      final response = await apiService.post(
        endpoint: ApiConstants.billingAddressUpdate,
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Karma-App': 'dafjcnalnsjn',
        },
        body: {
          'street': street,
          'city': city,
          'state': state,
          'zipcode': zipcode,
          'country': country,
        },
      );

      if (response != null && response['success'] == true) {
        hasBillingAddress.value = true;
        billingAddress.value = {
          'street': street,
          'city': city,
          'state': state,
          'zipcode': zipcode,
          'country': country,
        };
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('Error updating billing address: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============ Dodo Payment Methods ============

  Future<Map<String, dynamic>?> createDodoPayment(String amount) async {
    try {
      isLoading.value = true;
      final String? authToken = await getToken();
      if (authToken == null) return null;

      final response = await apiService.post(
        endpoint: ApiConstants.dodoCreatePayment,
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Karma-App': 'dafjcnalnsjn',
        },
        body: {
          'amount': amount,
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        currentPaymentId.value = data['payment_id']?.toString() ?? '';
        currentPaymentStatus.value = 'pending';
        return {
          'payment_id': data['payment_id'],
          'checkout_url': data['checkout_url'],
          'amount': data['amount'],
        };
      } else {
        final data = response?['data'];
        if (data != null && data['error_code'] == 'BILLING_ADDRESS_REQUIRED') {
          return {'error': 'BILLING_ADDRESS_REQUIRED'};
        }
        return null;
      }
    } catch (e) {
      AppLogger.e('Error creating Dodo payment: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> checkPaymentStatus(String paymentId) async {
    try {
      final String? authToken = await getToken();
      if (authToken == null) return 'pending';

      final response = await apiService.get(
        endpoint: '${ApiConstants.dodoPaymentStatus}/$paymentId',
        headers: {
          'Authorization': 'Bearer $authToken',
          'X-Karma-App': 'dafjcnalnsjn',
        },
      );

      if (response != null && response['success'] == true) {
        final status = response['data']['status']?.toString() ?? 'pending';
        currentPaymentStatus.value = status;
        return status;
      }
      return 'pending';
    } catch (e) {
      AppLogger.e('Error checking payment status: $e');
      return 'pending';
    }
  }

  void startPollingPaymentStatus(String paymentId, {Function(String)? onStatusChange}) {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final status = await checkPaymentStatus(paymentId);
      if (status == 'success' || status == 'failed' || status == 'cancelled') {
        timer.cancel();
        if (status == 'success') {
          await refreshWalletData();
        }
        onStatusChange?.call(status);
      }
    });
  }

  void stopPollingPaymentStatus() {
    _statusPollTimer?.cancel();
  }
}
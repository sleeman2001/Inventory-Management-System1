import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import '../../database/database_helper.dart';
import '../model/merged_Item.dart';
import 'package:http/http.dart' as http;

class InventoryController extends GetxController {
  var inventoryList = <MergedItem>[].obs;
  var filteredList = <MergedItem>[].obs;
  var isRefreshing = false.obs;
  var hasNetwork = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkNetworkStatus();
    loadLocalData();
    fetchAndMergeData();
  }

  void checkNetworkStatus() async {
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((status) async {
      hasNetwork.value = (status != ConnectivityResult.none);
      if (!hasNetwork.value) {
        Get.snackbar(
          "No Network",
          "You are offline. Showing locally saved data.",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        await loadLocalData();
      }
    });

    final status = await connectivity.checkConnectivity();
    hasNetwork.value = (status != ConnectivityResult.none);
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredList.value = inventoryList;
    } else {
      bool isNumeric = int.tryParse(query) != null;

      if (isNumeric) {
        filteredList.value = inventoryList
            .where((item) => int.tryParse(item.qty) == int.parse(query))
            .toList();
      } else {
        filteredList.value = inventoryList
            .where((item) =>
                item.name.toLowerCase().contains(query.toLowerCase()) ||
                item.itemno.contains(query))
            .toList();
      }
    }
  }

  Future<void> fetchAndMergeData() async {
    if (!hasNetwork.value) {
      await loadLocalData();
      return;
    }

    final itemsUrl =
        "http://173.249.1.117:8095/van.dll/getvanalldata?cono=290&strno=1&case=4";
    final quantitiesUrl =
        "http://173.249.1.117:8095/van.dll/getvanalldata?cono=290&strno=1&case=9";

    isRefreshing.value = true;
    try {
      final itemsResponse = await http.get(Uri.parse(itemsUrl));
      final quantitiesResponse = await http.get(Uri.parse(quantitiesUrl));

      if (itemsResponse.statusCode == 200 &&
          quantitiesResponse.statusCode == 200) {
        final itemsData = json.decode(itemsResponse.body)['Items_Master'];
        final quantitiesData =
            json.decode(quantitiesResponse.body)['SalesMan_Items_Balance'];

        List<MergedItem> mergedData = [];

        for (var item in itemsData) {
          final quantity = quantitiesData.firstWhere(
            (q) => q['ItemOCode'] == item['ITEMNO'],
            orElse: () => {"ItemOCode": "", "STOCK_CODE": "", "QTY": "0"},
          );

          mergedData.add(MergedItem(
            itemno: item['ITEMNO'],
            name: item['NAME'],
            categoryid: item['CATEOGRYID'],
            barcode: item['BARCODE'],
            minprice: item['MINPRICE'],
            stockCode: quantity['STOCK_CODE'],
            qty: quantity['QTY'],
          ));
        }

        await DatabaseHelper().insertData(
          mergedData.map((item) => item.toJson()).toList(),
        );

        inventoryList.value = mergedData;
        filteredList.value = mergedData;
      } else {
        throw Exception(
            "Failed to fetch data. Status Code: ${itemsResponse.statusCode} or ${quantitiesResponse.statusCode}");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch data: $e",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadLocalData() async {
    try {
      final localData = await DatabaseHelper().getInventory();
      List<MergedItem> mergedData = localData.map((item) {
        return MergedItem(
          itemno: item['itemno'],
          name: item['name'],
          categoryid: item['categoryid'],
          barcode: item['barcode'],
          minprice: item['minprice'],
          stockCode: item['stock_code'],
          qty: item['qty'],
        );
      }).toList();

      inventoryList.value = mergedData;
      filteredList.value = mergedData;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load local data: $e",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void sortItemsByQuantity(bool ascending) {
    inventoryList.sort((a, b) {
      int qtyA = int.tryParse(a.qty) ?? 0;
      int qtyB = int.tryParse(b.qty) ?? 0;
      return ascending ? qtyA.compareTo(qtyB) : qtyB.compareTo(qtyA);
    });
    filteredList.value = inventoryList;
  }
}

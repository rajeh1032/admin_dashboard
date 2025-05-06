import 'package:admin_dashboard/core/constants/app_collections.dart';
import 'package:admin_dashboard/core/utils/services/firebase_service.dart';
import 'package:admin_dashboard/enums/order_types.dart';
import 'package:admin_dashboard/models/category/category_model.dart';
import 'package:admin_dashboard/models/order/order_model.dart';
import 'package:admin_dashboard/models/product/product_model.dart';
import 'package:admin_dashboard/screens/orders/order_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderProvider extends ChangeNotifier {
  final _firebaseService = FirebaseFirestoreService();
  final formKey = GlobalKey<FormState>();
  final TextEditingController orderDetailsController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController categoryIdController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  List<OrderModel> filteredOrders = [];
  List<OrderModel> orders = [];
  List<CategoryModel> categories = [];
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProduct = [];
  bool isLoading = false;
  void setState(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearFields() {
    customerNameController.clear();
    customerPhoneController.clear();
    productIdController.clear();
    categoryIdController.clear();
    quantityController.clear();
    statusController.clear();
    priceController.clear();
    orderDetailsController.clear();
    categoryController.clear();
    productController.clear();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await _firebaseService.getCollection(
        collectionId: AppCollections.categories,
      );
      categories = snapshot
          .map((doc) =>
              CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> fetchOrders() async {
    try {
      FirebaseFirestore.instance
          .collection(AppCollections.orders)
          .snapshots()
          .listen((event) {
        orders =
            event.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
        filteredOrders = orders;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firebaseService.getCollection(
        collectionId: AppCollections.products,
      );
      allProducts = snapshot
          .map((doc) =>
              ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  void selectCategory(String categoryId) {
    filteredProduct = allProducts
        .where((product) => product.categoryID == categoryId)
        .toList();
    categoryController.text =
        categories.where((category) => category.id == categoryId).first.name;
    categoryIdController.text = categoryId;
    productController.clear();
    productIdController.clear();
    notifyListeners();
  }

  Future<void> addOrder(BuildContext context) async {
    final order = OrderModel(
      FirebaseFirestore.instance.collection(AppCollections.orders).doc().id,
      customerNameController.text,
      (double.tryParse(priceController.text) ?? 0.0),
      int.tryParse(quantityController.text) ?? 0,
      orderDetailsController.text,
      OrderStatus.processing,
      DateTime.now(),
      productIdController.text,
      categoryIdController.text,
      customerPhoneController.text,
    );
    if (formKey.currentState!.validate()) {
      try {
        await _firebaseService.addDocumentUsingId(
          collectionId: AppCollections.orders,
          documentId: order.orderId,
          data: order.toJson(),
        );
        clearFields();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void searchOrder(String query) {
    if (query == "all") {
      filteredOrders = orders;
      notifyListeners();
      return;
    }
    if (query.isNotEmpty) {
      filteredOrders = orders
          .where((order) =>
              order.status.name.toLowerCase().contains(query.toLowerCase()) ||
              order.customerName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      filteredOrders = orders; // Reset to original list if query is empty
    }
    notifyListeners();
  }

  Future<void> showOrderDialog({
    required BuildContext context,
    required bool isAdding,
    OrderModel? order,
  }) async {
    await showDialog(
      context: context,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: this,
          child: AlertDialog(
            title: Row(
              children: [
                Text(isAdding ? 'Add Order' : 'Edit Order'),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    clearFields();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            content: OrderForm(
              onSubmitted: () async {
                if (categoryController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a category'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (productController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a product'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (statusController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a product status'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (formKey.currentState!.validate()) {
                  if (isAdding) {
                    await addOrder(context);
                  } else {
                    await updateOrder(context, order!);
                  }
                }
              },
              orderModel: order,
            ),
          ),
        );
      },
    );
  }

  void initState(OrderModel? order) {
    if (order == null) return;
    customerNameController.text = order.customerName;
    productIdController.text = order.productId;
    quantityController.text = order.quantity.toString();
    orderDetailsController.text = order.details;
    statusController.text = order.status.name;
    priceController.text = order.price.toString();
    categoryIdController.text = order.categoryId;
    productIdController.text = order.productId;
    customerPhoneController.text = order.phoneNumber;
    productController.text =
        allProducts.firstWhere((product) => product.id == order.productId).name;
    categoryController.text = categories
        .firstWhere((category) => category.id == order.categoryId)
        .name;
  }

  Future<void> updateOrder(BuildContext context, OrderModel oldOrder) async {
    if (formKey.currentState!.validate()) {
      final order = OrderModel(
        oldOrder.orderId,
        customerNameController.text,
        (double.tryParse(priceController.text) ?? 0.0),
        int.tryParse(quantityController.text) ?? 0,
        orderDetailsController.text,
        OrderStatus.values.firstWhere(
          (e) => e.toString() == 'OrderStatus.${statusController.text}',
          orElse: () => OrderStatus.processing,
        ),
        oldOrder.createdAt,
        productIdController.text,
        categoryIdController.text,
        customerPhoneController.text,
      );
      try {
        await _firebaseService.updateDocument(
          collectionId: AppCollections.orders,
          documentId: oldOrder.orderId,
          data: order.toJson(),
        );
        clearFields();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteOrder(BuildContext context, String orderId) async {
    try {
      await _firebaseService.deleteDocument(
        collectionId: AppCollections.orders,
        documentId: orderId,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteOrder(
      {required BuildContext context, required OrderModel order}) async {
    await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: this,
        child: AlertDialog(
          title: const Text('Delete Order'),
          content: const Text('Are you sure you want to delete this Order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(true);
                await _deleteOrder(context, order.orderId);
                setState(false);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    orderDetailsController.dispose();
    customerNameController.dispose();
    productIdController.dispose();
    quantityController.dispose();
    statusController.dispose();
    super.dispose();
  }
}

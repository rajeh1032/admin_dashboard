import 'package:admin_dashboard/enums/order_types.dart';
import 'package:admin_dashboard/models/order/order_model.dart';
import 'package:admin_dashboard/screens/orders/order_provider.dart';
import 'package:admin_dashboard/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({super.key, this.orderModel, required this.onSubmitted});
  final OrderModel? orderModel;
  final VoidCallback onSubmitted;

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  @override
  void initState() {
    super.initState();
    context.read<OrderProvider>().initState(widget.orderModel);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    return Form(
      key: provider.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              child: Row(
                children: [
                  Text(
                    provider.categoryController.text.isNotEmpty
                        ? provider.categoryController.text
                        : 'Select Product Category',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_drop_down,
                  ),
                ],
              ),
              onSelected: (value) {
                provider.selectCategory(value);
              },
              itemBuilder: (context) => [
                ...provider.categories.map(
                  (category) => PopupMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              child: Row(
                children: [
                  Text(
                    provider.productController.text.isNotEmpty
                        ? provider.productController.text
                        : 'Select Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_drop_down,
                  ),
                ],
              ),
              onSelected: (value) {
                provider.productIdController.text = value.toString();
                provider.productController.text = provider.filteredProduct
                    .firstWhere((product) => product.id == value)
                    .name;
                provider.setState(false);
              },
              itemBuilder: (context) => [
                ...provider.filteredProduct.map(
                  (product) => PopupMenuItem(
                    value: product.id,
                    child: Text(product.name),
                  ),
                ),
              ],
            ),
          ),
          CustomTextField(
            labelText: "Customer Name",
            hintText: "Enter Customer Name",
            controller: provider.customerNameController,
          ),
          CustomTextField(
            labelText: "Quantity",
            hintText: "Enter Quantity",
            controller: provider.quantityController,
          ),
          CustomTextField(
            labelText: "Price",
            hintText: "Enter Price",
            controller: provider.priceController,
          ),
          CustomTextField(
            labelText: "Order Details",
            hintText: "Enter Order Details",
            controller: provider.orderDetailsController,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<OrderStatus>(
              child: Row(
                children: [
                  Text(
                    provider.statusController.text.isNotEmpty
                        ? provider.statusController.text
                        : 'Select Order Status',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_drop_down,
                  ),
                ],
              ),
              onSelected: (value) {
                provider.statusController.text = value.name;
                provider.setState(false);
              },
              itemBuilder: (context) => [
                ...OrderStatus.values.map(
                  (status) => PopupMenuItem(
                    value: status,
                    child: Text(status.name),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: widget.onSubmitted,
            child: Text(
              widget.orderModel == null ? 'Add Order' : 'Update Order',
            ),
          ),
        ],
      ),
    );
  }
}

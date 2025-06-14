// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      categoryID: json['categoryID'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$ProductStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'quantity': instance.quantity,
      'imageUrl': instance.imageUrl,
      'categoryID': instance.categoryID,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$ProductStatusEnumMap[instance.status]!,
    };

const _$ProductStatusEnumMap = {
  ProductStatus.outOfStock: 'outOfStock',
  ProductStatus.inStock: 'inStock',
  ProductStatus.fromUser: 'fromUser',
};

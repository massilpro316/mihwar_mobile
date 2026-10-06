import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';

// ─── BLoC ────────────────────────────────────────────────────────────────────

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  final CreateProduct _createProduct;
  final DeleteProduct _deleteProduct;

  ProductBloc({
    required GetProducts getProducts,
    required CreateProduct createProduct,
    required DeleteProduct deleteProduct,
  })  : _getProducts = getProducts,
        _createProduct = createProduct,
        _deleteProduct = deleteProduct,
        super(const ProductState()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<AddProductEvent>(_onAddProduct);
    on<RemoveProductEvent>(_onRemoveProduct);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    final result = await _getProducts(event.stationId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(isLoading: false, products: products)),
    );
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    final result = await _createProduct(event.params);

    result.fold(
      (failure) {
        emit(state.copyWith(isSubmitting: false));
        if (event.context.mounted) {
          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(
                content: Text(failure.message), backgroundColor: Colors.red),
          );
        }
      },
      (product) {
        emit(state.copyWith(
          isSubmitting: false,
          products: [product, ...state.products],
        ));
        if (event.context.mounted) {
          ScaffoldMessenger.of(event.context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
          Navigator.of(event.context).pop();
        }
      },
    );
  }

  Future<void> _onRemoveProduct(
    RemoveProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _deleteProduct(event.id);

    result.fold(
      (failure) {
        if (event.context.mounted) {
          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(
                content: Text(failure.message), backgroundColor: Colors.red),
          );
        }
      },
      (_) {
        emit(state.copyWith(
          products: state.products.where((p) => p.id != event.id).toList(),
        ));
      },
    );
  }
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final int stationId;
  const FetchProductsEvent(this.stationId);
  @override
  List<Object?> get props => [stationId];
}

class AddProductEvent extends ProductEvent {
  final BuildContext context;
  final CreateProductParams params;
  const AddProductEvent({required this.context, required this.params});
}

class RemoveProductEvent extends ProductEvent {
  final BuildContext context;
  final int id;
  const RemoveProductEvent({required this.context, required this.id});
}

// ─── State ───────────────────────────────────────────────────────────────────

class ProductState extends Equatable {
  final List<ProductEntity> products;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasError;
  final String errorMessage;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  ProductState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasError,
    String? errorMessage,
  }) =>
      ProductState(
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        hasError: hasError ?? this.hasError,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [products, isLoading, isSubmitting, hasError, errorMessage];
}

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/domain/auth_route_guard.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

void addCatalogProduct(BuildContext context, HomeProduct product) {
  final session = AuthSessionService.instance;
  final account = session.currentAccount;
  if (!session.isAuthenticated ||
      account == null ||
      !AuthRouteGuard.allowsRole(account, AuthRole.buyer)) {
    return;
  }
  if (!product.canOrder) return;
  BasketController.instance.addProduct(product);
  ScaffoldMessenger.of(context).showAppSnackBar(
    SnackBar(content: Text('${product.name} added to basket.')),
  );
}

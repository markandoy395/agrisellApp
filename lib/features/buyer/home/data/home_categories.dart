import 'package:agresell_app/core/constants/agrisellAssets.dart';
import 'package:agresell_app/features/buyer/home/domain/home_category.dart';
import 'package:agresell_app/features/shared/products/domain/product_categories.dart';

const List<HomeCategory> homeCategories = <HomeCategory>[
  HomeCategory(
    label: ProductCategories.vegetables,
    asset: AgrisellAssets.categoryVegetable,
  ),
  HomeCategory(
    label: ProductCategories.fruits,
    asset: AgrisellAssets.categoryFruits,
  ),
  HomeCategory(
    label: ProductCategories.nuts,
    asset: AgrisellAssets.categoryNuts,
  ),
  HomeCategory(
    label: ProductCategories.fruitTrees,
    asset: AgrisellAssets.categoryFruits,
  ),
  HomeCategory(
    label: ProductCategories.spices,
    asset: AgrisellAssets.categorySpices,
  ),
];

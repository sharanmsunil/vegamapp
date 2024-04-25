import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/models/product_model.dart';
import '../../views/product_views/product_view.dart';
import '../app_colors.dart';
import '../app_style.dart';
import 'buttons.dart';

class ProductsYouMayLikeWidget extends StatelessWidget {
  ProductsYouMayLikeWidget({super.key,required this.suggestedProducts});
  List<dynamic> suggestedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestedProducts.length,
        itemBuilder: (context, index) {
          var productModel =
          Items.fromJson(suggestedProducts[index]);
          // var cartModel = Items.fromJson(cartProducts[index]);
          return InkWell(
            onTap: () => context.push(
                '/${ProductView.route}/${productModel.urlKey}.${productModel.urlSuffix}'),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(color: AppColors.greyBgColor,width: .5),
                    color: AppColors.containerColor
              ),
              child: ListTile(
                leading: Container(
                  color: AppColors.appBarColor,
                  height: 100,
                  width: 50,
                  child: CachedNetworkImage(imageUrl: suggestedProducts[index]
                  ['image']['url'],fit: BoxFit.contain,),
                ),
                // Image(
                //   image: NetworkImage(suggestedProducts[index]['image']['url']),fit: BoxFit.contain,),
                title: Text(suggestedProducts[index]['name'].length > 20
                    ? "${suggestedProducts[index]['name'].substring(0, 20.toInt())}..."
                    : suggestedProducts[index]['name'],
                    style: AppStyles.getMediumTextStyle(
                        fontSize: 12, color: AppColors.fontColor)),
                // subtitle: Text(characters[index]['countries'][index]['code']),
                subtitle: Text(
                  "${suggestedProducts[index]['price_range']['minimum_price']['regular_price']['currency']} ${suggestedProducts[index]['price_range']['minimum_price']['regular_price']['value'].toString()}",
                  style: AppStyles.getLightTextStyle(
                      fontSize: 12,
                      color: AppColors.fontColor),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: BuildButtonSingle(
                      typeName: productModel.sTypename!,
                      width: 400,
                      title: 'ADD TO CART',
                      buttonColor: AppColors.buttonColor,
                      textColor: Colors.white,
                      svg: 'assets/svg/shopping-cart.svg',
                      parentSku: productModel.sku!,
                      selectedSku: productModel
                          .variants?[0].product?.sku!,
                      quantity: 1,
                    ),
                  ),
                  // Container(
                  //   width: 100,
                  //   height: 100,
                  //   decoration: BoxDecoration(
                  //     color: AppColors.buttonColor,
                  //     borderRadius: BorderRadius.all(Radius.circular(5))
                  //   ),
                  //   child: Center(child: Text("ADD TO CART",style: AppStyles.getMediumTextStyle(fontSize: 10,color: Colors.white),)),
                  // ),
                ),
              ),
            ),
          );
        }, ),
    );
  }
}
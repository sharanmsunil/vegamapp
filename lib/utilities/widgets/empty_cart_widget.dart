import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/models/product_model.dart';
import '../../views/product_views/product_view.dart';
import '../app_colors.dart';
import '../app_style.dart';
import 'buttons.dart';

class EmptyCartWidget extends StatelessWidget {
  EmptyCartWidget({super.key,required this.suggestedProducts});
  List<dynamic> suggestedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: suggestedProducts.length,
          itemBuilder: (context, index) {
            var productModel =
            Items.fromJson(suggestedProducts[index]);
            // var cartModel = Items.fromJson(cartProducts[index]);
            return InkWell(
              onTap: () => context.push(
                  '/${ProductView.route}/${productModel.urlKey}.${productModel.urlSuffix}'),
              child: Container(
                height: 200,
                color: AppColors.appBarColor,
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: CachedNetworkImage(imageUrl: suggestedProducts[index]
                      ['image']['url'],fit: BoxFit.contain,),
                    ),
                    const SizedBox(height: 10,),
                    Text(suggestedProducts[index]['name'].length > 20
                        ? "${suggestedProducts[index]['name'].substring(0, 20.toInt())}..."
                        : suggestedProducts[index]['name'],
                        style: AppStyles.getMediumTextStyle(
                            fontSize: 12, color: AppColors.fontColor)),
                    const SizedBox(height: 10,),
                    Text(
                      "${suggestedProducts[index]['price_range']['minimum_price']['regular_price']['currency']} ${suggestedProducts[index]['price_range']['minimum_price']['regular_price']['value'].toString()}",
                      style: AppStyles.getLightTextStyle(
                          fontSize: 12,
                          color: AppColors.fontColor),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}


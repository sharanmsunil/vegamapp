import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:m2/utilities/widgets/quantity_changer_widget.dart';
import '../../services/models/product_model.dart';
import '../../views/product_views/product_view.dart';
import '../app_colors.dart';
import '../app_style.dart';

class ProductsYouMayLikeWidget extends StatefulWidget {
  const ProductsYouMayLikeWidget({super.key,required this.suggestedProducts, required this.data, this.refetch, });
  final List <dynamic> suggestedProducts;
  final Map<String, dynamic> data;
  final VoidCallback? refetch;


  @override
  State<ProductsYouMayLikeWidget> createState() => _ProductsYouMayLikeWidgetState();
}

class _ProductsYouMayLikeWidgetState extends State<ProductsYouMayLikeWidget> {
  double quantity = 1;
  late ProductModel productModel1;
  List<Map<String, dynamic>> originalMedia = [];
  List<Map<String, dynamic>> mediaGallery = [];
  @override
  void initState() {
    // Initialize product model
    productModel1 = ProductModel.fromJson(widget.data['products']);

    // originalMedia = List<Map<String, dynamic>>.from(widget.data['products']['items'][0]['media_gallery']);
    // mediaGallery = originalMedia;
    // if (productModel1.items![0].variants != null && productModel1.items![0].variants!.isNotEmpty) {
    //   mediaGallery = productModel1.items![0].variants![0].product!.mediaGallery!;
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.suggestedProducts.length,
        itemBuilder: (context, index) {
          var productModel =
          Items.fromJson(widget.suggestedProducts[index]);
          // var cartModel = Items.fromJson(cartProducts[index]);
          return InkWell(
            onTap: () => context.push(
                '/${ProductView.route}/${productModel.urlKey}.${productModel.urlSuffix}'),
            child: Container(
              height: 110,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(color: AppColors.greyBgColor,width: .5),
                    color: AppColors.containerColor
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    color: AppColors.appBarColor,
                    height: 100,
                    width: 50,
                    child: CachedNetworkImage(imageUrl: widget.suggestedProducts[index]
                    ['image']['url'],fit: BoxFit.contain,),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(widget.suggestedProducts[index]['name'].length > 30
                                  ? "${widget.suggestedProducts[index]['name'].substring(0, 20.toInt())}..."
                                  : widget.suggestedProducts[index]['name'],
                                   style: AppStyles.getMediumTextStyle(
                                      fontSize: 12, color: AppColors.fontColor)),
                      ),
                      // const SizedBox(height: 10,),
                      if (productModel1.items![index].configurableOptions != null)
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                              addAutomaticKeepAlives: true,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 5),
                              itemCount: productModel1.items![index].configurableOptions![0].values!.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 10),
                              itemBuilder: (context, index1) {
                            return Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  color: AppColors.containerColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Color(
                                    int.parse('ff${productModel1.items![index].configurableOptions![0].values![index1].swatchData!.replaceAll('#', '')}', radix: 16),
                                  ),),
                              ),
                              child: Center(
                                child: FractionallySizedBox(
                                  heightFactor: .85, // Adjust those two for the white space
                                  widthFactor: .85,
                                  child: Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        int.parse('ff${productModel1.items![index].configurableOptions![0].values![index1].swatchData!.replaceAll('#', '')}', radix: 16),
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                                                ),
                        ),
                      SizedBox(
                        width: 150,
                        child: Text(
                                 "${widget.suggestedProducts[index]['price_range']['minimum_price']['regular_price']['currency']} ${widget.suggestedProducts[index]['price_range']['minimum_price']['regular_price']['value'].toString()}",
                                 style: AppStyles.getLightTextStyle(
                                     fontSize: 12,
                                    color: AppColors.fontColor),
                               ),
                      ),
                    ],
                  ),
                  QuantityChanger(quantity: quantity,productModel: productModel,),

                  // Column(
                  //   children: [
                  //     // buildQuantityChanger(index),
                  //     const SizedBox(height: 5,),
                  //     Padding(
                  //              padding: const EdgeInsets.all(5),
                  //             child: SizedBox(
                  //               width: 100,
                  //                height: 40,
                  //                child: BuildButtonSingle(
                  //                  typeName: productModel.sTypename!,
                  //                 width: 400,
                  //                 title: 'ADD TO CART',
                  //                  buttonColor: AppColors.buttonColor,
                  //                  textColor: Colors.white,
                  //                 svg: 'assets/svg/shopping-cart.svg',
                  //                 parentSku: productModel.sku!,
                  //                  selectedSku: productModel
                  //                      .variants?[0].product?.sku!,
                  //                  quantity: quantity,
                  //                ),
                  //              ),),
                  //   ],
                  // ),
                ],
              )
              // Center(
              //   child: ListTile(
              //     leading: Container(
              //       color: AppColors.appBarColor,
              //       height: 100,
              //       width: 50,
              //       child: CachedNetworkImage(imageUrl: widget.suggestedProducts[index]
              //       ['image']['url'],fit: BoxFit.contain,),
              //     ),
              //     // Image(
              //     //   image: NetworkImage(suggestedProducts[index]['image']['url']),fit: BoxFit.contain,),
              //     title: Text(widget.suggestedProducts[index]['name'].length > 20
              //         ? "${widget.suggestedProducts[index]['name'].substring(0, 20.toInt())}..."
              //         : widget.suggestedProducts[index]['name'],
              //         style: AppStyles.getMediumTextStyle(
              //             fontSize: 12, color: AppColors.fontColor)),
              //     // subtitle: Text(characters[index]['countries'][index]['code']),
              //     subtitle: Text(
              //       "${widget.suggestedProducts[index]['price_range']['minimum_price']['regular_price']['currency']} ${widget.suggestedProducts[index]['price_range']['minimum_price']['regular_price']['value'].toString()}",
              //       style: AppStyles.getLightTextStyle(
              //           fontSize: 12,
              //           color: AppColors.fontColor),
              //     ),
              //     trailing: Padding(
              //       padding: const EdgeInsets.all(5),
              //       child: SizedBox(
              //         width: 100,
              //         height: 100,
              //         child: BuildButtonSingle(
              //           typeName: productModel.sTypename!,
              //           width: 400,
              //           title: 'ADD TO CART',
              //           buttonColor: AppColors.buttonColor,
              //           textColor: Colors.white,
              //           svg: 'assets/svg/shopping-cart.svg',
              //           parentSku: productModel.sku!,
              //           selectedSku: productModel
              //               .variants?[0].product?.sku!,
              //           quantity: quantity,
              //         ),
              //       ),
              //       // Container(
              //       //   width: 100,
              //       //   height: 100,
              //       //   decoration: BoxDecoration(
              //       //     color: AppColors.buttonColor,
              //       //     borderRadius: BorderRadius.all(Radius.circular(5))
              //       //   ),
              //       //   child: Center(child: Text("ADD TO CART",style: AppStyles.getMediumTextStyle(fontSize: 10,color: Colors.white),)),
              //       // ),
              //     ),
              //   ),
              // ),
            ),
          );
        }, ),
    );
  }

}
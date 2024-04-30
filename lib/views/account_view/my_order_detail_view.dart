import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:m2/services/app_responsive.dart';
import 'package:m2/utilities/utilities.dart';
import 'package:m2/utilities/widgets/account_sidebar.dart';
import 'package:m2/utilities/widgets/widgets.dart';
import 'package:m2/views/account_view/orders_view.dart';
import 'package:m2/views/product_views/product_view.dart';
import 'package:provider/provider.dart';

import '../../services/api_services/product_apis.dart';
import '../../services/models/product_model.dart';
import '../../services/state_management/cart/cart_data.dart';
import '../../services/state_management/token/token.dart';

class MyOrderDetailView extends StatefulWidget {
  const MyOrderDetailView({super.key, required this.orderId});

  final String orderId;

  @override
  State<MyOrderDetailView> createState() => _MyOrderDetailViewState();
}

class _MyOrderDetailViewState extends State<MyOrderDetailView> {
  DateFormat dateFormat = DateFormat('MM/dd/yyyy');

  @override
  void initState() {
    super.initState();
    print(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BuildScaffold(
      child: LayoutBuilder(builder: (context, constraints) {
        return Query(
            options: QueryOptions(
                document: gql(orderDetails),
                fetchPolicy: FetchPolicy.noCache,
                variables: {
                  'filter': {
                    "number": {"eq": widget.orderId}
                  }
                }),
            builder: (result, {fetchMore, refetch}) {
              if (result.isLoading) {
                return BuildLoadingWidget(color: AppColors.primaryColor);
              }
              if (result.hasException) {
                return Center(
                  child: BuildErrorWidget(
                    errorMsg: result.exception?.graphqlErrors[0].message,
                    onRefresh: refetch,
                  ),
                );
              }
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 1400
                        ? (constraints.maxWidth - 1400) / 2
                        : 10,
                    vertical: 20),
                child: AppResponsive(
                  mobile: _getMobileView(size, result.data!),
                  desktop: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: size.width * 0.2,
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: AccountSideBar(currentPage: OrdersView.route),
                      ),
                      Expanded(child: _getMobileView(size, result.data!))
                    ],
                  ),
                ),
              );
            });
      }),
    );
  }

  Padding _getMobileView(Size size, Map data) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My orders',
              style: AppStyles.getMediumTextStyle(
                  fontSize: 18, color: AppColors.primaryColor)),
          const SizedBox(height: 10),
          Text('Order ID: ${widget.orderId}',
              style: AppStyles.getMediumTextStyle(
                  fontSize: 18, color: AppColors.fontColor)),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Order date:\t\t',
                  style: AppStyles.getMediumTextStyle(
                      fontSize: 12, color: AppColors.evenFadedText),
                ),
                TextSpan(
                  text: dateFormat.format(DateTime.parse(data['customer']['orders']['items'][0]['order_date'])),
                  style: AppStyles.getMediumTextStyle(
                      fontSize: 12, color: AppColors.fadedText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Divider(
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 5),
          // ListView.separated(
          //   itemCount: data['customer']['orders']['items'][0]['items'].length,
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   separatorBuilder: (ctx, index) => !AppResponsive.isDesktop(context)
          //       ? const SizedBox(height: 40)
          //       : Column(
          //           children: [
          //             const SizedBox(height: 40),
          //             Divider(height: 1, color: AppColors.evenFadedText),
          //             const SizedBox(height: 40),
          //           ],
          //         ),
          //   itemBuilder: (context, index) => BuildOrderDetailContainer(
          //     data: data['customer']['orders']['items'][0]['items'][index],
          //     size: size,
          //     orderId: widget.orderId,
          //   ),
          // ),
          ListView.builder(
              itemCount: data['customer']['orders']['items'][0]['items'].length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
                return BuildOrderDetailContainer(
                    size: size,
                    orderId: widget.orderId,
                    data: data['customer']['orders']['items'][0]['items'][index]);
              }),
          const SizedBox(height: 5),
          Divider(
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  String orderDetails = r'''
  query Orders($filter:CustomerOrdersFilterInput!){
    customer {
      orders(filter:$filter,currentPage: 1, pageSize:10){
        items {
          number
          id
          order_date
          status
          total{
            grand_total{
              value
            }
          }
          items{
            product_name
            status
            product_sku
            product_url_key
            quantity_ordered
            product_sale_price{
                value
            }
          }
          status
        }
        page_info {
          current_page
          page_size
          total_pages
        }
      }
    }
  }
  ''';
}

class BuildOrderDetailContainer extends StatefulWidget {
  const BuildOrderDetailContainer(
      {super.key,
      required this.size,
      required this.orderId,
      this.isReturn = false,
      required this.data});

  final Size size;
  final String orderId;
  final bool isReturn;
  final Map data;

  @override
  State<BuildOrderDetailContainer> createState() =>
      _BuildOrderDetailContainerState();
}

class _BuildOrderDetailContainerState extends State<BuildOrderDetailContainer> {
  List<dynamic> suggestedProducts = [];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(widget.data);
        context.push('/${ProductView.route}/${widget.data['product_url_key']}');
      },
      child: SizedBox(
        width: widget.size.width,
        child: AppResponsive(
          mobile: _getMobileViewNew(),
          desktop: Row(
            children: [
              Flexible(flex: 5, child: _getOrderDetails()),
              const Spacer(),
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _getOrderPrice(),
                    // _getOrderDelivery(),
                    _orderCancelButton(),
                    _trackOrderButton(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _getMobileViewNew(){
    return Container(
      margin: const EdgeInsets.all(5),
      height: 100,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            decoration:  BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: AppColors.greyBgColor
            ),
          ),
          const SizedBox(width: 5,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 5),
                // margin: const EdgeInsets.all(10),
                width: widget.size.width / 3,
                child: Text(
                  widget.data['product_name'].length > 20
                      ? "${widget.data['product_name'].substring(0, 20.toInt())}..."
                      : widget.data['product_name'],
                  style: AppStyles.getMediumTextStyle(
                      fontSize: 12, color: AppColors.fontColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                // margin: const EdgeInsets.all(10),
                width: widget.size.width / 3,
                child:
                  Text.rich(
                    TextSpan(
                      text: "$currency: ",
                      style: AppStyles.getMediumTextStyle(
                          fontSize: 12, color: AppColors.primaryColor),
                      children: [
                        TextSpan(
                            text:
                            widget.data['product_sale_price']['value'].toStringAsFixed(2),
                            //"${2*widget.data['product_sale_price']['value']}".toString(),
                            style: AppStyles.getMediumTextStyle(
                                fontSize: 12, color: AppColors.fontColor)),
                      ],
                    ),
                  ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 5),
                // margin: const EdgeInsets.all(10),
                width: widget.size.width / 3,
                child: Text.rich(
                TextSpan(
                  text: "Qty: ",
                  style: AppStyles.getMediumTextStyle(
                      fontSize: 12, color: AppColors.primaryColor),
                  children: [
                    TextSpan(
                        text:
                        widget.data['quantity_ordered'].toString(),
                        //"${2*widget.data['product_sale_price']['value']}".toString(),
                        style: AppStyles.getMediumTextStyle(
                            fontSize: 12, color: AppColors.fontColor)),
                  ],
                ),
              ),
              ),
            ],
          ),
          // const SizedBox(width: 5,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _reOrderButton(),
            ],
          )
        ],
      ),
    );
  }

  Column _getMobileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getOrderDetails(),
        const SizedBox(height: 20),
        _getOrderPrice(),
        const SizedBox(height: 10),
        // _getOrderDelivery(),
        // const SizedBox(height: 10),
        if (!widget.isReturn)
          SizedBox(
            width: widget.size.width,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                _trackOrderButton(),
                // _orderCancelButton(),
                _reOrderButton()
              ],
            ),
          ),
        if (widget.isReturn) _returnButton()
      ],
    );
  }

  Row _getOrderDetails() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // _getProductContainer(),
        // const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(height: 20,
              // // width: 20,
              // decoration: BoxDecoration(
              //   // color: Colors.red,
              //   borderRadius: BorderRadius.all(Radius.circular(5)),
              //   // image: DecorationImage(image: NetworkImage(widget.data['product_url_key']))
              // ),
              // child: Text(widget.data['image']['url']),),
              Text(
                widget.data['product_name'],
                style: AppStyles.getMediumTextStyle(
                    fontSize: 18, color: AppColors.fontColor),
              ),
              Text(
                widget.data['quantity_ordered'] > 1
                    ? "Products ordered: ${widget.data['quantity_ordered'].toString()}"
                    : "Product ordered: ${widget.data['quantity_ordered'].toString()}",
                style: AppStyles.getMediumTextStyle(
                    fontSize: 12, color: AppColors.fadedText),
              ),
              const SizedBox(height: 5),
              Text(
                'Order details',
                style: AppStyles.getMediumTextStyle(
                    fontSize: 12, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 5),
              Container(height: 1, color: AppColors.buttonColor),
              const SizedBox(height: 5),
              Text(
                'Order status : ${widget.data['status']}',
                style: AppStyles.getRegularTextStyle(
                    fontSize: 12, color: AppColors.fadedText),
              ),
              const SizedBox(height: 5),
              // Text(
              //   'Payement Methods : Cash On Delivery',
              //   style: AppStyles.getRegularTextStyle(fontSize: 12, color: AppColors.fadedText),
              // ),
            ],
          ),
        )
      ],
    );
  }

  TextButton _returnButton() {
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      onPressed: () {},
      child: Text('Returns',
          style: AppStyles.getMediumTextStyle(fontSize: 17, color: Colors.red)),
    );
  }

  TextButton _orderCancelButton() {
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      onPressed: () {},
      child: Text('Cancel Order',
          style: AppStyles.getMediumTextStyle(
              fontSize: 17, color: AppColors.fadedText)),
    );
  }

  ///111
  // Mutation<Object?> _reOrderButton() {
  //   var cartData = Provider.of<CartData>(context, listen: false);
  //   return Mutation(
  //       options: MutationOptions(
  //         document: gql(ProductApi.reorder),
  //         onCompleted: (data) {
  //           //print(data);
  //           try {
  //             if (data!['reorderItems']['userInputErrors'].isEmpty) {
  //               cartData.putCartCount(
  //                   data['reorderItems']['cart']['total_quantity'].ceil());
  //
  //               // TODO: CartView
  //               // navigate(context, Cart.route, arguments: {"page": 3});
  //             } else {
  //               for (var i in data['reorderItems']['userInputErrors']) {
  //                 showSnackBar(
  //                     context: context,
  //                     message: i['message'],
  //                     backgroundColor: Colors.red);
  //               }
  //             }
  //           } catch (e) {
  //             //print(e);
  //           }
  //         },
  //       ),
  //       builder: (runMutation, result) {
  //         return InkWell(
  //             onTap: () => runMutation({'orderNo': widget.orderId}),
  //             child: result!.isLoading
  //                 ? BuildLoadingWidget(color: AppColors.primaryColor, size: 20)
  //                 : Text('Re-Order',
  //                     style: AppStyles.getMediumTextStyle(
  //                         fontSize: 17, color: AppColors.fadedText)));
  //       });
  // }

  ///222
  Mutation<Object?> _reOrderButton() {
    var cartData = Provider.of<CartData>(context, listen: false);
    return Mutation(
        options: MutationOptions(
          document: gql(ProductApi.addProductToCart),
          onCompleted: (data) {
            //print(data);
            try {
              if (data!['addProductsToCart']['user_errors'].isEmpty) {
                cartData.putCartCount(
                    data['addProductsToCart']['cart']['total_quantity'].ceil());

                // TODO: CartView
                // navigate(context, Cart.route, arguments: {"page": 3});
              } else {
                for (var i in data['addProductsToCart']['user_errors']) {
                  showSnackBar(
                      context: context,
                      message: i['message'],
                      backgroundColor: Colors.red);
                }
              }
            } catch (e) {
              //print(e);
            }
          },
        ),
        builder: (runMutation, result) {
          return InkWell(
              onTap: () {
                runMutation({'cartIdString': cartData.cartId,
                  'cartItemsMap': [
                    {'quantity': 1, 'sku': widget.data['product_sku']}
                  ]});
                showSnackBar(
                  backgroundColor: AppColors.snackbarSuccessBackgroundColor,
                  textColor: AppColors.snackbarSuccessTextColor,
                  context: context,
                  message: "Added to cart",
                );

              } ,
              child: result!.isLoading
                              ? BuildLoadingWidget(color: AppColors.primaryColor, size: 20)
                  : Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10),
                  ),
                  color: AppColors.primaryColor
                ),
                    child: Center(
                      child: Text('Buy it again',
                      style: AppStyles.getMediumTextStyle(
                          fontSize: 10, color: AppColors.containerColor)),
                    ),
                  ));
        });
  }



  TextButton _trackOrderButton() {
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      onPressed: () {},
      child: Text('Track Order',
          style: AppStyles.getMediumTextStyle(
              fontSize: 17, color: AppColors.buttonColor)),
    );
  }

  // Text _getOrderDelivery() {
  //   return const Text(
  //     'Delivery Expected Thu May 13 2021',
  //     style: TextStyle(
  //       fontFamily: 'Poppins',
  //       fontSize: 13,
  //       color: Color(0xff707070),
  //     ),
  //   );
  // }

  Text _getOrderPrice() {
    return Text.rich(
      TextSpan(
        text: "Total Price: ",
        style: AppStyles.getMediumTextStyle(
            fontSize: 18, color: AppColors.fontColor),
        children: [
          TextSpan(
            text: currency,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: AppColors.fontColor),
          ),
          TextSpan(
              text:
                  widget.data['product_sale_price']['value'].toStringAsFixed(2),
              //"${2*widget.data['product_sale_price']['value']}".toString(),
              style: AppStyles.getMediumTextStyle(
                  fontSize: 18, color: AppColors.fontColor)),
        ],
      ),
    );
  }

// Container _getProductContainer() {
//   return Container(
//     constraints: const BoxConstraints(maxHeight: 100, maxWidth: 100),
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       color: const Color(0xffffffff),
//       borderRadius: BorderRadius.circular(7.0),
//       border: Border.all(width: 1.0, color: AppColors.evenFadedText),
//     ),
//     child: Text(
//         // images[0],
//         widget.data.toString()),
//   );
// }
}

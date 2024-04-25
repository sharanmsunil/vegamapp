import 'dart:convert';
import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart%20';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:m2/services/api_services/customer_apis.dart';
import 'package:m2/services/app_responsive.dart';
import 'package:m2/services/state_management/user/user_data.dart';
import 'package:m2/utilities/utilities.dart';
import 'package:m2/utilities/widgets/account_sidebar.dart';
import 'package:m2/utilities/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../../services/api_services/product_apis.dart';
import '../../services/state_management/cart/cart_data.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  static String route = 'orders';

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  List<String> headers = ['Order', 'Date', 'Grand Total', 'Status', 'Actions'];
  DateFormat dateFormat = DateFormat('MM/dd/yyyy');
  int page = 1;
  int totalPage = 1;

  FetchMoreOptions? opts;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BuildScaffold(
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: AppResponsive.isMobile(context)
                  ? 20
                  : constraints.maxWidth > 1400
                      ? (constraints.maxWidth - 1400) / 2
                      : 60,
              vertical: 20),
          child: AppResponsive(
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AccountSideBar(currentPage: OrdersView.route),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                      margin: const EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldColor,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.shadowColor,
                              blurRadius: 50,
                              offset: const Offset(0, 10))
                        ],
                      ),
                      child: getBody(context, size)),
                ),
              ],
            ),
            mobile: getBody(context, size),
          ),
        );
      }),
    );
  }

  Padding getBody(BuildContext context, Size size) {
    var userData = Provider.of<UserData>(context);
    return Padding(
      padding: AppResponsive.isDesktop(context)
          ? const EdgeInsets.symmetric(horizontal: 60, vertical: 50)
          : EdgeInsets.symmetric(horizontal: size.width * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('My Orders',
                style: AppStyles.getMediumTextStyle(
                    fontSize: 18, color: AppColors.primaryColor)),
          ),
          const SizedBox(height: 30),
          getTableQuery(size),
        ],
      ),
    );
  }

  getTableQuery(Size size) {
    var cartData = Provider.of<CartData>(context, listen: false);
    // generate table
    return Query(
        options: QueryOptions(
            document: gql(CustomerApis.orderDetails),
            variables: {'page': page},
            fetchPolicy: FetchPolicy.noCache),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading && result.data == null) {
            return Center(
                child: BuildLoadingWidget(color: AppColors.primaryColor));
          }
          if (result.data == null) {
            return BuildErrorWidget(onRefresh: refetch);
          }
          log(jsonEncode(result.data!));
          try {
            var pageInfo = result.data!['customer']['orders']['page_info'];

            page = pageInfo['current_page'];
            totalPage = pageInfo['total_pages'];
          } catch (e) {}

          if (result.data!['customer']['orders']['items'].isEmpty) {
            return SizedBox(
              height: 200,
              child: Center(
                  child: Text("No orders yet",
                      style: AppStyles.getMediumTextStyle(
                          fontSize: 15, color: AppColors.primaryColor))),
            );
          }
          // if (opts == null)
          opts = FetchMoreOptions(
            document: gql(CustomerApis.orderDetails),
            variables: {'page': ++page},
            updateQuery: (previousResultData, fetchMoreResultData) {
              //print('currentReviewPage $page');
              // //print('fetchMoreResultData $fetchMoreResultData');

              final List<dynamic> repos = [
                ...previousResultData!['customer']['orders']['items']
                    as List<dynamic>,
                ...fetchMoreResultData!['customer']['orders']['items']
                    as List<dynamic>
              ];

              // to avoid a lot of work, lets just update the list of repos in returned
              // data with new data, this also ensures we have the endCursor already set
              // correctly
              fetchMoreResultData['customer']['orders']['items'] = repos;

              return fetchMoreResultData;
            },
          ); // List<Orders> products = List.generate(
          //     result.data!['customerOrders']['items']!.length, (index) => Orders.fromJson(result.data!['customerOrders']['items'][index]));
          // List<Orders> products = List.generate(data.length, (index) => Orders.fromJson(data[index]));
          return Column(
            children: [
              // BuildTableWidget(
              //   size: size,
              //   headers: headers,
              //   id: List.generate(result.data!['customer']['orders']['items'].length, (index) => result.data!['customer']['orders']['items'][index]['number'].toString()),
              //   cells: List<Map<String, dynamic>>.generate(
              //       result.data!['customer']['orders']['items'].length,
              //       (index) => {
              //             'data': result.data!['customer']['orders']['items'][index],
              //             'list': [
              //               result.data!['customer']['orders']['items'][index]['number'],
              //               dateFormat.format(DateTime.parse(result.data!['customer']['orders']['items'][index]['order_date'])),
              //               double.parse(result.data!['customer']['orders']['items'][index]['total']['grand_total']['value'].toString()).toStringAsFixed(2),
              //               result.data!['customer']['orders']['items'][index]['status'],
              //               'View Order'
              //             ],
              //           }),
              //   onTap: 'MyOrderDetailView',
              // ),

              ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  physics: const ScrollPhysics(),
                  itemCount: result.data!['customer']['orders']['items'].length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 200,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: AppColors.shadowColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [5, 5],
                                    color: result.data!['customer']['orders']['items'][index]['status'] == "Delivered" ? AppColors.orderConfirmColor : result.data!['customer']['orders']['items'][index]['status'] == "Pending" ? AppColors.orderPendingColor : AppColors.orderCancelledColor,
                                    strokeWidth: 2,
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      width: 30,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: result.data!['customer']['orders']['items'][index]['status'] == "Delivered" ? AppColors.orderConfirmColor : result.data!['customer']['orders']['items'][index]['status'] == "Pending" ? AppColors.orderPendingColor : AppColors.orderCancelledColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        result.data!['customer']['orders']['items'][index]['status'] == "Delivered" ? Icons.done : result.data!['customer']['orders']['items'][index]['status'] == "Pending" ? Icons.timelapse_outlined : Icons.cancel_outlined,
                                        color: AppColors.containerColor,
                                        size: 15,
                                      ),
                                    )),
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.data!['customer']['orders']
                                                      ['items'][index]['items']
                                                  [0]['quantity_ordered'] >
                                              1
                                          ? "Order id - ${result.data!['customer']['orders']['items'][index]['number']} - ${result.data!['customer']['orders']['items'][index]['items'][0]['quantity_ordered']} items"
                                          : "Order id - ${result.data!['customer']['orders']['items'][index]['number']} - ${result.data!['customer']['orders']['items'][index]['items'][0]['quantity_ordered']} item",
                                      style: AppStyles.getMediumTextStyle(
                                          fontSize: 12,
                                          color: AppColors.fontColor),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Order on - ${dateFormat.format(DateTime.parse(result.data!['customer']['orders']['items'][index]['order_date']))}",
                                      style: AppStyles.getMediumTextStyle(
                                          fontSize: 12,
                                          color: AppColors.fontColor),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                result.data!['customer']['orders']['items']
                                                [index]['items'][0]
                                            ['quantity_ordered'] >
                                        1
                                    ? "Price (${result.data!['customer']['orders']['items'][index]['items'][0]['quantity_ordered']} items)"
                                    : "Price (${result.data!['customer']['orders']['items'][index]['items'][0]['quantity_ordered']} item)",
                                style: AppStyles.getLightTextStyle(
                                    fontSize: 12, color: AppColors.fontColor),
                              ),
                              Text(
                                "₹${double.parse(result.data!['customer']['orders']['items'][index]['total']['grand_total']['value'].toString()).toStringAsFixed(2)}",
                                style: AppStyles.getLightTextStyle(
                                    fontSize: 12, color: AppColors.fontColor),
                              )
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Status",
                                style: AppStyles.getLightTextStyle(
                                    fontSize: 12, color: AppColors.fontColor),
                              ),
                              // Text("${result.data!['customer']['orders']['items'][index]['status']}"),
                              Text(
                                "${result.data!['customer']['orders']['items'][index]['status']}",
                                style: AppStyles.getLightTextStyle(
                                    fontSize: 12, color: AppColors.fontColor),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.push(
                                    "/account/${OrdersView.route}/${result.data!['customer']['orders']['items'][index]['number']}",
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.buttonColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5))),
                                  height: 30,
                                  width: 100,
                                  child: Center(
                                      child: Text(
                                    "View details",
                                    style: AppStyles.getMediumTextStyle(
                                        fontSize: 10,
                                        color: AppColors.buttonTextColor),
                                  )),
                                ),
                              ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //       color: AppColors.buttonTextColor,
                              //       borderRadius: const BorderRadius.all(Radius.circular(5))
                              //   ),
                              //   height: 30,
                              //   width: 100,
                              //   child: Center(child: Text("Re-Order",style: AppStyles.getMediumTextStyle(fontSize: 10,color: AppColors.buttonColor),)),
                              // ),
                              ///222
                              // Mutation(
                              //     options: MutationOptions(document: gql(ProductApi.reorder)),
                              //     builder: (runMutation, result1){
                              //       return InkWell(
                              //           onTap: ()=> runMutation({'orderNo': result.data!['customer']['orders']['items'][index]['number']}),
                              //           child: Container(
                              //             decoration: BoxDecoration(
                              //                 color: AppColors.buttonTextColor,
                              //                 borderRadius: const BorderRadius.all(Radius.circular(5))
                              //             ),
                              //             height: 30,
                              //             width: 100,
                              //             child: Center(child: Text("Re-Order",style: AppStyles.getMediumTextStyle(fontSize: 10,color: AppColors.buttonColor),)),
                              //           ),);
                              //     }),
                              ///3333
                              Mutation(
                                  options: MutationOptions(
                                    document: gql(ProductApi.reorder),
                                    onCompleted: (data) {
                                      //print(data);
                                      try {
                                        if (data!['reorderItems']
                                                ['userInputErrors']
                                            .isEmpty) {
                                          cartData.putCartCount(
                                              data['reorderItems']['cart']
                                                      ['total_quantity']
                                                  .ceil());

                                          // TODO: CartView
                                          // navigate(context, Cart.route, arguments: {"page": 3});
                                        } else {
                                          for (var i in data['reorderItems']
                                              ['userInputErrors']) {
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
                                  builder: (runMutation, result1) {
                                    return InkWell(
                                      onTap: () => runMutation({
                                        'orderNo': result.data!['customer']
                                            ['orders']['items'][index]['number']
                                      }),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.buttonTextColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5))),
                                        height: 30,
                                        width: 100,
                                        child: result1!.isLoading
                                            ? BuildLoadingWidget(
                                                color: AppColors.primaryColor,
                                                size: 20)
                                            : Center(
                                                child: Text(
                                                "Re-Order",
                                                style: AppStyles
                                                    .getMediumTextStyle(
                                                        fontSize: 10,
                                                        color: AppColors
                                                            .buttonColor),
                                              )),
                                      ),
                                    );
                                  }),
                            ],
                          )
                        ],
                      ),
                    );
                  }),

              const SizedBox(height: 10),
              if (totalPage >= page)
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      shape: const StadiumBorder(),
                      backgroundColor: AppColors.primaryColor,
                      shadowColor: AppColors.shadowColor,
                    ),
                    onPressed: () {
                      // //print(opts);
                      ++page;
                      fetchMore!(opts!);
                    },
                    child: result.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : Text(
                            'Load More',
                            style: AppStyles.getMediumTextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                  ),
                ),
            ],
          );
        });
  }
}

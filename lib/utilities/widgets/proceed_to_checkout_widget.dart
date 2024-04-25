// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:m2/services/api_services/cart_apis.dart';
import 'package:m2/services/search_services.dart';
import 'package:m2/services/state_management/cart/cart_data.dart';
import 'package:m2/services/state_management/token/token.dart';
import 'package:m2/utilities/utilities.dart';
import 'package:m2/utilities/widgets/widgets.dart';

class ProceedToCheckoutWidget extends StatefulWidget {
  const ProceedToCheckoutWidget({
    super.key,
    this.estimatedDelivery,
    this.onButtonTap,
    required this.buttonText,
    this.isLoading = false,
    required this.refetch,
  });
  final int? estimatedDelivery;
  final void Function()? onButtonTap;
  final String buttonText;
  final bool isLoading;
  final VoidCallback? refetch;
  @override
  State<ProceedToCheckoutWidget> createState() => _ProceedToCheckoutWidgetState();
}

class _ProceedToCheckoutWidgetState extends State<ProceedToCheckoutWidget> {
  TextEditingController coupon = TextEditingController();
  bool isAppliedCoupon = false;
  var f = NumberFormat("#,##,##,##0.00", "en_IN");
  MaterialStatesController buttonStateController = MaterialStatesController();
  bool isLoading = false;
  late AuthToken authToken;
  late CartData cart;

  Debouncer debouncer = Debouncer(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getData());
  }

  getData() {
    coupon = TextEditingController(text: cart.cartData['cart']['applied_coupons']?[0]['code'] ?? '');

    log(cart.cartData['cart']['applied_coupons'].toString());
    isAppliedCoupon = cart.cartData['cart']['applied_coupons'] != null;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    coupon.dispose();
    buttonStateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    cart = Provider.of<CartData>(context);
    authToken = Provider.of<AuthToken>(context);

    return Observer(builder: (context) {
      return Container(
        width: size.width,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(size.width * 0.05 > 40 ? 40 : size.width * 0.05),
        decoration: BoxDecoration(
          color: AppColors.dividerColor,
          // borderRadius: BorderRadius.circular(18.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.spaceBetween,
              spacing: 20,
              runSpacing: 20,
              children: [
                Text('Order Total', style: AppStyles.getSemiBoldTextStyle(fontSize: 12, color: AppColors.fontColor)),
                Text.rich(
                  TextSpan(
                    children: [
                      if (cart.cartData['cart']['prices']['grand_total']['currency'] != null)
                        TextSpan(
                            text: '${cart.cartData['cart']['prices']['grand_total']['currency']} ',
                            style: AppStyles.getSemiBoldTextStyle(fontSize: 12, color: AppColors.fontColor)),
                      TextSpan(
                          text: f.format(cart.cartData['cart']['prices']['grand_total']['value']), style: AppStyles.getMediumTextStyle(fontSize: 12, color: AppColors.fontColor))
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              // style: TextButton.styleFrom(
              //   fixedSize: Size(size.width * 0.8, size.width * 0.125),
              //   maximumSize: Size(250, 50),
              //   shape: StadiumBorder(side: BorderSide(width: 2, color: AppColors.buttonColor)),
              //   shadowColor: AppColors.shadowColor,
              // ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 2, color: AppColors.buttonColor),borderRadius: BorderRadius.circular(5))),
                shadowColor: MaterialStateProperty.all(AppColors.shadowColor),
                backgroundColor: MaterialStateProperty.resolveWith(getButtonColor),
                foregroundColor: MaterialStateProperty.resolveWith(getTextColor),
                padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
              ),
              statesController: buttonStateController,
              onPressed: widget.onButtonTap,
              child: widget.isLoading
                  ? const BuildLoadingWidget()
                  : Text(
                widget.buttonText,
                style: AppStyles.getRegularTextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            // const SizedBox(height: 40),
          ],
        ),
      );
    });
  }
}

applyDiscount() {}

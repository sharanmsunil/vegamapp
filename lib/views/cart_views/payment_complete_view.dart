import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:m2/utilities/utilities.dart';
import 'package:m2/utilities/widgets/scaffold_body.dart';
import 'package:provider/provider.dart';

import '../../services/state_management/token/token.dart';
import '../account_view/orders_view.dart';
import '../auth/auth.dart';
import '../home/search_view.dart';
import 'cart_view.dart';

class OrderPlacedView extends StatefulWidget {
  const OrderPlacedView({super.key, this.orderId});
  static String route = 'ordersucess';
  final String? orderId;

  @override
  State<OrderPlacedView> createState() => _OrderPlacedViewState();
}

class _OrderPlacedViewState extends State<OrderPlacedView> {
  @override
  Widget build(BuildContext context) {
    return BuildScaffold(
        child: ListView(
      shrinkWrap: true,
      children: [
        // const BuildCheckoutSteps(index: 3),
        const SizedBox(height: 20),
        ConstrainedBox(constraints: const BoxConstraints(maxHeight: 400), child: Image.asset('assets/images/thankyou.png')),
        const SizedBox(height: 20),
        Text(
          "${widget.orderId == null ? 'Thank you for your order!' : "Your order number ${widget.orderId} has been placed"} .\nWe’ll let you know as soon as it ships.",
          style: AppStyles.getMediumTextStyle(fontSize: 15, color: AppColors.fontColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Wrap(
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Text(
              'Having trouble? ',
              style: AppStyles.getLightTextStyle(fontSize: 14, color: AppColors.fontColor),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                'Contact us',
                style: AppStyles.getLightTextStyle(fontSize: 14, color: AppColors.buttonColor),
              ),
            )
          ],
        ),
        const SizedBox(height: 50,),
        InkWell(
          onTap: (){
        navigate(0, context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 100),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: AppColors.primaryColor
            ),
            child: Center(child: Text('Shop More',style: AppStyles.getRegularTextStyle(fontSize: 14,color: AppColors.containerColor),)),
          ),
        ),
        const SizedBox(height: 20,),
        InkWell(
          onTap: (){
            context.push("/account/${OrdersView.route}");
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 100),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              border: Border.all(color: AppColors.primaryColor,width: 1),
              color: AppColors.containerColor
            ),
            child: Center(child: Text('View Orders',style: AppStyles.getRegularTextStyle(fontSize: 14,color: AppColors.primaryColor),)),
          ),
        ),
      ],
    ));
  }

    navigate(int index, BuildContext context) {
    switch (index) {
    case 0:
    return context.push("/");
    case 1:
    return context.push('/${SearchView.route}');
    case 2:
    return context.push("/${CartView.route}");
    case 3:
    final authToken = Provider.of<AuthToken>(context, listen: false);
    if (authToken.loginToken == null) {
    return context.push('/${Auth.route}');
    } else {
    return context.push('/account');
    }

    default:
    break;
    }
    }
}

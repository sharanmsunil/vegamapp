import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart%20';

import '../app_colors.dart';
import '../app_style.dart';
import 'buttons.dart';

class QuantityChanger extends StatefulWidget {
    const QuantityChanger(
      {super.key, required this.quantity, required this.productModel});

    final double quantity;
  final dynamic productModel;

  @override
  State<QuantityChanger> createState() => _QuantityChangerState();
}

class _QuantityChangerState extends State<QuantityChanger> {
  late  Timer? timer;
  dynamic _quantity;
  @override
  void initState() {
    _quantity = widget.quantity;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      if (_quantity > 1) _quantity--;
                    }),
                    onLongPress: () => setState(() {
                      timer = Timer.periodic(const Duration(milliseconds: 50),
                          (timer) {
                        setState(() {
                          if (_quantity > 1) _quantity--;
                        });
                      });
                    }),
                    onLongPressEnd: (_) => setState(() {
                      timer?.cancel();
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5)),
                          border: Border.all(
                              width: 1, color: AppColors.primaryColor),
                          color: AppColors.primaryColor),
                      alignment: Alignment.center,
                      width: 30,
                      height: 30,
                      child: Center(
                          child: Icon(Icons.expand_more,
                              size: 14.5, color: AppColors.containerColor)),
                    ),
                  ),
                  Container(
                    width: 40,
                    decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: AppColors.primaryColor),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 7.5, horizontal: 10),
                    alignment: Alignment.center,
                    child: Text(
                      _quantity.round().toString(),
                      style: AppStyles.getSemiBoldTextStyle(
                          fontSize: 12, color: AppColors.primaryColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (_quantity < 99) _quantity++;
                    }),
                    onLongPress: () => setState(() {
                      timer = Timer.periodic(const Duration(milliseconds: 50),
                          (timer) {
                        setState(() {
                          if (_quantity < 99) {
                            _quantity++;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                "Limit reached",
                                style: TextStyle(
                                    color: AppColors.snackbarErrorTextColor),
                              ),
                              backgroundColor:
                                  AppColors.snackbarErrorBackgroundColor,
                            ));
                            timer.cancel();
                          }
                        });
                      });
                    }),
                    onLongPressEnd: (_) => setState(() {
                      timer?.cancel();
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                          border: Border.all(
                              width: 1, color: AppColors.primaryColor),
                          color: AppColors.primaryColor),
                      alignment: Alignment.center,
                      width: 30,
                      height: 30,
                      child: Center(
                          child: Icon(Icons.expand_less,
                              size: 14.5, color: AppColors.containerColor)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            width: 100,
            height: 40,
            child: BuildButtonSingle(
              typeName: widget.productModel.sTypename!,
              width: 400,
              title: 'ADD TO CART',
              buttonColor: AppColors.buttonColor,
              textColor: Colors.white,
              svg: 'assets/svg/shopping-cart.svg',
              parentSku: widget.productModel.sku!,
              selectedSku: widget.productModel.variants?[0].product?.sku!,
              quantity: _quantity,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:m2/utilities/app_colors.dart';

import '../../../views/product_views/product_view.dart';

class PopularItem extends StatelessWidget {
  PopularItem({super.key});

  final List<String> popularItem = [
    'Shirt',
    'Watch',
    'Bags',
    'Short',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      // color: Colors.grey.shade200,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: MediaQuery.of(context).size.width < 500 ? 200 : 400,
          // crossAxisCount: constraints.maxWidth < 600 ? 2 : (constraints.maxWidth / 250).floor(),
          crossAxisSpacing: MediaQuery.of(context).size.width < 500 ? 0 : 30,
          mainAxisSpacing: MediaQuery.of(context).size.width < 500 ? 10 : 30,
          mainAxisExtent: 40,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 9),

        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: popularItem.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: InkWell(
              onTap: (){
                context.push(Uri(
                    path: '/${ProductView.route}',
                    queryParameters: {"search": popularItem[index]})
                    .toString());
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  color: AppColors.containerColor,
                  border: Border.all(color: AppColors.greyBgColor)
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(popularItem[index]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
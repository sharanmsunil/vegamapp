import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:m2/services/functions/db_functions.dart';
import 'package:m2/utilities/utilities.dart';

import '../../../services/models/recent_searches/recent_model.dart';
import '../../../views/product_views/product_view.dart';

class RecentSearches extends StatelessWidget {
   const RecentSearches({super.key,
  });


  @override

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ValueListenableBuilder(
        valueListenable: searchListNotifier,
        builder: (BuildContext ctx, List<RecentSearchModel> searchList, Widget? child) {

          if(searchList.length > 4){
            deleteExtraSearch(searchList);
          }
          return ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: searchList.length,
              itemBuilder: (context, index) {
                final data = searchList[index];
                return InkWell(
                        onTap: () {
                          context.push(Uri(
                              path: '/${ProductView.route}',
                              queryParameters: {
                                "search": data.search
                              }).toString());
                        },
                        child: Center(
                          child: FilterChip(
                            showCheckmark: false,
                            label: Text(data.search.length > 5
                                ? "${data.search.substring(0, 5.toInt())}..."
                                : data.search),
                            labelStyle: AppStyles.getMediumTextStyle(
                                fontSize: 16, color: AppColors.buttonColor),
                            backgroundColor: AppColors.containerColor,
                            // avatar: _isSelected ? Icon(Icons.check, color: Colors.white) : null,
                            // avatar: const CircleAvatar(
                            //   child: Center(child: Icon(Icons.history)),
                            // ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            side: BorderSide(
                                color: AppColors.buttonColor, width: 1),
                            padding: const EdgeInsets.all(5),
                            // selected: _isSelected,
                            // onSelected: (isSelected) {
                            //   setState(() {
                            //     _isSelected = isSelected;
                            //   });
                            // },
                            // selectedColor: Colors.pink,
                            onSelected: (bool value) {
                              context.push(Uri(
                                  path: '/${ProductView.route}',
                                  queryParameters: {
                                    "search": data.search
                                  }).toString());
                            },
                          ),
                        ));
              },
          separatorBuilder: (BuildContext ctx, index){
                return const SizedBox(width: 10,);
          },
          );
        }
      ),
    );
  }

  Future <void> deleteExtraSearch(searchList) async{
      for(int i=0; searchList.length > 5;){
        // searchList.removeAt(i);
        await deleteSearch(i);
      }
  }
}

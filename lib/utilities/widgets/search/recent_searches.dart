import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:m2/utilities/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../views/product_views/product_view.dart';

class RecentSearches extends StatefulWidget {
  const RecentSearches({super.key,
    required this.recentSearched
  });
  final String? recentSearched;

  @override
  State<RecentSearches> createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<RecentSearches> {
  List<String> recentSearches = [];
  late SharedPreferences preferences;
  String? recentProduct;

  @override
  void initState() {
    fetchList();
    super.initState();
  }

  Future <void> fetchList () async{
    preferences = await SharedPreferences.getInstance();
    setState(()  {
      recentSearches = preferences.getStringList('recentSearches') ?? [];
      if(recentSearches.length > 4){
         preferences.remove('recentSearches');
        for( int i=0; recentSearches.length > 4;){
          recentSearches.removeAt(i);
        }
        preferences.setStringList('recentSearches', recentSearches);
      }
    });
  }

  // Future<void> fetchList()  async{
  //   preferences = await SharedPreferences.getInstance();
  //   setState(() async {
  //     // preferences.setStringList('recentSearches', widget.recentSearched!);
  //     recentSearches = preferences.getStringList('recentSearches') ?? [];
  //     recentSearches.add(widget.recentSearched!);
  //     for (int i = 0; recentSearches.length > 4;) {
  //       // isTrue = true;
  //       // await preferences.remove('recentSearches');
  //       recentSearches.removeAt(i);
  //     }
  //     // if(isTrue == true){
  //     //     preferences.setStringList('recentSearches', recentSearches);
  //     //   isTrue = false;
  //     // }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // physics: const NeverScrollableScrollPhysics(),
          // reverse: true,
          shrinkWrap: true,
          itemCount: recentSearches.length,
          itemBuilder: (context, index) {
            return
                //   TextButton(onPressed: (){
                //   context.push(Uri(
                //       path: '/${ProductView.route}',
                //       queryParameters: {"search": recentSearches[index]})
                //       .toString());
                // }, child: Text("${recentSearches[index]}, ",style: AppStyles.getMediumTextStyle(fontSize: 16,color: AppColors.fadedText),))
                InkWell(
                    onTap: () {
                      context.push(Uri(
                          path: '/${ProductView.route}',
                          queryParameters: {
                            "search": recentSearches[index]
                          }).toString());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Center(
                        child: FilterChip(
                          showCheckmark: false,
                          label: Text(recentSearches[index].length > 5
                              ? "${recentSearches[index].substring(0, 5.toInt())}..."
                              : recentSearches[index]),
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
                                  "search": recentSearches[index]
                                }).toString());
                          },
                        ),
                      ),
                    ));
          }),
    );
  }
}

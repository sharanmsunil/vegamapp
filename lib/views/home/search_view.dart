import 'package:flutter/material.dart';
import 'package:flutter/material.dart%20';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:m2/services/api_services/api_services.dart';
import 'package:m2/services/api_services/suggested_product_api.dart';
import 'package:m2/services/search_services.dart';
import 'package:m2/utilities/utilities.dart';
import 'package:m2/utilities/widgets/widgets.dart';

import 'package:m2/views/product_views/product_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/models/product_model.dart';
import '../../utilities/widgets/search/popular_item.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  static String route = 'search';

  @override
  State<SearchView> createState() => _SearchViewState();
}

// Only on mobile. Seperate page for search

class _SearchViewState extends State<SearchView> {
  List<String> dropDownItem = ['All', 'Mobile', 'Accessories'];
  String dropDownValue = 'All';
  TextEditingController searchQuery = TextEditingController();
  List<dynamic> suggestedProducts = [];
  bool _isloading = false;
  late SharedPreferences preferences;
  List<String> recentSearches = [];

  @override
  void initState() {
    setState(() {
      fetchProducts();
      fetchList();
    });
    super.initState();
  }

  fetchList() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = preferences.getStringList('recentSearches') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BuildScaffold(
      currentIndex: 1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: size.width,
              height: 50,
              margin: EdgeInsets.all(size.width * 0.05),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(width: 1, color: AppColors.fadedText),
              ),
              child: TextFieldSearch(
                label: 'Search',
                controller: searchQuery,
                future: () => ApiServices().searchSuggessionApi(
                    searchQuery: searchQuery.text, context: context),
                itemsInView: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(300),
                    borderSide: BorderSide(color: AppColors.evenFadedText),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(300),
                    borderSide: BorderSide(color: AppColors.evenFadedText),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  hintText: "Search",
                  hintStyle: AppStyles.getRegularTextStyle(
                      fontSize: 14, color: AppColors.primaryColor),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      splashRadius: 25,
                      onPressed: () async {
                        preferences = await SharedPreferences.getInstance();
                        setState(() {
                          recentSearches.add(searchQuery.text);
                          preferences.setStringList(
                              'recentSearches', recentSearches);
                        });
                        context.push(Uri(
                                path: '/${ProductView.route}',
                                queryParameters: {"search": searchQuery.text})
                            .toString());
                      },
                      icon: Icon(Icons.search, color: AppColors.fadedText),
                    ),
                  ),
                ),
                onSubmitted: (value) => context.push(Uri(
                    path: '/${ProductView.route}',
                    queryParameters: {"search": searchQuery.text}).toString()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: TwoColoredTitle(
                  title: "Popular Searches",
                  firstHeadColor: AppColors.primaryColor,
                  secondHeadColor: Colors.black),
            ),
            PopularItem(),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: TwoColoredTitle(
                  title: "Products You May also Like",
                  firstHeadColor: AppColors.primaryColor,
                  secondHeadColor: Colors.black),
            ),
            // Obx(() {
            //   if (productController.isLoading.value) {
            //     return Center(
            //         child: CircularProgressIndicator(color: AppColors.primaryColor,strokeWidth: 4,));
            //   } else {
            //     return GridView.builder(
            //       shrinkWrap: true,
            //         physics: NeverScrollableScrollPhysics(),
            //         itemCount: productController.productList.length,
            //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //             crossAxisCount: 2,
            //             crossAxisSpacing: 5,
            //             mainAxisSpacing: 20,
            //             childAspectRatio: MediaQuery.of(context).size.width /
            //                 (MediaQuery.of(context).size.height / 2.5)),
            //         itemBuilder: (context, index) {
            //           return ProductTile(productController.productList[index],);
            //         });
            //   }
            // })
            _isloading
                ? const CircularProgressIndicator()
                : suggestedProducts.isEmpty
                    ? Center(
                        child: Container(
                          height: 50,
                          width: 50,
                          color: Colors.red,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: suggestedProducts.length,
                            itemBuilder: (context, index) {
                              var productModel =
                                  Items.fromJson(suggestedProducts[index]);
                              // var cartModel = Items.fromJson(cartProducts[index]);
                              return InkWell(
                                onTap: () => context.push(
                                    '/${ProductView.route}/${productModel.urlKey}.${productModel.urlSuffix}'),
                                child: Card(
                                  elevation: 2,
                                  color: AppColors.appBarColor,
                                  child: ListTile(
                                    leading: Container(
                                      height: 100,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  suggestedProducts[index]
                                                      ['image']['url']),
                                              fit: BoxFit.contain)),
                                    ),
                                    // Image(
                                    //   image: NetworkImage(suggestedProducts[index]['image']['url']),fit: BoxFit.contain,),
                                    title: Text(
                                      suggestedProducts[index]['name'],
                                      style: AppStyles.getRegularTextStyle(
                                          fontSize: 15,
                                          color: AppColors.fadedText),
                                    ),
                                    // subtitle: Text(characters[index]['countries'][index]['code']),
                                    subtitle: Text(
                                      "${suggestedProducts[index]['price_range']['minimum_price']['regular_price']['currency']} ${suggestedProducts[index]['price_range']['minimum_price']['regular_price']['value'].toString()}",
                                      style: AppStyles.getLightTextStyle(
                                          fontSize: 12,
                                          color: AppColors.fontColor),
                                    ),
                                    trailing: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: BuildButtonSingle(
                                          typeName: productModel.sTypename!,
                                          width: 400,
                                          title: 'ADD TO CART',
                                          buttonColor: AppColors.buttonColor,
                                          textColor: Colors.white,
                                          svg: 'assets/svg/shopping-cart.svg',
                                          parentSku: productModel.sku!,
                                          selectedSku: productModel
                                              .variants?[0].product?.sku!,
                                          quantity: 1,
                                        ),
                                      ),
                                      // Container(
                                      //   width: 100,
                                      //   height: 100,
                                      //   decoration: BoxDecoration(
                                      //     color: AppColors.buttonColor,
                                      //     borderRadius: BorderRadius.all(Radius.circular(5))
                                      //   ),
                                      //   child: Center(child: Text("ADD TO CART",style: AppStyles.getMediumTextStyle(fontSize: 10,color: Colors.white),)),
                                      // ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
          ],
        ),
      ),
    );
  }

  void fetchProducts() async {
    setState(() {
      _isloading = true;
    });
    HttpLink link = HttpLink(ApiServices.path);
    GraphQLClient qlClient =
        GraphQLClient(link: link, cache: GraphQLCache(store: HiveStore()));
    QueryResult queryResult = await qlClient
        .query(QueryOptions(document: gql(SuggestedApi.suggestedProducts)));
    setState(() {
      suggestedProducts = queryResult.data!['products']['items'];
      // cartProducts = queryResult1.data!['products']['items'];

      _isloading = false;
    });
  }
}

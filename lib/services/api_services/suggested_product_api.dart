class SuggestedApi{
  static String suggestedProducts = '''{
  products(
    
   # filter: { sku: { eq: "24-MB05" }}
    search: "all"
  ) {
    items {
      name
      sku
      url_key
      image{
        url
      }
      stock_status
       __typename
      special_price
      price_range {
        
        minimum_price {
          regular_price {
            value
            currency
          }
        }
        maximum_price {
          regular_price {
            value
            currency
          }
          discount {
            amount_off
            percent_off
          }
          }
      }  
      ... on ConfigurableProduct {
        configurable_options {
          id
          attribute_id_v2
          label
          position
          use_default
          attribute_code
          values {
            uid
            value_index
            label
            swatch_data {
              value
            }
          }
          product_id
        }
        variants {
          product {
            id
            name
            sku
            attribute_set_id
            media_gallery {
              url
              label
            }
            ... on PhysicalProductInterface {
              weight
            }

            price_range {
              minimum_price {
                regular_price {
                  value
                  currency
                }
              }
              maximum_price {
                regular_price {
                  value
                  currency
                }
                discount {
                  amount_off
                  percent_off
                }
              }
            }
          }
          attributes {
            uid
            label
            code
            value_index
          }
        }
      }
    }
    total_count
    page_info {
      page_size
    }
  }
}
''';
}
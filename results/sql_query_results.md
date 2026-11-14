# SQL Results

_Output of `scripts/step2_run_sql_queries.py`._

## Q1: Revenue and average order value by gender

| gender   |   customers |   total_revenue |   avg_order_value |
|:---------|------------:|----------------:|------------------:|
| Male     |        2652 |          157890 |             59.54 |
| Female   |        1248 |           75191 |             60.25 |

## Q2: How many discount users still spent above the overall average order value?

|   high_spending_discount_users |   their_avg_spend |   overall_avg_spend |
|-------------------------------:|------------------:|--------------------:|
|                            839 |             79.79 |               59.76 |

## Q3: Top 5 products by average review rating

| item_purchased   |   avg_rating |   reviews |
|:-----------------|-------------:|----------:|
| Gloves           |         3.86 |       140 |
| Sandals          |         3.84 |       160 |
| Boots            |         3.82 |       144 |
| Hat              |         3.8  |       154 |
| T-shirt          |         3.78 |       147 |

## Q4: Average spend by shipping type

| shipping_type   |   orders |   avg_order_value |
|:----------------|---------:|------------------:|
| 2-Day Shipping  |      627 |             60.73 |
| Express         |      646 |             60.48 |
| Free Shipping   |      675 |             60.41 |
| Store Pickup    |      650 |             59.89 |
| Next Day Air    |      648 |             58.63 |
| Standard        |      654 |             58.46 |

## Q5: Do subscribers spend more than non-subscribers?

| subscription_status   |   customers |   avg_order_value |   total_revenue |   revenue_share_pct |
|:----------------------|------------:|------------------:|----------------:|--------------------:|
| No                    |        2847 |             59.87 |          170436 |                73.1 |
| Yes                   |        1053 |             59.49 |           62645 |                26.9 |

## Q6: Top 5 products most dependent on discounts

| item_purchased   |   discount_rate_pct |   orders |
|:-----------------|--------------------:|---------:|
| Hat              |                50   |      154 |
| Sneakers         |                49.7 |      145 |
| Coat             |                49.1 |      161 |
| Sweater          |                48.2 |      164 |
| Pants            |                47.4 |      171 |

## Q7: Customer lifecycle segments (New / Returning / Loyal)

| customer_segment   |   customers |   avg_order_value |   subscription_rate_pct |
|:-------------------|------------:|------------------:|------------------------:|
| Loyal              |        3116 |             59.54 |                    27.9 |
| Returning          |         701 |             60.93 |                    24.1 |
| New                |          83 |             58.47 |                    18.1 |

## Q8: Top 3 best-selling products in each category (window function)

| category    |   rnk | item_purchased   |   orders |
|:------------|------:|:-----------------|---------:|
| Accessories |     1 | Jewelry          |      171 |
| Accessories |     2 | Sunglasses       |      161 |
| Accessories |     2 | Belt             |      161 |
| Accessories |     3 | Scarf            |      157 |
| Clothing    |     1 | Pants            |      171 |
| Clothing    |     1 | Blouse           |      171 |
| Clothing    |     2 | Shirt            |      169 |
| Clothing    |     3 | Dress            |      166 |
| Footwear    |     1 | Sandals          |      160 |
| Footwear    |     2 | Shoes            |      150 |
| Footwear    |     3 | Sneakers         |      145 |
| Outerwear   |     1 | Jacket           |      163 |
| Outerwear   |     2 | Coat             |      161 |

## Q9: Subscription rate of repeat buyers (>5 previous purchases) vs others

| buyer_type        |   customers |   subscription_rate_pct |
|:------------------|------------:|------------------------:|
| Occasional (<=5)  |         424 |                    22.4 |
| Repeat buyer (>5) |        3476 |                    27.6 |

## Q10: Revenue contribution by age group

| age_group   |   customers |   total_revenue |   revenue_share_pct |
|:------------|------------:|----------------:|--------------------:|
| 18-30       |         949 |           57279 |                24.6 |
| 31-45       |        1093 |           64927 |                27.9 |
| 46-60       |        1135 |           67711 |                29.1 |
| 60+         |         723 |           43164 |                18.5 |

## Q11: Seasonal revenue by category - which category leads each season?

| season   | category    |   revenue |   share_of_season_pct |   rank_in_season |
|:---------|:------------|----------:|----------------------:|-----------------:|
| Fall     | Clothing    |     26220 |                  43.7 |                1 |
| Fall     | Accessories |     19874 |                  33.1 |                2 |
| Fall     | Footwear    |      8665 |                  14.4 |                3 |
| Fall     | Outerwear   |      5259 |                   8.8 |                4 |
| Spring   | Clothing    |     27692 |                  47.2 |                1 |
| Spring   | Accessories |     17007 |                  29   |                2 |
| Spring   | Footwear    |      9555 |                  16.3 |                3 |
| Spring   | Outerwear   |      4425 |                   7.5 |                4 |
| Summer   | Clothing    |     23078 |                  41.4 |                1 |
| Summer   | Accessories |     19028 |                  34.1 |                2 |
| Summer   | Footwear    |      9393 |                  16.8 |                3 |
| Summer   | Outerwear   |      4278 |                   7.7 |                4 |
| Winter   | Clothing    |     27274 |                  46.5 |                1 |
| Winter   | Accessories |     18291 |                  31.2 |                2 |
| Winter   | Footwear    |      8480 |                  14.5 |                3 |
| Winter   | Outerwear   |      4562 |                   7.8 |                4 |

## Q12: Top 10 states by revenue with running (cumulative) revenue share

| state         |   revenue |   cumulative_share_pct |
|:--------------|----------:|-----------------------:|
| Montana       |      5784 |                    2.5 |
| Illinois      |      5617 |                    4.9 |
| California    |      5605 |                    7.3 |
| Idaho         |      5587 |                    9.7 |
| Nevada        |      5514 |                   12.1 |
| Alabama       |      5261 |                   14.3 |
| New York      |      5257 |                   16.6 |
| North Dakota  |      5220 |                   18.8 |
| West Virginia |      5174 |                   21   |
| Nebraska      |      5172 |                   23.2 |

## Q13: Payment method preference by age group (share within each age group)

| age_group   | payment_method   |   customers |   share_pct |
|:------------|:-----------------|------------:|------------:|
| 18-30       | Cash             |         172 |        18.1 |
| 18-30       | Credit Card      |         161 |        17   |
| 18-30       | Bank Transfer    |         157 |        16.5 |
| 18-30       | Debit Card       |         156 |        16.4 |
| 18-30       | PayPal           |         154 |        16.2 |
| 18-30       | Venmo            |         149 |        15.7 |
| 31-45       | PayPal           |         197 |        18   |
| 31-45       | Venmo            |         195 |        17.8 |
| 31-45       | Credit Card      |         184 |        16.8 |
| 31-45       | Debit Card       |         178 |        16.3 |
| 31-45       | Cash             |         175 |        16   |
| 31-45       | Bank Transfer    |         164 |        15   |
| 46-60       | PayPal           |         218 |        19.2 |
| 46-60       | Cash             |         191 |        16.8 |
| 46-60       | Debit Card       |         189 |        16.7 |
| 46-60       | Credit Card      |         187 |        16.5 |
| 46-60       | Bank Transfer    |         176 |        15.5 |
| 46-60       | Venmo            |         174 |        15.3 |
| 60+         | Credit Card      |         139 |        19.2 |
| 60+         | Cash             |         132 |        18.3 |
| 60+         | Venmo            |         116 |        16   |
| 60+         | Bank Transfer    |         115 |        15.9 |
| 60+         | Debit Card       |         113 |        15.6 |
| 60+         | PayPal           |         108 |        14.9 |

## Q14: Customer value tiers - score each customer on spend, loyalty and frequency

| value_tier    |   customers |   avg_order_value |   avg_previous_purchases |   avg_purchases_per_year |   est_annual_revenue |
|:--------------|------------:|------------------:|-------------------------:|-------------------------:|---------------------:|
| 1. High value |         596 |             80.44 |                     38.2 |                     31.3 |          1.45788e+06 |
| 2. Mid value  |        2094 |             62.46 |                     27.2 |                     19.2 |          2.2508e+06  |
| 3. Low value  |        1210 |             44.91 |                     15.9 |                      8   |     366300           |

## Q15: Do discounts actually lift basket size? Avg spend with vs without discount, per category

| category    |   avg_with_discount |   avg_without_discount |   difference |
|:------------|--------------------:|-----------------------:|-------------:|
| Outerwear   |               55.32 |                  58.66 |        -3.34 |
| Accessories |               58.49 |                  60.89 |        -2.4  |
| Clothing    |               59.75 |                  60.22 |        -0.47 |
| Footwear    |               61.8  |                  59.08 |         2.72 |

## Q16: Estimated annual revenue by purchase frequency (order value x purchases per year)

| frequency_of_purchases   |   customers |   avg_order_value |   est_annual_revenue |
|:-------------------------|------------:|------------------:|---------------------:|
| Weekly                   |         539 |             58.97 |          1.65605e+06 |
| Bi-Weekly                |         547 |             60.69 |     866520           |
| Fortnightly              |         542 |             59.05 |     835383           |
| Monthly                  |         553 |             59.33 |     400282           |
| Every 3 Months           |         584 |             60.08 |     143861           |
| Quarterly                |         563 |             59.98 |     138461           |
| Annually                 |         572 |             60.17 |      34419           |

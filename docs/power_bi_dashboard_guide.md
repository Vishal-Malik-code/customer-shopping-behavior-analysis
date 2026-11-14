# Power BI Dashboard Guide

This guide covers three things:
1. **Part A:** opening the finished dashboard
2. **Part B:** rebuilding the same dashboard yourself, step by step
3. **Part C:** ideas for extending it

---

## Part A: Open the finished dashboard

1. Install **Power BI Desktop** (free, Windows).
2. Download and open `powerbi/Customer Shopping Dashboard.pbix`.
3. The data is already saved inside the file, so all visuals and slicers work straight away.
4. **Refresh (optional):** the report reads its data from this GitHub repository, so **Home > Refresh** works
   on any PC with internet access. If asked how to connect to `raw.githubusercontent.com`, choose **Anonymous > Connect**.
5. Expected values on the Overview page (all slicers cleared):

   | KPI | Value |
   |-----|-------|
   | Total Customers | 3,900 |
   | Total Revenue | $233K |
   | Avg Order Value | $59.76 |
   | Avg Review Rating | 3.75 |
   | Subscription Rate | 27.0% |
   | Discount Usage Rate | 43.0% |

No Power BI? See `powerbi/Customer Shopping Dashboard.pdf` or the screenshots in `powerbi/screenshots/`.

---

## Part B: Build it yourself

Start a **new blank report** and recreate the dashboard. Compare it with `powerbi/Customer Shopping Dashboard.pbix` as you go.

### Step 1: Get the data (Power Query)
1. **Home > Get data > Web**, then paste:
   ```
   https://raw.githubusercontent.com/Vishal-Malik-code/customer-shopping-behavior-analysis/main/data/processed/customer_shopping_data_clean.csv
   ```
   Then click **Transform Data**, not Load.
2. In Power Query:
   - Check the data types: whole number for IDs, amounts and counts; decimal number for `review_rating` and
     `est_purchases_per_year`; text for everything else.
   - **Rename the columns** to friendly names by double-clicking each header, for example `purchase_amount` > `Purchase Amount`
     and `location` > `State`.
   - Rename the query to **Customers**.
   - **Add Column > Custom Column** named `Season Order`:
     ```
     if [Season] = "Spring" then 1 else if [Season] = "Summer" then 2 else if [Season] = "Fall" then 3 else 4
     ```
     Do the same for `Segment Order`: New = 1, Returning = 2, Loyal = 3.
3. Repeat for the value tiers file, and name that query **Value Tiers**:
   ```
   https://raw.githubusercontent.com/Vishal-Malik-code/customer-shopping-behavior-analysis/main/results/customer_value_tiers.csv
   ```
   Add a `Tier Order` column: High value = 1, Mid value = 2, Low value = 3.
4. Click **Close & Apply**.

> **Note:** the data comes from a URL, so anyone can refresh the report. If you connect to
> PostgreSQL instead, use **Get data > PostgreSQL database** with server `localhost` and database `customer_behavior`.

### Step 2: Data model
1. Open **Model view** (the third icon on the left).
2. Drag `Customers[Customer ID]` onto `Value Tiers[Customer ID]` to create a relationship.
   Value Tiers should be on the **one (1)** side, so that choosing a value tier filters the customers.
3. **Sort by column**, so Season and Value Tier appear in a logical order rather than A-Z:
   - Select the `Season` column, then **Column tools > Sort by column > Season Order**.
   - Do the same for `Customer Segment` > `Segment Order` and `Value Tier` > `Tier Order`.
4. Hide the helper columns: right-click `Season Order`, `Segment Order` and `Tier Order` > **Hide in report view**.

### Step 3: DAX measures
Select the **Customers** table, then **New measure**, and paste each one:

```DAX
Total Revenue = SUM ( Customers[Purchase Amount] )
Total Customers = COUNTROWS ( Customers )
Avg Order Value = AVERAGE ( Customers[Purchase Amount] )
Avg Review Rating = AVERAGE ( Customers[Review Rating] )

Subscription Rate =
DIVIDE ( CALCULATE ( [Total Customers], Customers[Subscription Status] = "Yes" ), [Total Customers] )

Discount Usage Rate =
DIVIDE ( CALCULATE ( [Total Customers], Customers[Discount Applied] = "Yes" ), [Total Customers] )

AOV With Discount = CALCULATE ( [Avg Order Value], Customers[Discount Applied] = "Yes" )
AOV Without Discount = CALCULATE ( [Avg Order Value], Customers[Discount Applied] = "No" )

Est Annual Revenue =
SUMX ( Customers, Customers[Purchase Amount] * Customers[Est Purchases per Year] )

Customer Share % =
DIVIDE ( [Total Customers], CALCULATE ( [Total Customers], ALL ( 'Value Tiers' ) ) )

Annual Revenue Share % =
DIVIDE ( [Est Annual Revenue], CALCULATE ( [Est Annual Revenue], ALL ( 'Value Tiers' ) ) )

High Value Customers = CALCULATE ( [Total Customers], 'Value Tiers'[Value Tier] = "High value" )
High Value Revenue Share = CALCULATE ( [Annual Revenue Share %], 'Value Tiers'[Value Tier] = "High value" )
```
Set the formats under **Measure tools**: currency for revenue and order values, percentage for the rates and shares.

**What the key DAX ideas do:**
- `CALCULATE ( measure, filter )` re-calculates a measure with an extra filter, such as "only subscribers".
- `DIVIDE ( a, b )` is safe division: it returns blank instead of an error when `b` is 0.
- `SUMX ( table, expression )` works row by row, multiplying order value by purchases per year on each row, then adds the results up.
- `ALL ( 'Value Tiers' )` removes the value-tier filter, giving the "grand total" needed to calculate a share.

### Step 4: Theme
Go to **View > Themes > Browse for themes** and pick `powerbi/CustomerInsightsTheme.json`.
This gives every visual the navy and teal colours, white cards and rounded borders in one step.

### Step 5: Page 1, "Overview" (canvas 1280 × 720)
| Visual | Type | Fields |
|--------|------|--------|
| Header | Text box (navy background) | "Customer Shopping Behavior Dashboard" |
| Slicers (left column) | Slicer > Dropdown | Gender, Category, Season, Age Group, Subscription Status, Shipping Type |
| 6 KPI cards | Card | Total Customers, Total Revenue, Avg Order Value, Avg Review Rating, Subscription Rate, Discount Usage Rate |
| Revenue by Category | Clustered bar chart | Y-axis: Category; X-axis: Total Revenue |
| Revenue by Season | Clustered column chart | X-axis: Season; Y-axis: Total Revenue |
| Customers by Subscription | Donut chart | Legend: Subscription Status; Values: Total Customers |
| Revenue by Age Group | Clustered column chart | Age Group, Total Revenue |
| Customers by Payment Method | Clustered bar chart | Payment Method, Total Customers |
| Revenue by Customer Segment | Clustered column chart | Customer Segment, Total Revenue |

### Step 6: Page 2, "Customer Value & Discounts"
| Visual | Type | Fields |
|--------|------|--------|
| Header | Text box | "Customer Value & Discount Impact" |
| Slicers | Slicer > Dropdown | Gender, Category, Season, Age Group |
| 5 KPI cards | Card | High Value Customers, High Value Revenue Share, Est Annual Revenue, AOV With Discount, AOV Without Discount |
| Customers vs Revenue share | Clustered column chart | X-axis: Value Tier; Y-axis: Customer Share % **and** Annual Revenue Share % |
| Discount vs No Discount | Clustered column chart | X-axis: Category; Y-axis: Avg Order Value; Legend: Discount Applied |
| Revenue heatmap | Matrix | Rows: Category; Columns: Season; Values: Total Revenue. Then **Cell elements > Background color > on**, from light teal to teal |
| Subscription Rate by Segment | Clustered column chart | Customer Segment, Subscription Rate |

### Step 7: Finishing touches
- Turn on **data labels** for the charts (Format > Data labels).
- Add a **tooltip** or a subtitle to each chart that states its insight.
- Test that the slicers filter every visual.
- **File > Save as** your own `.pbix`.

---

## Part C: Ideas to add something new
- **Top N products:** a bar chart of the top 10 items by revenue. Use the visual's filter pane: *Filter type > Top N*.
- **Map page:** a filled map of revenue by State.
- **Drill-through page:** right-click a product to see its customers, ratings and discount rate.
- **What-if parameter:** "Discount reduction %", showing how revenue changes if discounts are cut.
- **Bookmarks and buttons:** switch between a "Revenue" view and a "Customers" view.
- **Dynamic title:** a DAX measure like `"Revenue for " & SELECTEDVALUE ( Customers[Category], "All Categories" )`.

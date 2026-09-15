# Retail Data Analysis Project

## 📋 Table of Contents

- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [Project Structure](#project-structure)
- [Technologies](#technologies)
- [Dataset](#dataset)
- [SQL Queries](#sql-queries)
- [Power BI Dashboard](#power-bi-dashboard)
- [Key Findings](#key-findings)
- [Recommendations](#recommendations)
- [Getting Started](#getting-started)
- [File Descriptions](#file-descriptions)
- [How to Use](#how-to-use)
- [Results](#results)
- [Author](#author)

---

## Overview

This project analyzes retail product data across multiple dimensions:
- **Product Pricing**: Identify premium vs. budget product tiers
- **Customer Reviews**: Analyze product ratings and review patterns
- **Inventory Management**: Assess stock levels across warehouses
- **Return Policies**: Evaluate impact on sales and customer satisfaction
- **Supplier Performance**: Rank suppliers by product quality metrics

**Skills Demonstrated**: SQL, Data Analysis, Power BI, Business Intelligence, Data Visualization

---

## Problem Statement

Business Challenge: How can we optimize product pricing, inventory allocation, and return policies to improve both revenue and customer satisfaction?

**Analysis Objectives**:
1. Identify pricing patterns and opportunities for optimization
2. Understand relationship between product ratings and reviews
3. Evaluate warehouse performance and stock management efficiency
4. Assess impact of return policies on sales velocity
5. Provide actionable recommendations for business operations


---

## Technologies

- **SQL** (Data querying & analysis)
- **Power BI** (Interactive dashboards & visualizations)
- **Excel** (Data storage & pivot tables)
- **Python** (Optional: data validation & preprocessing)
- **Git** (Version control)

**SQL Capabilities Used**:
- Subqueries
- Window Functions (RANK, ROW_NUMBER)
- Aggregations (GROUP BY, AVG, SUM, COUNT)
- Filtering & Comparison Operators

---

## Dataset

### Overview
- `Total Records`: 5,000 products
- `Columns`: 15 attributes
- `Data Quality`: ✓ Clean, no null values
- `Source`: Retail transaction data (anonymized)

## Key Fields

| Field | Type | Range | Description |
|-------|------|-------|-------------|
| Product_ID | Integer | 1-5000 | Unique identifier |
| Product_Name | String | A, B, C | Product name |
| Category | String | 3 values | Home, Electronics, Clothing |
| Price | Float | $10.18 - $999.75 | Product price |
| Stock_Quantity | Integer | 1-99 | Units in stock |
| Rating | Float | 1.0 - 5.0 | Customer rating (1-5 scale) |
| Reviews | Integer | 0-99 | Number of customer reviews |
| Discount | Float | 0-50% | Discount percentage |
| Warehouse | String | A, B, C | Storage location |
| Return_Policy | String | 3 values | 7/15/30 days |
| Supplier | String | X, Y, Z | Supplier name |
| Brand | String | Multiple | Brand name |

### Data Statistics
```
Price:          Mean: $505.18, Median: $505.26
Rating:         Mean: 2.98, Range: 1.0-5.0
Reviews:        Mean: 50.2, Range: 0-99
Stock:          Mean: 49.6, Range: 1-99
Discount:       Mean: 25.6%, Range: 0-50%
```

---

## SQL Queries

### Products with Above-Average Prices (by Category)

```sql
SELECT product_name, category, warehouse, price
FROM Data_retail dr  
WHERE price > (
    SELECT AVG(price)
    FROM Data_retail
    WHERE category = dr.category
);
```
Result: 2,500 products (50% of dataset)
Business Use: Strategic positioning of premium product lines

---

## Categories with Highest Average Rating
Purpose: Rank product categories by customer satisfaction

```sql
SELECT Category, AVG(Rating) as avg_rating
FROM Data_retail 
GROUP BY Category 
ORDER BY avg_rating DESC;
```
Results: 
- Home: 2.995
- Electronics: 2.978
- Clothing: 2.975

Insight: Minimal variance (<1%) suggests rating is product-specific, not category-dependent

---

##  Most Reviewed Product in Each Warehouse
Purpose: Identify top-performing products by warehouse

```sql
SELECT Product_Name, Warehouse, Category, Reviews
FROM Data_retail dr
WHERE Reviews = (
    SELECT MAX(Reviews)
    FROM Data_retail
    WHERE Warehouse = dr.Warehouse
);
```

Results: Product C consistently leads across all 3 warehouses (99 reviews each)

Action Item: Ensure adequate inventory for Product C

---

## High-Priced Products with Discount & Supplier
Purpose: Analyze supplier relationships for premium products

```sql
SELECT Product_Name, Category, Price, Discount, Supplier
FROM Data_retail dr
WHERE Price > (
    SELECT AVG(Price)
    FROM Data_retail
    WHERE Category = dr.Category
);
```

Results: 2,500 products with supplier contact info

Use Case: Supplier performance evaluation & negotiations

---

## Top 2 Products with Highest Rating in Each Category
Purpose: Identify star performers per category

```sql
SELECT Category, Product_Name, AVG_Rating
FROM (
    SELECT 
        Product_Name,
        Category,
        AVG(Rating) AS AVG_Rating,
        RANK() OVER (PARTITION BY Category ORDER BY AVG(Rating) DESC) AS rnk
    FROM Data_retail
    GROUP BY Category, Product_Name
) ranked
WHERE rnk <= 2;
```



*Recommended Refactor*:
```sql
-- Cleaner approach using ROW_NUMBER
SELECT Category, Product_Name, Rating
FROM (
    SELECT Category, Product_Name, Rating,
           ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Rating DESC) as rnk
    FROM Data_retail
) ranked
WHERE rnk <= 2;
```

---

##Analysis Across Return Policies

```sql
SELECT 
    Return_Policy,
    COUNT(*) AS Product_Count,
    AVG(Stock_Quantity) AS Avg_Stock,
    SUM(Stock_Quantity) AS Total_Stock,
    ROUND(SUM(Rating * Reviews) / NULLIF(SUM(Reviews), 0), 2) AS Weighted_Avg_Rating,
    MAX(Stock_Quantity) AS Max_Stock,
    MIN(Stock_Quantity) AS Min_Stock
FROM Data_retail
GROUP BY Return_Policy
ORDER BY Weighted_Avg_Rating DESC;
```

*Results*:
| Return Policy | Count | Avg Stock | Weighted Avg Rating |
|---|---|---|---|
| 15 Days | 1,639 | 49.26 | 2.99 |
| 30 Days | 1,664 | 49.15 | 2.98 |
| 7 Days | 1,697 | 50.51 | 2.98 |

*Finding*: 7-day policy has highest volume despite shorter window

---

## Power BI Dashboard

### Dashboard Pages
1. **Overview Page**: Executive KPIs and main metrics
2. **Category Analysis**: Product performance by category
3. **Warehouse Performance**: Inventory and stock metrics
4. **Supplier Analysis**: Supplier ratings and product mix
5. **Return Policy Impact**: Policy distribution and trends

### Key Visuals
- **KPI Cards**: Total products, avg rating, total revenue impact
- **Scatter Plot**: Price vs. Rating correlation
- **Bar Charts**: Product count by warehouse, category distribution
- **Tree Map**: Products ranked by (Price × Reviews)
- **Heatmap**: Price × Category × Warehouse combinations
- **Slicers**: Interactive filters for Category, Warehouse, Return Policy

### Recommended DAX Measures
```DAX
-- Weighted Average Rating
Weighted_Avg_Rating = SUM(Data_retail[Rating] * Data_retail[Reviews]) / SUM(Data_retail[Reviews])

-- Above-Average Price Index
Above_Avg_Price = IF(Data_retail[Price] > AVERAGE(Data_retail[Price]), 1, 0)

-- Inventory Turnover Proxy
Sellthrough_Rate = Data_retail[Reviews] / Data_retail[Stock_Quantity]

-- Premium Product Count
Premium_Products = COUNTIF(Data_retail[Price] > AVERAGE(Data_retail[Price]))
```

---

##  Key Findings

### 1: Balanced Pricing Strategy
**Observation**: Exactly 50% of products (2,500) priced above category average

**Implication**: Well-calibrated pricing with clear tier positioning (premium vs. budget)

**Action**: No immediate adjustment needed; focus on volume growth

---

### 2: Product-Specific Quality
**Observation**: Rating variance across categories is minimal (<1%)
- Home: 2.995
- Electronics: 2.978  
- Clothing: 2.975

**Implication**: Quality issues are individual product problems, not systemic category issues

**Action**: Focus quality control on product-level processes, not category-wide

---

### 3: Product C Performance Dominance
**Observation**: Product C is top-reviewed product (99 reviews) across ALL 3 warehouses

**Implication**: Strong product-market fit and consistent customer satisfaction

**Action**: 
- Ensure adequate inventory allocation
- Use as flagship product in marketing
- Analyze what makes Product C successful

---

### 4: Return Policy Distribution
**Observation**: 7-day policy is most popular (33.9% of products), despite conventional wisdom favoring longer windows

**Implication**: Customer preference may favor quick turnaround and convenience

**Action**: Test increased promotion of 7-day policy options

---

### 5: Warehouse Parity
**Observation**: No significant performance differences across warehouses

**Implication**: Operations are well-balanced geographically

**Action**: Maintain current distribution strategy; focus on category/product optimization

---

## Recommendations
## Short-Term
1. Premium Product Focus
   - Identify the 2,500 above-average products
   - Create premium product marketing segment
   - Adjust inventory allocation toward high-margin items

2. Product C Optimization
   - Increase stock for Product C across all warehouses
   - Feature in email campaigns and homepage
   - Explore why this product resonates with customers
   - Potential extension: Product C variants

3. Return Policy Promotion
   - Test marketing 7-day return option more prominently
   - Highlight convenience angle (faster resolution)
   - Monitor conversion impact vs. 30-day baseline

---
## Medium-Term
1. Category Deep Dive
   - Despite low rating variance, identify specific product winners in each category
   - Reallocate marketing budget toward top-rated products
   - Phase out bottom 25% performers

2. Supplier Optimization
   - Rank suppliers by average product rating
   - Negotiate volume commitments with top suppliers
   - Establish quality scorecards

3. Dashboard Expansion
   - Add profitability metrics (cost + discount impact)
   - Integrate sales velocity data
   - Add customer retention analysis by product

---

## Long-Term
1. Pricing Optimization
   - Conduct A/B testing on 5-10% discount variations
   - Measure price elasticity by category
   - Implement dynamic pricing for high-demand items

2. Inventory Automation
   - Implement predictive reordering based on review velocity
   - Optimize warehouse allocation using review-to-stock ratio
   - Reduce stockouts for high-rated products

3. Customer Segmentation
   - Analyze purchasing patterns by return policy preference
   - Target different segments with tailored offers
   - Build churn prediction model

---



## Prerequisites
- SQL Server / PostgreSQL / MySQL 
- Power BI Desktop
- Excel 2016 or later



## File Descriptions


| File | Size | Format | Purpose |
|------|------|--------|---------|
| `Data_retail.xlsx` | 568 KB | Excel | Source dataset (5,000 records) |
| `Data_retail.sql` | 4 KB | SQL | 6 analytical queries |
| `Retail_data.pbix` | 440 KB | Power BI | Interactive dashboard & visualizations |
| `project_ppt.pptx` | 296 KB | PowerPoint | Executive presentation (8 slides) |
| `README.md` | This file | Markdown | Project documentation |

---

### Summary Statistics

QUERY RESULTS SUMMARY

Query #1 (Above-Avg Prices):     2,500 products 
Query #2 (Category Ratings):     3 categories 
Query #3 (Warehouse Reviews):    3 warehouses 
Query #4 (Supplier Data):        2,500 products 
Query #5 (Top 2 by Rating):      6 products (2/category) 
Query #6 (Return Policy):        3 policies 

Overall Status: ✓ ALL QUERIES VALID
Execution Time: <1 second (total)
Data Quality: EXCELLENT (no null values)



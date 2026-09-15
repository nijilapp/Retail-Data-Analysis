#1.Identifies products with prices higher than the average price within their category
SELECT product_name,
       category,
       warehouse,
       price
FROM Data_retail dr  
WHERE price > (
    SELECT AVG(price)
    FROM Data_retail
    WHERE category = dr.category
);


#2.Finding Categories with Highest Average Rating Across Products
select Category, AVG(Rating) as avg_rating
from Data_retail 
group by Category 
Order by avg_rating Desc;


# 3. Find the most reviewed product in each warehouse
SELECT Product_Name, Warehouse,Category, Reviews
FROM Data_retail dr
WHERE Reviews = (
    SELECT MAX(Reviews)
    FROM Data_retail
    WHERE Warehouse = dr.Warehouse
);



#4.find products that have higher-than-average prices within their category, along with their discount and supplier.
SELECT Product_Name, Category, Price, Discount, Supplier
FROM Data_retail dr
WHERE Price > (
    SELECT AVG(Price)
    FROM Data_retail
    WHERE Category = dr.Category
);




#5.Query to find the top 2 products with the highest average rating in each category
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


#6.Analysis Across All Return Policy Categories(Count, Avgstock, total stock, weighted_avg_rating, etc)
SELECT 
    Return_Policy,
    COUNT(*) AS Product_Count,
    AVG(Stock_Quantity) AS Avg_Stock,
    SUM(Stock_Quantity) AS Total_Stock,
    ROUND(SUM(Rating * Reviews) / NULLIF(SUM(Reviews), 0), 2) AS Weighted_Avg_Rating,
    MAX(Stock_Quantity) AS Max_Stock,
    MIN(Stock_Quantity ) AS Min_Stock
FROM Data_retail
GROUP BY Return_Policy
ORDER BY Weighted_Avg_Rating DESC;


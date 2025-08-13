CREATE TABLE zepto(
		            sku_id SERIAL PRIMARY KEY,
					category VARCHAR(120),
					name VARCHAR(150) NOT NULL,
					mrp NUMERIC(8,2),
					discountPercent NUMERIC(5,2),
					availableQuantity INTEGER,
					discountedSellingPrice NUMERIC(8,2),
					weightInGms INTEGER,
					outOfStock BOOLEAN,
					quantity INTEGER
);

-- Data exploreation
SELECT * FROM zepto;

--null values
SELECT * FROM zepto 
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountpercent IS NULL
OR
discountedsellingprice IS NULL
OR
weightingms IS NULL
OR
availablequantity IS NULL
OR
outofstock IS NULL
OR
quantity IS NULL

--different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--products in stock vs out of stock
SELECT outofstock, COUNT(sku_id)
FROM zepto
GROUP BY outofstock;

--product names present multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

--data cleaning

--products with price = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

--converting paisa into rupees(in the original csv file)
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

SELECT * FROM zepto;

--Real life business queries

--1. top 10 best valued products, based on the discount percentage
SELECT DISTINCT name, mrp, discountpercent 
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;

--2. what are the products with high mrp but out of stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE AND mrp > 300
ORDER BY mrp DESC;

--3. estimated revenue for each category
SELECT category, SUM(discountedSellingPrice * quantity) AS estimated_revenue
FROM zepto
WHERE outOfStock = FALSE
GROUP BY category
ORDER BY estimated_revenue;

--4. find all products where mrp > 500 and discount < 10 %
SELECT DISTINCT name, mrp, discountpercent
FROM zepto
WHERE mrp > 500 AND discountpercent < 10
ORDER BY mrp DESC, discountpercent DESC;

--5. top 5 categories offering the highest average discount percentage
SELECT category, ROUND (AVG(discountpercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

--6. find the price per gram for products above 100g sort by best value
SELECT DISTINCT name, weightInGms, discountedsellingprice,
ROUND(discountedsellingprice / weightingms , 2) AS price_per_gram
FROM zepto
WHERE weightingms >= 100
ORDER BY price_per_gram;

--7. group the products into categories like low, medium, bulk.
SELECT name, weightingms,
       CASE WHEN weightingms < 1000 THEN 'low'
            WHEN weightingms < 5000 THEN 'medium'
            ELSE 'bulk' END AS weight_category
FROM zepto;

--8. what is the total inventory weight per category
SELECT 
    category,
    SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto
WHERE outOfStock = FALSE
GROUP BY category

ORDER BY total_inventory_weight;

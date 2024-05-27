

select * from Coffee_Shop_Sales

-- Total Sales For Month May

SELECT  
	ROUND(SUM(transaction_qty * unit_price),1) as total_Sales
FROM 
	Coffee_Shop_Sales
WHERE 
	month(transaction_date) = 5  -- MAY Month

-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT 
	MONTH(transaction_date) as Month ,
	ROUND(SUM(transaction_qty*unit_price),1) as Total_Sales,
	ROUND((SUM(transaction_qty*unit_price) - 
	LAG(SUM(transaction_qty*unit_price),1) OVER(ORDER BY MONTH(transaction_date)))
	/
	LAG(SUM(transaction_qty*unit_price),1) OVER(ORDER BY MONTH(transaction_date)) *100,1) AS Mom_increase_percentage 
FROM Coffee_Shop_Sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

-- TOTAL ORDERS FOR MONTH MAY

SELECT
	COUNT(*) AS total_orders
FROM 
	Coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5;

-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT
	  MONTH(transaction_date) AS month,
	  COUNT(transaction_id) as total_orders,
      1.0 * (COUNT(transaction_id) - LAG(COUNT(transaction_id),1) OVER(ORDER BY MONTH(transaction_date))) /
	  LAG(COUNT(transaction_id),1) OVER(ORDER BY MONTH(transaction_date)) * 100 As mom_increase_percentage
FROM 
	Coffee_Shop_Sales
WHERE 
	MONTH(transaction_date) IN (4,5)
GROUP BY  MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

-- TOTAL QUANTITY SOLD IN MONTH MAY

SELECT		
	SUM(transaction_qty) AS Total_quantity_Sold
FROM	
	Coffee_Shop_Sales
WHERE	
	MONTH(transaction_date) = 5 -- MAY MONTH

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT MONTH(transaction_date) as month , 
	   SUM(transaction_qty) as Total_quantity_sold,
	1.0 * (SUM(transaction_qty) - LAG(SUM(transaction_qty),1) OVER(ORDER BY MONTH(transaction_date)))/
	LAG(SUM(transaction_qty),1) OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_percentage_increase
From 
	Coffee_Shop_Sales
WHERE 
	MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS

SELECT	
	SUM(transaction_qty*unit_price) AS Daily_sales,
	SUM(transaction_qty) AS Quantity,
	COUNT(transaction_id) AS Orders
FROM 
	coffee_shop_sales
WHERE
	transaction_date = '2023-05-18'; 

-- If you want to get exact Rounded off values then use below query to get the result:

select 
	  CONCAT(ROUND(SUM (transaction_qty * unit_price)/1000,1),'k') AS Daily_sales,
	  CONCAT(ROUND(SUM(transaction_qty)/1000,2),'k') AS Quantity,
	  CONCAT(ROUND(COUNT(transaction_id)/1000,2),'k') AS Orders
FROM
	coffee_shop_sales
WHERE
	transaction_date = '2023-05-18';

-- SALES TREND OVER PERIOD

SELECT 
	AVG(total_Sales) AS average_Sales 
FROM 
	(SELECT 
		SUM(transaction_qty * unit_price) AS total_Sales
	FROM
		coffee_shop_sales
	WHERE
		MONTH(transaction_date) = 5
	GROUP BY 
			transaction_date ) AS internal_query


-- Daily Sales for MAY Month selected

SELECT 
	DAY(transaction_date) AS Day_of_month , 
	SUM(unit_price*transaction_qty) AS total_Sales
FROM 
	coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5
GROUP BY 
	DAY(transaction_date)
ORDER BY
	DAY(transaction_date)

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

SELECT  
	DAY(transaction_date) AS Day_of_month,
	AVG(SUM(transaction_qty * unit_price)) OVER() AS Average_Sales,
	SUM(transaction_qty * unit_price) AS Daily_sales,
CASE 
	WHEN SUM(transaction_qty * unit_price) > AVG(SUM(transaction_qty * unit_price)) OVER() THEN  'Above Average' 
	When SUM(transaction_qty * unit_price) < AVG(SUM(transaction_qty * unit_price)) OVER() THEN  'Below Average'
	ELSE 'No Change' 
	END AS Sales_Status
FROM
	coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5
GROUP BY DAY(transaction_Date)
ORDER BY DAY(transaction_Date)

-- OR 

select Day_of_month , 
	CASE WHEN Daily_Sales > Average_sales THEN 'Above Average'
		 WHEN Daily_Sales < Average_sales THEN 'Below Average'
		 Else 'No Change'
		 End as Sales_Status,
		 Daily_Sales
FROM 
	(select day(transaction_date) as Day_of_month,
			avg(sum(transaction_qty*unit_price)) over() as Average_sales,
			sum(transaction_qty*unit_price) as Daily_Sales
			from coffee_shop_sales
			where month(transaction_date) = 5 
			group by day(transaction_date)) as inner_query
order by Day_of_month

-- SALES BY WEEKDAY / WEEKEND:

SELECT
		CASE 
			WHEN  DATEPART (WEEKDAY,transaction_date) IN (1,7) THEN 'Weekends'
			ELSE 'Weekdays'
			END AS day_type,
			ROUND (SUM(transaction_qty * unit_price),2) AS Total_Sales
		FROM
			coffee_Shop_Sales
		WHERE
			MONTH(transaction_date) = 5
		GROUP BY 
			CASE WHEN  DATEPART (WEEKDAY,transaction_date) IN (1,7) THEN 'Weekends'
			Else 'Weekdays'
			END 

-- SALES BY STORE LOCATION

SELECT store_location , 
	    ROUND ( SUM (unit_price * transaction_qty),2) AS Total_Sales 
FROM   
		coffee_shop_sales
WHERE   
		MONTH(transaction_date) = 5
GROUP BY
		store_location
ORDER BY
		Total_Sales  DESC

-- SALES BY PRODUCT CATEGORY

SELECT product_category,
	ROUND(SUM (unit_price * transaction_qty),1) AS Total_Sales 
FROM
	coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5
GROUP BY
	product_category
ORDER BY
	Total_Sales  DESC

-- SALES BY PRODUCTS (TOP 10)

SELECT TOP 10 product_type,
	  ROUND(SUM (unit_price * transaction_qty),1) AS Total_Sales
FROM
	coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5
GROUP BY
	product_type
ORDER BY
	Total_Sales DESC


-- SALES BY DAY | HOUR

Select  ROUND (SUM(unit_price * transaction_qty),1) AS Total_Sales ,
		SUM(transaction_qty) AS Total_Quantity ,
		COUNT(*) AS Total_Orders 
FROM 
		coffee_shop_sales
	WHERE
		DATEPART(WEEKDAY , transaction_date) = 3  -- Tuesday ( 1 - Sunday to 7 - Saturday)
		AND DATEPART (HOUR ,transaction_time) = 8
			AND Month(transaction_date) = 5;


-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY


SELECT 
    CASE 
        WHEN Datepart(weekday,transaction_date) = 2 THEN 'Monday'
        WHEN Datepart(weekday,transaction_date) = 3 THEN 'Tuesday'
        WHEN Datepart(weekday,transaction_date) = 4 THEN 'Wednesday'
        WHEN Datepart(weekday,transaction_date) = 5 THEN 'Thursday'
        WHEN Datepart(weekday,transaction_date) = 6 THEN 'Friday'
        WHEN Datepart(weekday,transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty),2) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN Datepart(weekday,transaction_date) = 2 THEN 'Monday'
        WHEN Datepart(weekday,transaction_date) = 3 THEN 'Tuesday'
        WHEN Datepart(weekday,transaction_date) = 4 THEN 'Wednesday'
        WHEN Datepart(weekday,transaction_date) = 5 THEN 'Thursday'
        WHEN Datepart(weekday,transaction_date) = 6 THEN 'Friday'
        WHEN Datepart(weekday,transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;


	
-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY

SELECT Datepart(HOUR,transaction_time) AS Hour,
	ROUND(SUM(unit_price* transaction_qty),1) AS Total_Sales
FROM 
	coffee_shop_sales
WHERE	
	MONTH(transaction_date) = 5
GROUP BY
	Datepart(HOUR,transaction_time)
ORDER BY
	Datepart(HOUR,transaction_time)
	

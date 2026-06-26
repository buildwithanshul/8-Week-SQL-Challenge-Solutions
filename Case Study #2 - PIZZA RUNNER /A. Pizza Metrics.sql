--   This case study has LOTS of questions - they are broken up by area of focus including:

-- Pizza Metrics
-- Runner and Customer Experience
-- Ingredient Optimisation
-- Pricing and Ratings
-- Bonus DML Challenges (DML = Data Manipulation Language)

select * from runner_orders_temp;
select * from runners;
select * from customer_orders_temp;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;



-- A. Pizza Metrics

--1.How many pizzas were ordered?
--2.How many unique customer orders were made?
--3.How many successful orders were delivered by each runner?
--4.How many of each type of pizza was delivered?
--5.How many Vegetarian and Meatlovers were ordered by each customer?
--6.What was the maximum number of pizzas delivered in a single order?
--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--8.How many pizzas were delivered that had both exclusions and extras?
--9.What was the total volume of pizzas ordered for each hour of the day?
--10.What was the volume of orders for each day of the week?


-- 1.How many pizzas were ordered?
SELECT
	COUNT(PIZZA_ID) AS PIZZA_ORDERED
FROM
	CUSTOMER_ORDERS_TEMP;


-- 2.How many unique customer orders were made?
SELECT
	COUNT(DISTINCT ORDER_ID) AS UNIQUE_ORDER
FROM
	CUSTOMER_ORDERS_TEMP;

	
-- 3.How many successful orders were delivered by each runner?
SELECT
	RUNNER_ID,
	COUNT(ORDER_ID)
FROM
	RUNNER_ORDERS
WHERE
	DISTANCE != '0'
GROUP BY
	RUNNER_ID
ORDER BY
	RUNNER_ID;


-- 4.How many of each type of pizza was delivered?
SELECT
	N.PIZZA_NAME,
	COUNT(CO.ORDER_ID) AS AMOUNT_DELIVERED
FROM
	PIZZA_NAMES N
	JOIN CUSTOMER_ORDERS_TEMP CO ON CO.PIZZA_ID = N.PIZZA_ID
GROUP BY
	N.PIZZA_NAME;


-- 5.How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
	CO.CUSTOMER_ID,
	N.PIZZA_NAME,
	COUNT(ORDER_ID) AS PIZZA_ORDERED
FROM
	CUSTOMER_ORDERS_TEMP CO
	JOIN PIZZA_NAMES N ON CO.PIZZA_ID = N.PIZZA_ID
GROUP BY
	CO.CUSTOMER_ID,
	N.PIZZA_NAME
ORDER BY
	CO.CUSTOMER_ID ASC;



-- 6.What was the maximum number of pizzas delivered in a single order?
WITH
	PIZZA_COUNT_CTE AS (
		SELECT
			C.ORDER_ID,
			COUNT(C.PIZZA_ID) AS PIZZA_PER_ORDER
		FROM
			CUSTOMER_ORDERS_TEMP AS C
			JOIN RUNNER_ORDERS_TEMP AS R ON C.ORDER_ID = R.ORDER_ID
		WHERE
			R.DISTANCE != '0'
		GROUP BY
			C.ORDER_ID
	)
SELECT
	MAX(PIZZA_PER_ORDER) AS PIZZA_COUNT
FROM
	PIZZA_COUNT_CTE;


-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT
	C.CUSTOMER_ID,
	SUM(
		CASE
			WHEN C.EXCLUSIONS <> ''
			OR C.EXTRAS <> '' THEN 1
			ELSE 0
		END
	) AS AT_LEAST_1_CHANGE,
	SUM(
		CASE
			WHEN C.EXCLUSIONS = ''
			AND C.EXTRAS = '' THEN 1
			ELSE 0
		END
	) AS NO_CHANGE
FROM
	CUSTOMER_ORDERS_TEMP AS C
	JOIN RUNNER_ORDERS_TEMP AS R ON C.ORDER_ID = R.ORDER_ID
WHERE
	R.DISTANCE != '0'
GROUP BY
	C.CUSTOMER_ID
ORDER BY
	C.CUSTOMER_ID;



-- 8.How many pizzas were delivered that had both exclusions and extras?
SELECT
	SUM(
		CASE
			WHEN C.EXCLUSIONS <> ''
			AND C.EXTRAS <> '' THEN 1
			ELSE 0
		END
	) AS PIZZA_W_EXCLUSIONS_N_EXTRAS
FROM
	CUSTOMER_ORDERS_TEMP C
	JOIN RUNNER_ORDERS_TEMP R ON C.ORDER_ID = R.ORDER_ID
WHERE
	DISTANCE != '0';


-- 9.What was the total volume of pizzas ordered for each hour of the day?
SELECT
	EXTRACT(
		HOUR
		FROM
			ORDER_TIME
	) AS HOUR_OF_DAY,
	COUNT(ORDER_ID) AS PIZZA_COUNT
FROM
	CUSTOMER_ORDERS_TEMP
GROUP BY
	EXTRACT(
		HOUR
		FROM
			ORDER_TIME
	)
ORDER BY
	EXTRACT(
		HOUR
		FROM
			ORDER_TIME
	);


-- 10.What was the volume of orders for each day of the week?
SELECT
	EXTRACT(
		DOW
		FROM
			ORDER_TIME
	) AS DAY_NUMBER,
	TO_CHAR(ORDER_TIME, 'Day') AS DAY_OF_WEEK,
	COUNT(ORDER_ID) AS TOTAL_PIZZAS_ORDERED
FROM
	CUSTOMER_ORDERS_TEMP
GROUP BY
	DAY_NUMBER,
	DAY_OF_WEEK
ORDER BY
	DAY_NUMBER;






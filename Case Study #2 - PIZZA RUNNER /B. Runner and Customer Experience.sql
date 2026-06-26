
--B. Runner and Customer Experience

select * from runner_orders_temp;
select * from runners;
select * from customer_orders_temp;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
--4.What was the average distance travelled for each customer?
--5.What was the difference between the longest and shortest delivery times for all orders?
--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
--7.What is the successful delivery percentage for each runner?


--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
	(
		DATE_TRUNC('week', REGISTRATION_DATE + INTERVAL '3 days') - INTERVAL '3 days'
	)::DATE AS WEEK_START,
	COUNT(RUNNER_ID) AS NUMBER_OF_RUNNERS
FROM
	RUNNERS
GROUP BY
	1
ORDER BY
	1;


--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH
	ARRIVAL_CTE AS (
		SELECT
			R.RUNNER_ID,
			(CAST(R.PICKUP_TIME AS TIMESTAMP) - C.ORDER_TIME) AS TIME_TAKEN
		FROM
			RUNNER_ORDERS_TEMP R
			JOIN CUSTOMER_ORDERS_TEMP C ON C.ORDER_ID = R.ORDER_ID
		WHERE
			R.PICKUP_TIME <> ''
		GROUP BY
			1,
			2
	)
SELECT
	RUNNER_ID,
	AVG(TIME_TAKEN) AS AVG_PICKUP_TIME
FROM
	ARRIVAL_CTE
GROUP BY
	1;

	
--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH
	ARRIVAL_CTE AS (
		SELECT
			C.ORDER_ID,
			COUNT(C.PIZZA_ID) AS PIZZA_ORDERED,
			(CAST(R.PICKUP_TIME AS TIMESTAMP) - C.ORDER_TIME) AS TIME_TAKEN
		FROM
			RUNNER_ORDERS_TEMP R
			JOIN CUSTOMER_ORDERS_TEMP C ON C.ORDER_ID = R.ORDER_ID
		WHERE
			R.PICKUP_TIME <> ''
		GROUP BY
			1,
			3
	)
SELECT
	PIZZA_ORDERED,
	AVG(TIME_TAKEN) AS AVG_PICKUP_TIME
FROM
	ARRIVAL_CTE
GROUP BY
	1
ORDER BY
	1;
	

--4.What was the average distance travelled for each customer?
SELECT
	C.CUSTOMER_ID,
	AVG(R.DISTANCE) AS AVG_DISTANCE
FROM
	CUSTOMER_ORDERS_TEMP C
	JOIN RUNNER_ORDERS_TEMP R ON C.ORDER_ID = R.ORDER_ID
WHERE
	R.DISTANCE <> '0'
GROUP BY
	1
ORDER BY
	1;


--5.What was the difference between the longest and shortest delivery times for all orders?
SELECT
	MIN(DURATION) MINIMUM_DURATION,
	MAX(DURATION) AS MAXIMUM_DURATION,
	MAX(DURATION) - MIN(DURATION) AS MAXIMUM_DIFFERENCE
FROM
	RUNNER_ORDERS_TEMP
WHERE
	DURATION <> '0';


--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
	RUNNER_ID,
	(DISTANCE * 60 / DURATION) AS AVG_SPEED_INKM
FROM
	RUNNER_ORDERS_TEMP
WHERE
	DISTANCE <> '0'
ORDER BY
	RUNNER_ID;


--7.What is the successful delivery percentage for each runner?
SELECT
	RUNNER_ID,
	COUNT(*) AS TOTAL_ORDERS,
	ROUND(
		100 * SUM(
			CASE
				WHEN PICKUP_TIME <> '' THEN 1
				ELSE 0
			END
		) / COUNT(*)
	) AS SUCCESS_DELIVERIES
FROM
	RUNNER_ORDERS_TEMP
GROUP BY
	RUNNER_ID
ORDER BY
	RUNNER_ID;






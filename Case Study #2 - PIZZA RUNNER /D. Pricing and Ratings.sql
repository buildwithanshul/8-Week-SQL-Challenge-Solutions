
-- D. Pricing and Ratings


-- 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
-- 2.What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
-- 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
-- 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
-- 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?


select * from runner_orders_temp;
select * from runners;
select * from customer_orders_temp;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;


-- 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT
	MEAT_LOVER_SUM,
	VEGETRIAN_SUM,
	(MEAT_LOVER_SUM + VEGETRIAN_SUM) AS TOTAL_REVENUE
FROM
	(
		SELECT
			SUM(
				CASE
					WHEN C.PIZZA_ID = 1 THEN 12
					ELSE 0
				END
			) AS MEAT_LOVER_SUM,
			SUM(
				CASE
					WHEN C.PIZZA_ID = 2 THEN 10
					ELSE 0
				END
			) AS VEGETRIAN_SUM
		FROM
			CUSTOMER_ORDERS_TEMP C
			JOIN RUNNER_ORDERS_TEMP R ON C.ORDER_ID = R.ORDER_ID
		WHERE
			R.DISTANCE <> '0'
	) AS T;


-- 2.What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
SELECT
	ARRAY_LENGTH(STRING_TO_ARRAY(EXTRAS, ','), 1)
FROM
	CUSTOMER_ORDERS_TEMP;

SELECT
	MEAT_LOVER_SUM,
	VEGETRIAN_SUM,
	EXTRAS_REVENUE,
	(MEAT_LOVER_SUM + VEGETRIAN_SUM + EXTRAS_REVENUE) AS TOTAL_REVENUE
FROM
	(
		SELECT
			SUM(
				CASE
					WHEN C.PIZZA_ID = 1 THEN 12
					ELSE 0
				END
			) AS MEAT_LOVER_SUM,
			SUM(
				CASE
					WHEN C.PIZZA_ID = 2 THEN 10
					ELSE 0
				END
			) AS VEGETRIAN_SUM,
			SUM(ARRAY_LENGTH(STRING_TO_ARRAY(EXTRAS, ','), 1)) AS EXTRAS_REVENUE
		FROM
			CUSTOMER_ORDERS_TEMP C
			JOIN RUNNER_ORDERS_TEMP R ON C.ORDER_ID = R.ORDER_ID
		WHERE
			R.DISTANCE <> '0'
	) AS T;


-- 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS RUNNER_RATING;

CREATE TABLE RUNNER_RATING (
	ORDER_ID INTEGER,
	RATING INTEGER CHECK (RATING BETWEEN 1 AND 5),
	REVIEW VARCHAR(100)
);

INSERT INTO
	RUNNER_RATING
VALUES
	('1', '1', 'Really bad service'),
	('2', '1', NULL),
	('3', '4', 'Took too long...'),
	(
		'4',
		'1',
		'Runner was lost, delivered it AFTER an hour. Pizza arrived cold'
	),
	('5', '2', 'Good service'),
	('7', '5', 'It was great, good service and fast'),
	(
		'8',
		'2',
		'He tossed it on the doorstep, poor service'
	),
	(
		'10',
		'5',
		'Delicious!, he delivered it sooner than expected too!'
	);
	

SELECT * FROM RUNNER_RATING ;
		

-- 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
SELECT
	CO.CUSTOMER_ID,
	CO.ORDER_ID,
	RO.RUNNER_ID,
	RR.RATING,
	CO.ORDER_TIME,
	RO.PICKUP_TIME,
	-- Calculate pickup time difference in minutes
	(CAST(PICKUP_TIME AS TIMESTAMP) - ORDER_TIME) AS PICK_UP_TIME,
	RO.DURATION AS DELIVERY_DURATION,
	-- Average speed
	ROUND((RO.DISTANCE * 60.0 / RO.DURATION)::NUMERIC, 2) AS AVERAGE_SPEED,
	COUNT(CO.PIZZA_ID) AS TOTAL_PIZZA_COUNT
FROM
	CUSTOMER_ORDERS_TEMP CO
	JOIN RUNNER_ORDERS_TEMP RO ON CO.ORDER_ID = RO.ORDER_ID
	JOIN RUNNER_RATING RR ON CO.ORDER_ID = RR.ORDER_ID
GROUP BY
	CO.CUSTOMER_ID,
	CO.ORDER_ID,
	RO.RUNNER_ID,
	RR.RATING,
	CO.ORDER_TIME,
	RO.PICKUP_TIME,
	RO.DURATION,
	RO.DISTANCE
ORDER BY
	1;


-- 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
SELECT
	MEAT_LOVER_SUM,
	VEGETRIAN_SUM,
	RUNNER_EXPENSE,
	(
		(MEAT_LOVER_SUM + VEGETRIAN_SUM) - (0.3 * RUNNER_EXPENSE)
	) AS TOTAL_REVENUE
FROM
	(
		SELECT
			SUM(
				CASE
					WHEN C.PIZZA_ID = 1 THEN 12
					ELSE 0
				END
			) AS MEAT_LOVER_SUM,
			SUM(
				CASE
					WHEN C.PIZZA_ID = 2 THEN 10
					ELSE 0
				END
			) AS VEGETRIAN_SUM,
			SUM(CAST(R.DISTANCE AS FLOAT)) AS RUNNER_EXPENSE
		FROM
			CUSTOMER_ORDERS_TEMP C
			JOIN RUNNER_ORDERS_TEMP R ON C.ORDER_ID = R.ORDER_ID
		WHERE
			R.DISTANCE <> '0'
	) AS T;







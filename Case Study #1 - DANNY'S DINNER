--CASE STUDY #1 ( DANNY'S DINNER)

CREATE TABLE SALES (
	"customer_id" VARCHAR(1),
	"order_date" DATE,
	"product_id" INTEGER
);

INSERT INTO
	SALES ("customer_id", "order_date", "product_id")
VALUES
	('A', '2021-01-01', '1'),
	('A', '2021-01-01', '2'),
	('A', '2021-01-07', '2'),
	('A', '2021-01-10', '3'),
	('A', '2021-01-11', '3'),
	('A', '2021-01-11', '3'),
	('B', '2021-01-01', '2'),
	('B', '2021-01-02', '2'),
	('B', '2021-01-04', '1'),
	('B', '2021-01-11', '1'),
	('B', '2021-01-16', '3'),
	('B', '2021-02-01', '3'),
	('C', '2021-01-01', '3'),
	('C', '2021-01-01', '3'),
	('C', '2021-01-07', '3');
 
CREATE TABLE MENU (
	"product_id" INTEGER,
	"product_name" VARCHAR(5),
	"price" INTEGER
);

INSERT INTO
	MENU ("product_id", "product_name", "price")
VALUES
	('1', 'sushi', '10'),
	('2', 'curry', '15'),
	('3', 'ramen', '12');

CREATE TABLE MEMBERS ("customer_id" VARCHAR(1), "join_date" DATE);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  select * from sales;
  select * from menu;
  select * from members;


/* --------------------
Case Study Questions
--------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	S.CUSTOMER_ID,
	SUM(M.PRICE) AS PRICEE
FROM
	SALES S
	JOIN MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY
	S.CUSTOMER_ID;

-- 2. How many days has each customer visited the restaurant?
SELECT
	CUSTOMER_ID,
	COUNT(DISTINCT ORDER_DATE) AS VISIT
FROM
	SALES
GROUP BY
	CUSTOMER_ID;

-- 3. What was the first item from the menu purchased by each customer?
WITH
	ORDERED_SALE AS (
		SELECT
			S.CUSTOMER_ID,
			M.PRODUCT_NAME,
			S.ORDER_DATE,
			DENSE_RANK() OVER (
				PARTITION BY
					S.CUSTOMER_ID
				ORDER BY
					S.ORDER_DATE
			) AS RANK
		FROM
			SALES S
			JOIN MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
	)
SELECT
	CUSTOMER_ID,
	PRODUCT_NAME
FROM
	ORDERED_SALE
WHERE
	RANK = 1
GROUP BY
	CUSTOMER_ID,
	PRODUCT_NAME;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	S.PRODUCT_ID,
	M.PRODUCT_NAME,
	COUNT(S.PRODUCT_ID) AS MOST_PURCHASED
FROM
	SALES S
	JOIN MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY
	S.PRODUCT_ID,
	M.PRODUCT_NAME
ORDER BY
	MOST_PURCHASED DESC
LIMIT
	1;
	


-- 5. Which item was the most popular for each customer?
WITH
	MOST_POPULAR AS (
		SELECT
			S.CUSTOMER_ID,
			M.PRODUCT_NAME,
			DENSE_RANK() OVER (
				PARTITION BY
					S.CUSTOMER_ID
				ORDER BY
					COUNT(S.ORDER_DATE) DESC
			) AS RANKK
		FROM
			SALES S
			JOIN MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
		GROUP BY
			S.CUSTOMER_ID,
			M.PRODUCT_NAME
	)
SELECT
	CUSTOMER_ID,
	PRODUCT_NAME
FROM
	MOST_POPULAR
WHERE
	RANKK = 1;


-- 6. Which item was purchased first by the customer after they became a member?
WITH
	JOINED_AS_MEMBER AS (
		SELECT
			S.PRODUCT_ID,
			M.CUSTOMER_ID,
			ROW_NUMBER() OVER (
				PARTITION BY
					S.CUSTOMER_ID
				ORDER BY
					ORDER_DATE
			) AS ROW_NUM
		FROM
			SALES S
			JOIN MEMBERS M ON M.CUSTOMER_ID = S.CUSTOMER_ID
			AND S.ORDER_DATE > M.JOIN_DATE
	)
SELECT
	J.CUSTOMER_ID,
	M.PRODUCT_NAME
FROM
	JOINED_AS_MEMBER J
	JOIN MENU M ON J.PRODUCT_ID = M.PRODUCT_ID
WHERE
	ROW_NUM = 1
ORDER BY
	CUSTOMER_ID ASC;

	
-- 7. Which item was purchased just before the customer became a member?
WITH
	JOINED_NOT_MEMBER AS (
		SELECT
			S.PRODUCT_ID,
			M.CUSTOMER_ID,
			ROW_NUMBER() OVER (
				PARTITION BY
					S.CUSTOMER_ID
				ORDER BY
					ORDER_DATE DESC
			) AS ROW_NUM
		FROM
			SALES S
			JOIN MEMBERS M ON M.CUSTOMER_ID = S.CUSTOMER_ID
			AND S.ORDER_DATE < M.JOIN_DATE
	)
SELECT
	J.CUSTOMER_ID,
	M.PRODUCT_NAME
FROM
	MENU M
	JOIN JOINED_NOT_MEMBER J ON J.PRODUCT_ID = M.PRODUCT_ID
WHERE
	ROW_NUM = 1
ORDER BY
	J.CUSTOMER_ID ASC;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH
	BEFORE_MEMBERSHIP AS (
		SELECT
			S.PRODUCT_ID,
			M.CUSTOMER_ID,
			COUNT(ORDER_DATE) AS TOTAL_ITEMS
		FROM
			SALES S
			JOIN MEMBERS M ON M.CUSTOMER_ID = S.CUSTOMER_ID
			AND S.ORDER_DATE < M.JOIN_DATE
		GROUP BY
			S.PRODUCT_ID,
			M.CUSTOMER_ID
	)
	--select * from before_membership;
SELECT
	B.CUSTOMER_ID,
	B.TOTAL_ITEMS,
	SUM(M.PRICE) AS SPENT
FROM
	BEFORE_MEMBERSHIP B
	JOIN MENU M ON B.PRODUCT_ID = M.PRODUCT_ID
GROUP BY
	B.CUSTOMER_ID,
	B.TOTAL_ITEMS
ORDER BY
	B.CUSTOMER_ID;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH
	POINTS_CTE AS (
		SELECT
			PRODUCT_ID,
			CASE
				WHEN PRODUCT_ID = 1 THEN PRICE * 20
				ELSE PRICE * 10
			END AS POINTS
		FROM
			MENU
	)
	--select * from points_cte;
SELECT
	S.CUSTOMER_ID,
	SUM(P.POINTS) AS TOTAL_POINTS
FROM
	SALES S
	JOIN POINTS_CTE P ON S.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
	S.CUSTOMER_ID
ORDER BY
	S.CUSTOMER_ID;



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT
	S.CUSTOMER_ID,
	SUM(
		CASE
			WHEN (ORDER_DATE <= JOIN_DATE + 6)
			AND ORDER_DATE >= JOIN_DATE THEN ME.PRICE * 20
			ELSE CASE
				WHEN ME.PRODUCT_NAME = 'sushi' THEN ME.PRICE * 20
				ELSE ME.PRICE * 10
			END
		END
	) AS POINTS
FROM
	SALES S
	JOIN MEMBERS M ON M.CUSTOMER_ID = S.CUSTOMER_ID
	JOIN MENU ME ON S.PRODUCT_ID = ME.PRODUCT_ID
WHERE
	S.ORDER_DATE <= '2021-01-31'
GROUP BY
	1;


	
-- Example Query:
SELECT
  	product_id,
    product_name,
    price
from menu
ORDER BY price DESC
LIMIT 5;

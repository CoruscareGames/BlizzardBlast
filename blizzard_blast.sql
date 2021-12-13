CREATE DATABASE blizzard_blast;

-- To keep track of what recipes we have
CREATE TABLE recipe(
	recipe_name VARCHAR(50) NOT NULL PRIMARY KEY
);

-- To keep track of the different sizes of milkshake recipes we have
CREATE TABLE recipe_size(
	recipe_size INT NOT NULL PRIMARY KEY
);

-- To keep track of the different schedules per week we have
-- Holds the Monday date of each week
CREATE TABLE week(
	week_date DATE NOT NULL PRIMARY KEY
);

-- To keep track of our employees
CREATE TABLE employee(
	employee_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	name VARCHAR(255) NOT NULL
);

-- To keep track of our ingredients
CREATE TABLE ingredient(
	ingredient_name VARCHAR(50) NOT NULL PRIMARY KEY,
	category VARCHAR(50) NOT NULL,
	stock INT NOT NULL,
	price_per_serving INT NOT NULL
);

-- To keep track of the price of each recipe and size (base prices)
CREATE TABLE recipe_price(
	recipe_name VARCHAR(50) NOT NULL,
	recipe_size INT NOT NULL,
	price INT NOT NULL,
	PRIMARY KEY(recipe_name, recipe_size),
	FOREIGN KEY(recipe_name) REFERENCES recipe(recipe_name),
	FOREIGN KEY(recipe_size) REFERENCES recipe_size(recipe_size)
);

-- To keep track of the number of servings of an ingredient in a specific size of a recipe
CREATE TABLE servings(
	ingredient_name VARCHAR(50) NOT NULL,
	recipe_name VARCHAR(50) NOT NULL,
	recipe_size INT NOT NULL,
	servings INT NOT NULL,
	PRIMARY KEY(ingredient_name, recipe_name, recipe_size),
	FOREIGN KEY(ingredient_name) REFERENCES ingredient(ingredient_name),
	FOREIGN KEY(recipe_name) REFERENCES recipe(recipe_name),
	FOREIGN KEY(recipe_size) REFERENCES recipe_size(recipe_size)
);

-- To keep track of the roles of employees per week
CREATE TABLE schedule(
	week_date DATE NOT NULL,
	employee_id INT NOT NULL,
	employee_role VARCHAR(50) NOT NULL,
	PRIMARY KEY(week_date, employee_id),
	FOREIGN KEY(week_date) REFERENCES week(week_date),
	FOREIGN KEY(employee_id) REFERENCES employee(employee_id)
);

-- To keep track of the transactions each linked to a customer
CREATE TABLE sale(
	txn INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customer_name VARCHAR(255) NOT NULL,
	day_date DATE NOT NULL,
	week_date DATE NOT NULL,
	FOREIGN KEY(week_date) REFERENCES week(week_date)
);

-- To keep track of all milkshakes ordered by customers
CREATE TABLE milkshake(
	milkshake_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	recipe_name VARCHAR(50) NOT NULL,
	recipe_size INT NOT NULL,
	FOREIGN KEY(recipe_name) REFERENCES recipe(recipe_name),
	FOREIGN KEY(recipe_size) REFERENCES recipe_size(recipe_size)
);

-- To keep track of all customizations ordered by customers
-- NOTE THAT THE price_delta FIELD SHOULD BE AUTOMATICALLY GENERATED IN AN INSERT STATEMENT AND NOT PLACED MANUALLY
CREATE TABLE customization(
	milkshake_id INT NOT NULL,
	ingredient_name VARCHAR(50) NOT NULL,
	ingredient_quantity INT NOT NULL,
	price_delta INT NOT NULL,
	PRIMARY KEY(milkshake_id, ingredient_name),
	FOREIGN KEY(milkshake_id) REFERENCES milkshake(milkshake_id),
	FOREIGN KEY(ingredient_name) references ingredient(ingredient_name)
);

-- To keep track of all milkshakes in a transaction
CREATE TABLE orders(
	txn INT NOT NULL,
	milkshake_id INT NOT NULL,
	price INT NOT NULL,
	PRIMARY KEY(txn, milkshake_id),
	FOREIGN KEY(txn) REFERENCES sale(txn),
	FOREIGN KEY(milkshake_id) REFERENCES milkshake(milkshake_id)
);

-- To keep track of who the manager is on a particular date in a particular week
CREATE TABLE manager(
	manager_date DATE NOT NULL PRIMARY KEY,
	employee_id INT NOT NULL,
	week_date DATE NOT NULL,
	FOREIGN KEY(employee_id) REFERENCES employee(employee_id),
	FOREIGN KEY(week_date) REFERENCES week(week_date)
);

-- Functions and Views
-- Ingredient View (For managers to view inventory stock)
-- To call type “SELECT * FROM ingredient_stock_view;”
CREATE OR REPLACE VIEW ingredient_stock_view AS
SELECT	ingredient_name "Ingredient", 
		category "Category",
        stock "Stock"
FROM	ingredient
ORDER BY ingredient_name ASC, category ASC;

-- Function to return all milkshakes and customizations linked to a txn
-- To use, type “SELECT * FROM print_transaction(PUTTXNHERE)”
CREATE OR REPLACE FUNCTION print_transaction(transaction_no INT)
RETURNS TABLE
(
	milkshake_id INT,
	recipe_name VARCHAR(50),
	recipe_size INT,
	ingredient_name VARCHAR(50),
	ingredient_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY
	SELECT milkshake.milkshake_id, milkshake.recipe_name, milkshake.recipe_size, 'NULL'::VARCHAR(50), 0
	FROM milkshake
	WHERE milkshake.milkshake_id IN (
		SELECT orders.milkshake_id
		FROM orders
		WHERE txn = transaction_no
		)
	UNION ALL
	SELECT milkshake.milkshake_id, milkshake.recipe_name, milkshake.recipe_size, customization.ingredient_name, customization.ingredient_quantity
	FROM milkshake
	INNER JOIN customization ON milkshake.milkshake_id = customization.milkshake_id
	WHERE milkshake.milkshake_id IN (
		SELECT orders.milkshake_id
		FROM orders
		WHERE txn = transaction_no
		)
	ORDER BY milkshake_id;
END;
$$;

-- Report View (Needed for report_call to work)
-- NOT TO BE USED; USE report_call instead
CREATE OR REPLACE VIEW report_view AS
SELECT  recipe_name,
        day_date
FROM    milkshake
INNER JOIN orders on milkshake.milkshake_id = orders.milkshake_id
INNER JOIN sale on orders.txn = sale.txn;

-- Prints a list of recipes and how many times they were ordered by customers
-- To use, type “SELECT * FROM report_call(STARTDATE, ENDDATE)”
CREATE OR REPLACE FUNCTION report_call(start_date DATE, end_DATE DATE)
RETURNS TABLE
(
    recipe VARCHAR(50),
	times_ordered BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY
    SELECT	recipe_name,
            COUNT(recipe_name)
    FROM    report_view
    WHERE    day_date BETWEEN start_date AND end_date
    GROUP BY recipe_name
    ORDER BY COUNT(recipe_name) DESC;
END;
$$;

-- Customization Report View (Needed for report_customization_call to work)
-- NOT TO BE USED; USE report_customization_call instead
CREATE OR REPLACE VIEW customization_report_view AS
SELECT ingredient_name, ingredient_quantity, day_date
FROM customization
INNER JOIN orders ON customization.milkshake_id = orders.milkshake_id
INNER JOIN sale ON orders.txn = sale.txn;

-- Prints a list of ingredients/customizations and the sum of the times they were ordered (if they were removed then they are subtracted)
-- To use, type “SELECT * FROM report_customization_call(STARTDATE, ENDDATE);”
CREATE OR REPLACE FUNCTION report_customization_call(start_date DATE, end_DATE DATE)
RETURNS TABLE
(
	ingredient VARCHAR(50),
	sum_ordered BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY
    SELECT	ingredient_name,
            SUM(ingredient_quantity)
    FROM    customization_report_view
    WHERE    day_date BETWEEN start_date AND end_date
    GROUP BY ingredient_name
    ORDER BY SUM(ingredient_quantity) DESC;
END;
$$;

-- Schedule View (Needed for print_roles to work)
-- NOT TO BE USED; USE print_roles instead
CREATE OR REPLACE VIEW schedule_view AS
SELECT schedule.week_date, employee.name, schedule.employee_role
FROM schedule
INNER JOIN employee ON schedule.employee_id = employee.employee_id;

-- Prints the roles of the employees for a week
-- To use, type "SELECT * FROM print_roles(WORKDATE);"
CREATE OR REPLACE FUNCTION print_roles(week_start_date DATE)
RETURNS TABLE
(
	name VARCHAR(255),
	role VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
RETURN QUERY
    SELECT	schedule_view.name,
			schedule_view.employee_role
    FROM    schedule_view
    WHERE    week_date = week_start_date;
END;
$$;


-- Test Values:
-- Recipe
INSERT	INTO recipe
VALUES	('STRAWBERRY MILKSHAKE');

INSERT	INTO recipe
VALUES	('OREO MILKSHAKE');

INSERT	INTO recipe
VALUES	('CHOCOLATE MILKSHAKE');

-- Ingredient
INSERT	INTO ingredient
VALUES	('FULL CREAM MILK', 'MILK', 100, 20);

INSERT	INTO ingredient
VALUES	('SOY MILK', 'MILK', 100, 20);

INSERT	INTO ingredient
VALUES	('OREO', 'MIX-IN', 100, 10);

INSERT	INTO ingredient
VALUES	('CHOCOLATE', 'MIX-IN', 100, 10);

INSERT	INTO ingredient
VALUES	('STRAWBERRY', 'FRUITS', 50, 20);

INSERT	INTO ingredient
VALUES	('VANILLA ICE CREAM', 'BASE', 100, 40);

INSERT	INTO ingredient
VALUES	('CHOCOLATE ICE CREAM', 'BASE', 100, 40);

INSERT	INTO ingredient
VALUES	('WHIPPED CREAM', 'TOPPING', 100, 15);

INSERT	INTO ingredient
VALUES	('BANANA', 'FRUITS', 25, 15);

INSERT	INTO ingredient
VALUES	('PEANUT', 'MIX-IN', 42, 8);


-- Recipe Size
INSERT	INTO recipe_size
VALUES	(1);

INSERT	INTO recipe_size
VALUES	(2);

INSERT	INTO recipe_size
VALUES	(3);

-- Recipe Price
INSERT	INTO recipe_price
VALUES	('OREO MILKSHAKE', 1, 125);

INSERT	INTO recipe_price
VALUES	('OREO MILKSHAKE', 2, 195);

INSERT	INTO recipe_price
VALUES	('OREO MILKSHAKE', 3, 265);

INSERT	INTO recipe_price
VALUES	('CHOCOLATE MILKSHAKE', 1, 125);

INSERT	INTO recipe_price
VALUES	('CHOCOLATE MILKSHAKE', 2, 195);

INSERT	INTO recipe_price
VALUES	('CHOCOLATE MILKSHAKE', 3, 265);

INSERT	INTO recipe_price
VALUES	('STRAWBERRY MILKSHAKE', 1, 135);

INSERT	INTO recipe_price
VALUES	('STRAWBERRY MILKSHAKE', 2, 215);

INSERT	INTO recipe_price
VALUES	('STRAWBERRY MILKSHAKE', 3, 295);


-- Servings
INSERT	INTO servings
VALUES	('OREO', 'OREO MILKSHAKE', 1, 1);

INSERT	INTO servings
VALUES	('OREO', 'OREO MILKSHAKE', 2, 2);

INSERT	INTO servings
VALUES	('OREO', 'OREO MILKSHAKE', 3, 3);

INSERT	INTO servings
VALUES	('VANILLA ICE CREAM', 'OREO MILKSHAKE', 1, 2);

INSERT	INTO servings
VALUES	('VANILLA ICE CREAM', 'OREO MILKSHAKE', 2, 3);

INSERT	INTO servings
VALUES	('VANILLA ICE CREAM', 'OREO MILKSHAKE', 3, 4);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'OREO MILKSHAKE', 1, 1);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'OREO MILKSHAKE', 2, 2);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'OREO MILKSHAKE', 3, 3);
         
INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'OREO MILKSHAKE', 1, 1);

INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'OREO MILKSHAKE', 2, 1);

INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'OREO MILKSHAKE', 3, 1);
         
INSERT	INTO servings
VALUES	('CHOCOLATE', 'CHOCOLATE MILKSHAKE', 1, 1);

INSERT	INTO servings
VALUES	('CHOCOLATE', 'CHOCOLATE MILKSHAKE', 2, 2);

INSERT	INTO servings
VALUES	('CHOCOLATE', 'CHOCOLATE MILKSHAKE', 3, 3);

INSERT	INTO servings
VALUES	('CHOCOLATE ICE CREAM', 'CHOCOLATE MILKSHAKE', 1, 2);

INSERT	INTO servings
VALUES	('CHOCOLATE ICE CREAM', 'CHOCOLATE MILKSHAKE', 2, 3);

INSERT	INTO servings
VALUES	('CHOCOLATE ICE CREAM', 'CHOCOLATE MILKSHAKE', 3, 4);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'CHOCOLATE MILKSHAKE', 1, 1);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'CHOCOLATE MILKSHAKE', 2, 2);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'CHOCOLATE MILKSHAKE', 3, 3);
         
INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'CHOCOLATE MILKSHAKE', 1, 1);

INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'CHOCOLATE MILKSHAKE', 2, 1);

INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'CHOCOLATE MILKSHAKE', 3, 1);

INSERT	INTO servings
VALUES	('STRAWBERRY', 'STRAWBERRY MILKSHAKE', 1, 1);

INSERT	INTO servings
VALUES	('STRAWBERRY', 'STRAWBERRY MILKSHAKE', 2, 2);

INSERT	INTO servings
VALUES	('STRAWBERRY', 'STRAWBERRY MILKSHAKE', 3, 3);

INSERT	INTO servings
VALUES	('VANILLA ICE CREAM', 'STRAWBERRY MILKSHAKE', 1, 2);

INSERT	INTO servings
VALUES	('VANILLA ICE CREAM', 'STRAWBERRY MILKSHAKE', 2, 3);

INSERT	INTO servings
VALUES	('VANILLA ICE CREAM', 'STRAWBERRY MILKSHAKE', 3, 4);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'STRAWBERRY MILKSHAKE', 1, 1);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'STRAWBERRY MILKSHAKE', 2, 2);
         
INSERT	INTO servings
VALUES	('FULL CREAM MILK', 'STRAWBERRY MILKSHAKE', 3, 3);
         
INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'STRAWBERRY MILKSHAKE', 1, 1);

INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'STRAWBERRY MILKSHAKE', 2, 1);

INSERT	INTO servings
VALUES	('WHIPPED CREAM', 'STRAWBERRY MILKSHAKE', 3, 1);

-- week
INSERT	INTO week
VALUES	('2021-12-06');

INSERT	INTO week
VALUES	('2021-12-13');

INSERT	INTO week
VALUES	('2021-12-20');

-- employee
INSERT	INTO employee
VALUES	(DEFAULT,'ICHI');

INSERT	INTO employee
VALUES	(DEFAULT,'ONII');

INSERT	INTO employee
VALUES	(DEFAULT,'SAN');

-- sched
INSERT	INTO schedule
VALUES	('2021-12-06', 1,'CASHIER');

INSERT	INTO schedule
VALUES	('2021-12-06', 2,'PREPARATION');

INSERT	INTO schedule
VALUES	('2021-12-06', 3,'CLEANING');

INSERT	INTO schedule
VALUES	('2021-12-13', 1,'PREPARATION');

INSERT	INTO schedule
VALUES	('2021-12-13', 2,'CLEANING');

INSERT	INTO schedule
VALUES	('2021-12-13', 3,'CASHIER');

INSERT	INTO schedule
VALUES	('2021-12-20', 1,'CLEANING');

INSERT	INTO schedule
VALUES	('2021-12-20', 2,'CASHIER');

INSERT	INTO schedule
VALUES	('2021-12-20', 3,'PREPARATION');

-- manager
INSERT INTO manager
VALUES
(
	'2021-12-06',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-06' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-07',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-07' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-08',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-08' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-09',
	2,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-09' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-10',
	2,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-10' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-11',
	3,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-11' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-12',
	3,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-12' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-13',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-13' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-14',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-14' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-15',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-15' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-16',
	2,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-16' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-17',
	2,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-17' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-18',
	3,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-18' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-19',
	3,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-19' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-20',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-20' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-21',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-21' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);


INSERT INTO manager
VALUES
(
	'2021-12-22',
	1,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-22' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-23',
	2,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-23' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-24',
	2,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-24' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-25',
	3,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-25' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO manager
VALUES
(
	'2021-12-26',
	3,
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-26' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

-- milkshake
INSERT	INTO milkshake
VALUES	(DEFAULT,'OREO MILKSHAKE', 1);

INSERT	INTO milkshake
VALUES	(DEFAULT,'CHOCOLATE MILKSHAKE', 1);

INSERT	INTO milkshake
VALUES	(DEFAULT,'OREO MILKSHAKE', 3);

INSERT	INTO milkshake
VALUES	(DEFAULT,'STRAWBERRY MILKSHAKE', 2);

INSERT	INTO milkshake
VALUES	(DEFAULT,'CHOCOLATE MILKSHAKE', 3);

INSERT	INTO milkshake
VALUES	(DEFAULT,'STRAWBERRY MILKSHAKE', 1);

INSERT	INTO milkshake
VALUES	(DEFAULT,'CHOCOLATE MILKSHAKE', 3);

INSERT	INTO milkshake
VALUES	(DEFAULT,'OREO MILKSHAKE', 3);

INSERT	INTO milkshake
VALUES	(DEFAULT,'OREO MILKSHAKE', 3);

INSERT	INTO milkshake
VALUES	(DEFAULT,'OREO MILKSHAKE', 3);

-- customization
INSERT INTO customization
VALUES
(
	1,
	'OREO',
	1,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'OREO'
	) * 1
);

INSERT INTO customization
VALUES
(
	2,
	'OREO',
	-1,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'OREO'
	) * -1
);

INSERT INTO customization
VALUES
(
	1,
	'CHOCOLATE',
	1,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'CHOCOLATE'
	) * 1
);

INSERT INTO customization
VALUES
(
	4,
	'CHOCOLATE',
	1,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'CHOCOLATE'
	) * 1
);

INSERT INTO customization
VALUES
(
	5,
	'CHOCOLATE ICE CREAM',
	-1,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'CHOCOLATE ICE CREAM'
	) * -1
);


INSERT INTO customization
VALUES
(
	6,
	'WHIPPED CREAM',
	-1,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'WHIPPED CREAM'
	) * -1
);

INSERT INTO customization
VALUES
(
	6,
	'VANILLA ICE CREAM',
	3,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'VANILLA ICE CREAM'
	) * 3
);

INSERT INTO customization
VALUES
(
	8,
	'VANILLA ICE CREAM',
	3,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'VANILLA ICE CREAM'
	) * 3
);

INSERT INTO customization
VALUES
(
	10,
	'CHOCOLATE ICE CREAM',
	3,
	(
	SELECT price_per_serving
	FROM ingredient
	WHERE ingredient_name = 'CHOCOLATE ICE CREAM'
	) * 3
);

--sale
INSERT INTO sale
VALUES
(
	DEFAULT,
	'JOHNNY',
	'2021-12-07',
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-07' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO sale
VALUES
(
	DEFAULT,
	'JOLYNE',
	'2021-12-09',
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-09' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO sale
VALUES
(
	DEFAULT,
	'JOSEPH',
	'2021-12-13',
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-13' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO sale
VALUES
(
	DEFAULT,
	'JOTARO',
	'2021-12-14',
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-14' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO sale
VALUES
(
	DEFAULT,
	'DIO',
	'2021-12-21',
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-21' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO sale
VALUES
(
	DEFAULT,
	'JOSUKE',
	'2021-12-22',
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-22' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

INSERT INTO sale
VALUES
(
	DEFAULT,
	'JOHNNY',
	'2021-12-23',
	(
	SELECT week_date
	FROM week
	WHERE '2021-12-23' BETWEEN week_date AND (week_date + INTERVAL '6 days'
	))
);

-- orders
INSERT INTO orders
VALUES
(
	1, -- TXN
	1, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 1
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 1
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 1
		)
		AS foo
	)
);

INSERT INTO orders
VALUES
(
	2, -- TXN
	2, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 2
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 2
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 2
		)
		AS foo
	)
);

INSERT INTO orders
VALUES
(
	3, -- TXN
	3, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 3
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 3
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 3
		)
		AS foo
	)
);
INSERT INTO orders
VALUES
(
	4, -- TXN
	4, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 4
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 4
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 4
		)
		AS foo
	)
);

INSERT INTO orders
VALUES
(
	5, -- TXN
	5, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 5
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 5
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 5
		)
		AS foo
	)
);

INSERT INTO orders
VALUES
(
	6, -- TXN
	6, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 6
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 6
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 6
		)
		AS foo
	)
);

INSERT INTO orders
VALUES
(
	6, -- TXN
	7, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 7
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 7
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 7
		)
		AS foo
	)
);

INSERT INTO orders
VALUES
(
	7, -- TXN
	8, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 8
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 8
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 8
		)
		AS foo
	)
);

INSERT INTO orders
VALUES
(
	7, -- TXN
	9, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 9
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 9
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 9
		)
		AS foo
	)
);

INSERT INTO orders
VALUES
(
	7, -- TXN
	10, -- Milkshake ID
	(
		SELECT SUM(price) FROM
		(
			SELECT price
			FROM recipe_price
			WHERE recipe_name = (
				SELECT recipe_name
				FROM milkshake
				WHERE milkshake_id = 10
			)
			AND recipe_size = (
				SELECT recipe_size
				FROM milkshake
				WHERE milkshake_id = 10
			)
			UNION ALL	
			SELECT price_delta
			FROM customization
			WHERE milkshake_id = 10
		)
		AS foo
	)
);


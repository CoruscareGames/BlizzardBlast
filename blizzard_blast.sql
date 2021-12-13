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
VALUES	('DEEZ', 'NUTZ', 420, 6);


-- Recipe Size
INSERT	INTO recipe_size
VALUES	(1);

INSERT	INTO recipe_size
VALUES	(2);

INSERT	INTO recipe_size
VALUES	(3);

-- Recipe Price
INSERT	INTO recipe_price
VALUES	('OREO MILKSHAKE', 1, 130);

INSERT	INTO recipe_price
VALUES	('OREO MILKSHAKE', 2, 200);

INSERT	INTO recipe_price
VALUES	('OREO MILKSHAKE', 3, 270);

INSERT	INTO recipe_price
VALUES	('CHOCOLATE MILKSHAKE', 1, 130);

INSERT	INTO recipe_price
VALUES	('CHOCOLATE MILKSHAKE', 2, 200);

INSERT	INTO recipe_price
VALUES	('CHOCOLATE MILKSHAKE', 3, 270);

INSERT	INTO recipe_price
VALUES	('STRAWBERRY MILKSHAKE', 1, 140);

INSERT	INTO recipe_price
VALUES	('STRAWBERRY MILKSHAKE', 2, 220);

INSERT	INTO recipe_price
VALUES	('STRAWBERRY MILKSHAKE', 3, 300);


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
INSERT	INTO manager
VALUES	('2021-12-06', 1, '2021-12-06');

INSERT	INTO manager
VALUES	('2021-12-07', 1, '2021-12-06');

INSERT	INTO manager
VALUES	('2021-12-08', 1, '2021-12-06');

INSERT	INTO manager
VALUES	('2021-12-09', 2, '2021-12-06');

INSERT	INTO manager
VALUES	('2021-12-10', 2, '2021-12-06');

INSERT	INTO manager
VALUES	('2021-12-11', 3, '2021-12-06');

INSERT	INTO manager
VALUES	('2021-12-12', 3, '2021-12-06');

INSERT	INTO manager
VALUES	('2021-12-13', 1, '2021-12-13');

INSERT	INTO manager
VALUES	('2021-12-14', 1, '2021-12-13');

INSERT	INTO manager
VALUES	('2021-12-15', 1, '2021-12-13');

INSERT	INTO manager
VALUES	('2021-12-16', 2, '2021-12-13');

INSERT	INTO manager
VALUES	('2021-12-17', 2, '2021-12-13');

INSERT	INTO manager
VALUES	('2021-12-18', 3, '2021-12-13');

INSERT	INTO manager
VALUES	('2021-12-19', 3, '2021-12-13');

INSERT	INTO manager
VALUES	('2021-12-20', 1, '2021-12-20');

INSERT	INTO manager
VALUES	('2021-12-21', 1, '2021-12-20');

INSERT	INTO manager
VALUES	('2021-12-22', 1, '2021-12-20');

INSERT	INTO manager
VALUES	('2021-12-23', 2, '2021-12-20');

INSERT	INTO manager
VALUES	('2021-12-24', 2, '2021-12-20');

INSERT	INTO manager
VALUES	('2021-12-25', 3, '2021-12-20');

INSERT	INTO manager
VALUES	('2021-12-26', 3, '2021-12-20');

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
INSERT	INTO customization
VALUES	(1,'OREO', 1, 10);

INSERT	INTO customization
VALUES	(2,'OREO', -1, 10);

INSERT	INTO customization
VALUES	(1,'CHOCOLATE', 1, 10);

INSERT	INTO customization
VALUES	(4,'CHOCOLATE', 1, 10);

INSERT	INTO customization
VALUES	(5,'CHOCOLATE ICE CREAM', -1, 40);

INSERT	INTO customization
VALUES	(6,'WHIPPED CREAM', -1, 10);

INSERT	INTO customization
VALUES	(6,'VANILLA ICE CREAM', 3, 10);

INSERT	INTO customization
VALUES	(8,'VANILLA ICE CREAM', 3, 10);

INSERT	INTO customization
VALUES	(10,'CHOCOLATE ICE CREAM', 3, 10);

--sale
INSERT	INTO sale
VALUES	(DEFAULT,'JOHNNY', '2021-12-07', '2021-12-06');

INSERT	INTO sale
VALUES	(DEFAULT,'JOLYNE', '2021-12-09', '2021-12-06');

INSERT	INTO sale
VALUES	(DEFAULT,'JOSEPH', '2021-12-13', '2021-12-13');

INSERT	INTO sale
VALUES	(DEFAULT,'JOTARO', '2021-12-14', '2021-12-13');

INSERT	INTO sale
VALUES	(DEFAULT,'DIO', '2021-12-21', '2021-12-20');

INSERT	INTO sale
VALUES	(DEFAULT,'JOSUKE', '2021-12-22', '2021-12-20');

INSERT	INTO sale
VALUES	(DEFAULT,'JOHNNY', '2021-12-23', '2021-12-20');

-- orders
INSERT	INTO orders
VALUES	(1,1,130);

INSERT	INTO orders
VALUES	(2,2,150);

INSERT	INTO orders
VALUES	(3,3,120);

INSERT	INTO orders
VALUES	(4,4,310);

INSERT	INTO orders
VALUES	(5,5,270);

INSERT	INTO orders
VALUES	(6,6,150);

INSERT	INTO orders
VALUES	(6,7,270);

INSERT	INTO orders
VALUES	(7,8,300);

INSERT	INTO orders
VALUES	(7,9,270);

INSERT	INTO orders
VALUES	(7,10,300);
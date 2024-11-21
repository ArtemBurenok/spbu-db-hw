/*
Домашнее задание №3
1. Создайте временную таблицу high_sales_products, которая будет содержать продукты, проданные в количестве 
более 10 единиц за последние 7 дней. Выведите данные из таблицы high_sales_products 
2. Создайте CTE employee_sales_stats, который посчитает общее количество продаж и среднее количество продаж 
для каждого сотрудника за последние 30 дней. Напишите запрос, который выводит сотрудников с количеством продаж 
выше среднего по компании 
3. Используя CTE, создайте иерархическую структуру, показывающую всех сотрудников, которые подчиняются конкретному 
менеджеру
4. Напишите запрос с CTE, который выведет топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц. 
В результатах должно быть указано, к какому месяцу относится каждая запись
5. Создайте индекс для таблицы sales по полю employee_id и sale_date. Проверьте, как наличие индекса влияет на 
производительность следующего запроса, используя трассировку (EXPLAIN ANALYZE)
6. Используя трассировку, проанализируйте запрос, который находит общее количество проданных единиц каждого продукта. 
*/


CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

-- Пример данных
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

SELECT * FROM employees LIMIT 5;

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-10-15'),
    (2, 2, 15, '2024-10-16'),
    (3, 1, 10, '2024-10-17'),
    (3, 3, 5, '2024-10-20'),
    (4, 2, 8, '2024-10-21'),
    (2, 1, 12, '2024-11-01');

SELECT * FROM sales LIMIT 5;


CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Пример данных
INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);

/*
1. Создайте временную таблицу high_sales_products, которая будет содержать продукты, проданные в количестве 
более 10 единиц за последние 7 дней. Выведите данные из таблицы high_sales_products 
*/

CREATE TEMPORARY TABLE high_sales_products AS
SELECT product_id, SUM(quantity) AS total_quantity
FROM sales
WHERE sale_date >= NOW() - INTERVAL '7 days'  -- последние 7 дней
GROUP BY product_id
HAVING SUM(quantity) > 10;  -- количество больше 10 единиц

-- Выводим данные из временной таблицы
SELECT *
FROM high_sales_products
LIMIT 10;

/*
2. Создайте CTE employee_sales_stats, который посчитает общее количество продаж и среднее количество продаж 
для каждого сотрудника за последние 30 дней. Напишите запрос, который выводит сотрудников с количеством продаж 
выше среднего по компании 
*/

WITH employee_sales_stats AS (
    SELECT employee_id, SUM(quantity) AS total_sales, AVG(quantity) AS average_sales
    FROM sales
    WHERE sale_date >= NOW() - INTERVAL '30 days' -- последние 30 дней
    GROUP BY employee_id
)

SELECT employee_id, total_sales
FROM employee_sales_stats
WHERE total_sales > (SELECT AVG(total_sales) FROM employee_sales_stats)
LIMIT 10;

/*
3. Используя CTE, создайте иерархическую структуру, показывающую всех сотрудников, которые подчиняются конкретному 
менеджеру
*/

WITH RECURSIVE employee_hierarchy AS (
    -- Базовый запрос для выборки информации о менеджере
    SELECT employee_id, name, position, manager_id
    FROM employees
    WHERE employee_id = 1  

    UNION ALL

    -- Рекурсивный запрос для получения сотрудников, подчиняющихся текущим
    SELECT e.employee_id, e.name, e.position, e.manager_id
    FROM employees e INNER JOIN 
        employee_hierarchy eh ON e.manager_id = eh.employee_id
)

SELECT employee_id,name, position, manager_id
FROM employee_hierarchy
LIMIT 10;

/*
4. Напишите запрос с CTE, который выведет топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц. 
В результатах должно быть указано, к какому месяцу относится каждая запись
*/

WITH monthly_sales AS (
    SELECT product_id, SUM(quantity) AS total_quantity, DATE_TRUNC('month', sale_date) AS sales_month
    FROM sales
    WHERE sale_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'  -- последние 2 месяца
    GROUP BY product_id, DATE_TRUNC('month', sale_date)
),
ranked_sales AS (
    SELECT product_id, total_quantity, sales_month, RANK() OVER (PARTITION BY sales_month ORDER BY total_quantity DESC) AS sales_rank
    FROM monthly_sales
)

SELECT product_id, total_quantity, sales_month, sales_rank
FROM ranked_sales
WHERE sales_rank <= 3
LIMIT 10;

/*
5. Создайте индекс для таблицы sales по полю employee_id и sale_date. Проверьте, как наличие индекса влияет на 
производительность следующего запроса, используя трассировку (EXPLAIN ANALYZE)
*/

-- без индекса
EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE employee_id = 1 AND sale_date >= '2023-01-01' AND sale_date < '2023-02-01'
LIMIT 10;

-- с индексом
CREATE INDEX idx_sales_employee_date ON sales(employee_id, sale_date);

EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE employee_id = 1 AND sale_date >= '2024-10-01' AND sale_date < '2024-12-01'
LIMIT 10;


-- Без индекса: 175 msec; С индексом: 137 msec

/*
6. Используя трассировку, проанализируйте запрос, который находит общее количество проданных единиц каждого продукта. 
*/

EXPLAIN ANALYZE	
SELECT product_id, SUM(quantity) AS total_sold_units
FROM sales
GROUP BY product_id
LIMIT 10;

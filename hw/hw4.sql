/*
Домашнее задание №4
1. Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры
2. Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)
3. Попробовать использовать RAISE внутри триггеров для логирования
*/

/*
1. Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры
*/

CREATE OR REPLACE FUNCTION log_changes() RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Изменение: %, OLD: %, NEW: %', TG_TABLE_NAME, OLD, NEW;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER employees_update_trigger
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER sales_insert_trigger
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER products_delete_trigger
BEFORE DELETE ON products
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER employees_insert_trigger
AFTER INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION log_changes();

/*
2. Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)
*/

-- Успешная транзакция

BEGIN;
INSERT INTO employees (name, position, department, salary) VALUES ('Иван Иванов', 'Менеджер', 'Продажи', 50000);
INSERT INTO sales (employee_id, product_id, quantity, sale_date) VALUES (CURRVAL(pg_get_serial_sequence('employees', 'employee_id')), 1, 5, CURRENT_DATE);
COMMIT;

-- Не успешная транзакция

BEGIN;
INSERT INTO employees (name, position, department, salary) VALUES ('Петр Петров', 'Аналитик', 'Маркетинг', 70000);
INSERT INTO sales (employee_id, product_id, quantity, sale_date) VALUES (CURRVAL(pg_get_serial_sequence('employees', 'employee_id')), 99999, 3, CURRENT_DATE);
COMMIT;

/*
Эта транзакция зафейлилась, потому что в таблице products нет продукта с product_id = 99999.
Ошибка вызвана нарушением ограничения внешнего ключа, что приводит к отмене всей транзакции.
*/

/*
3. Попробовать использовать RAISE внутри триггеров для логирования
*/

CREATE OR REPLACE FUNCTION log_sales_insert() RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Продано % единиц продукта ID % сотрудником %', NEW.quantity, NEW.product_id, NEW.employee_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sales_insert_logging_trigger
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION log_sales_insert();

-- В этом триггере мы логируем информацию о каждом новом добавлении продажи, используя RAISE для вывода сообщения в журнал.

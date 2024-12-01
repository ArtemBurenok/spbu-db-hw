-- Создание триггера

-- Проверка TotalValue

CREATE OR REPLACE FUNCTION ValidateTotalValue()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.total_value <> NEW.quantity * NEW.price THEN
        RAISE EXCEPTION 'TotalValue % is incorrect. It should be %', NEW.total_value, NEW.quantity * NEW.price;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ValidateTotalValue
BEFORE INSERT OR UPDATE ON trades
FOR EACH ROW EXECUTE FUNCTION ValidateTotalValue();

-- Триггер для автоматического вычисления total_value

CREATE OR REPLACE FUNCTION calculate_total_value()
RETURNS TRIGGER AS $$
BEGIN
    -- Вычисляем total_value как quantity * price
    NEW.total_value := NEW.quantity * NEW.price;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_total_value
BEFORE INSERT OR UPDATE ON trades
FOR EACH ROW
EXECUTE FUNCTION calculate_total_value();

-- Триггер для проверки существования акций перед вставкой сделки

CREATE OR REPLACE FUNCTION check_stock_exists()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM stock_dim WHERE stock_id = NEW.stock_id) THEN
        RAISE EXCEPTION 'Акция с идентификатором % не найдена', NEW.stock_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_stock_exists
BEFORE INSERT ON trades
FOR EACH ROW
EXECUTE FUNCTION check_stock_exists();

-- Транзакции

-- Вставка данных

BEGIN;
INSERT INTO trader_dim (trader_name, account_type, Location)
VALUES ('John Doe', 'Individual', 'New York');

INSERT INTO stock_dim (ticker, company_name)
VALUES ('AAPL', 'Apple Inc.');

INSERT INTO trades (stock_id, trader_id, quantity, price, total_value)
VALUES (1, 1, 10, 150.00, 1500.00);
COMMIT;

-- Обновление цены за все сделки трейдера

BEGIN;
UPDATE trades
SET price = price * :price_adjustment_factor
WHERE trader_id = :trader_id;
COMMIT;

-- Обновление и удаление данных

BEGIN;
UPDATE trader_dim
SET location = 'San Francisco', account_type = 'Retail'
WHERE trader_name = 'John Doe';

DELETE FROM trades
WHERE trade_id = 1;
COMMIT;

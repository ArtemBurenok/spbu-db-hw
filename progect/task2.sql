-- Временные таблицы

CREATE TEMPORARY TABLE temporary_stock_dim (
    ticker VARCHAR(10) NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    sector VARCHAR(50),
    industry VARCHAR(50),
    ISIN VARCHAR(12)
);

CREATE TEMPORARY TABLE temporary_trader_dim (
    trader_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50),
    register_date DATE,
    location VARCHAR(100)
);

CREATE TEMPORARY TABLE temporary_trades (
    stock_id INT NOT NULL,
    trader_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    total_value DECIMAL(10, 2) NOT NULL CHECK (total_value >= 0)
);

-- Представления с данными, которые были получены путём объединения всех таблиц

CREATE VIEW trade_details AS
SELECT t.trade_id, s.ticker, s.company_name, tr.trader_name, t.quantity, t.price, t.total_value
FROM trades t JOIN stock_dim s ON t.stock_id = s.stock_id
	JOIN trader_dim tr ON t.trader_id = tr.trader_id;



WITH trade_summary AS (
    SELECT t.trader_id, s.ticker, SUM(t.quantity) AS TotalQuantity, SUM(t.total_value) AS TotalValue
    FROM trades t JOIN stock_dim s ON t.stock_id = s.stock_id
    GROUP BY t.trader_id, s.ticker
),

trader_details AS (
    SELECT tr.trader_id, tr.trader_name, tr.account_type, tr.location
    FROM trader_dim tr
)

SELECT td.trader_name, td.account_type, ts.ticker, ts.TotalQuantity, ts.TotalValue
FROM trade_summary ts JOIN trader_details td ON ts.trader_id = td.trader_id
ORDER BY td.trader_name, ts.ticker
LIMIT 10;

-- Ограничения на уровне таблиц

ALTER TABLE trades
ADD CONSTRAINT check_Quantity CHECK (Quantity > 0);

ALTER TABLE trades
ADD CONSTRAINT check_Price CHECK (Price >= 0);

-- Триггер для валидации

CREATE OR REPLACE FUNCTION validate_trade()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка на существование StockID
    IF NOT EXISTS (SELECT 1 FROM stock_dim WHERE stock_id = NEW.stock_id) THEN
        RAISE EXCEPTION 'StockID % does not exist', NEW.stock_id;
    END IF;

    -- Проверка на существование TraderID
    IF NOT EXISTS (SELECT 1 FROM trader_dim WHERE trade_id = NEW.trade_id) THEN
        RAISE EXCEPTION 'TraderID % does not exist', NEW.trade_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_trade
BEFORE INSERT OR UPDATE ON trades
FOR EACH ROW EXECUTE FUNCTION validate_trade();
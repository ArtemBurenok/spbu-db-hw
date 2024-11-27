-- Временные таблицы

CREATE TEMPORARY TABLE TemporaryStockDim (
    Ticker VARCHAR(10) NOT NULL,
    CompanyName VARCHAR(100) NOT NULL,
    Sector VARCHAR(50),
    Industry VARCHAR(50),
    ISIN VARCHAR(12)
);

CREATE TEMPORARY TABLE TemporaryTraderDim (
    TraderName VARCHAR(100) NOT NULL,
    AccountType VARCHAR(50),
    RegisterDate DATE,
    Location VARCHAR(100)
);

CREATE TEMPORARY TABLE TemporaryTrades (
    StockID INT NOT NULL,
    TraderID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    TotalValue DECIMAL(10, 2) NOT NULL CHECK (TotalValue >= 0)
);

-- Представления с данными, которые были получены путём объединения всех таблиц

CREATE VIEW TradeDetails AS
SELECT t.TradeID, s.Ticker, s.CompanyName, tr.TraderName, t.Quantity, t.Price, t.TotalValue
FROM Trades t JOIN StockDim s ON t.StockID = s.StockID
	JOIN TraderDim tr ON t.TraderID = tr.TraderID;



WITH TradeSummary AS (
    SELECT t.TraderID, s.Ticker, SUM(t.Quantity) AS TotalQuantity, SUM(t.TotalValue) AS TotalValue
    FROM Trades t JOIN StockDim s ON t.StockID = s.StockID
    GROUP BY t.TraderID, s.Ticker
),

TraderDetails AS (
    SELECT tr.TraderID, tr.TraderName, tr.AccountType, tr.Location
    FROM TraderDim tr
)

SELECT td.TraderName, td.AccountType, ts.Ticker, ts.TotalQuantity, ts.TotalValue
FROM TradeSummary ts JOIN TraderDetails td ON ts.TraderID = td.TraderID
ORDER BY td.TraderName, ts.Ticker;

-- Ограничения на уровне таблиц

ALTER TABLE Trades
ADD CONSTRAINT chk_Quantity CHECK (Quantity > 0);

ALTER TABLE Trades
ADD CONSTRAINT chk_Price CHECK (Price >= 0);

-- Триггер для валидации

CREATE OR REPLACE FUNCTION validate_trade()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка на существование StockID
    IF NOT EXISTS (SELECT 1 FROM StockDim WHERE StockID = NEW.StockID) THEN
        RAISE EXCEPTION 'StockID % does not exist', NEW.StockID;
    END IF;

    -- Проверка на существование TraderID
    IF NOT EXISTS (SELECT 1 FROM TraderDim WHERE TraderID = NEW.TraderID) THEN
        RAISE EXCEPTION 'TraderID % does not exist', NEW.TraderID;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_trade
BEFORE INSERT OR UPDATE ON Trades
FOR EACH ROW EXECUTE FUNCTION validate_trade();

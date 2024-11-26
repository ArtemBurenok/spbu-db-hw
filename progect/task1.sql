-- Информация о сделках с данными о трейдерах и акциях
SELECT t.TradeID, s.Ticker, tr.TraderName, t.Quantity, t.Price, t.TotalValue
FROM Trades t JOIN StockDim s ON t.StockID = s.StockID
	 JOIN TraderDim tr ON t.TraderID = tr.TraderID
LIMIT 10;

-- Общая сумма сделок для каждого трейдера
SELECT tr.TraderName, SUM(t.TotalValue) OVER (PARTITION BY tr.TraderID) AS CumulativeTotalValue
FROM Trades t JOIN TraderDim tr ON t.TraderID = tr.TraderID
ORDER BY CumulativeTotalValue
LIMIT 10;

-- Общее количество сделок и общая стоимость сделок по каждому трейдеру
SELECT tr.TraderName, COUNT(t.TradeID) AS TotalTrades, SUM(t.TotalValue) AS TotalTradeValue
FROM Trades t JOIN TraderDim tr ON t.TraderID = tr.TraderID
GROUP BY tr.TraderName
LIMIT 10

-- Трейдеры, которые совершили более 2 сделок
SELECT tr.TraderName, COUNT(t.TradeID) AS TotalTrades
FROM Trades t JOIN TraderDim tr ON t.TraderID = tr.TraderID
GROUP BY tr.TraderName
HAVING COUNT(t.TradeID) > 2
LIMIT 10;

-- Список всех трейдеров и акций
SELECT TraderName AS Name, 'Trader'
FROM TraderDim
UNION
SELECT CompanyName AS Name, 'Stock'
FROM StockDim
LIMIT 10;

-- Информация о сделках с данными о трейдерах и акциях
SELECT t.tradeID, s.ticker, tr.traderName, t.quantity, t.price, t.totalValue
FROM trades t JOIN stockDim s ON t.stockID = s.stockID
	 JOIN traderDim tr ON t.traderID = tr.traderID
LIMIT 10;

-- Общая сумма сделок для каждого трейдера
SELECT tr.traderName, SUM(t.totalValue) OVER (PARTITION BY tr.traderID) AS CumulativeTotalValue
FROM trades t JOIN traderDim tr ON t.traderID = tr.traderID
ORDER BY CumulativeTotalValue
LIMIT 10;

-- Общее количество сделок и общая стоимость сделок по каждому трейдеру
SELECT tr.traderName, COUNT(t.tradeID) AS TotalTrades, SUM(t.totalValue) AS TotalTradeValue
FROM trades t JOIN traderDim tr ON t.traderID = tr.traderID
GROUP BY tr.traderName
LIMIT 10

-- Трейдеры, которые совершили более 2 сделок
SELECT tr.traderName, COUNT(t.tradeID) AS TotalTrades
FROM trades t JOIN traderDim tr ON t.traderID = tr.traderID
GROUP BY tr.traderName
HAVING COUNT(t.tradeID) > 2
LIMIT 10;

-- Список всех трейдеров и акций
SELECT traderName AS Name, 'Trader'
FROM traderDim
UNION
SELECT companyName AS Name, 'Stock'
FROM stockDim
LIMIT 10;

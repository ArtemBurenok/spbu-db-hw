-- Информация о сделках с данными о трейдерах и акциях
SELECT t.trade_id, s.ticker, tr.traderName, t.quantity, t.price, t.total_value
FROM trades t JOIN stock_dim s ON t.stock_id = s.stock_id
	 JOIN trader_dim tr ON t.trader_id = tr.trader_id
LIMIT 10;

-- Общая сумма сделок для каждого трейдера
SELECT tr.trader_name, SUM(t.total_value) OVER (PARTITION BY tr.trader_id) AS CumulativeTotalValue
FROM trades t JOIN trader_dim tr ON t.trader_id = tr.trader_id
ORDER BY CumulativeTotalValue
LIMIT 10;

-- Общее количество сделок и общая стоимость сделок по каждому трейдеру
SELECT tr.trader_name, COUNT(t.trade_id) AS TotalTrades, SUM(t.total_value) AS TotalTradeValue
FROM trades t JOIN trader_dim tr ON t.trader_id = tr.trader_id
GROUP BY tr.trader_name
LIMIT 10

-- Трейдеры, которые совершили более 2 сделок
SELECT tr.trader_name, COUNT(t.trade_id) AS TotalTrades
FROM trades t JOIN trader_dim tr ON t.trader_id = tr.trader_id
GROUP BY tr.trader_name
HAVING COUNT(t.trade_id) > 2
LIMIT 10;

-- Список всех трейдеров и акций
SELECT trader_name AS Name, 'Trader'
FROM trader_dim
UNION
SELECT company_name AS Name, 'Stock'
FROM stock_dim
LIMIT 10;

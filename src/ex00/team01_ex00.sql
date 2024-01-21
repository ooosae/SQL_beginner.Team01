--   name                 берем из: user.name
--   lastname             берем из: user.lastname
--   type                 берем из: balance.type
--   volume               берем из: balance.money и складываем все по айдише4ке
--   currency_name        берем из: currency.name
--   last_rate_to_usd     берем из: currency.rate_to_usd. берем последнее значение
--                        currency.rate_to_usd для валюты если это NULL то вернем 1
--   total_volume_in_usd  берем из: volume , last_rate_to_usd. умножаем друг на друга

-- Sort the result by user name in descending mode and then by user lastname and
-- balance type in ascending mode.

--валюты с актуальной информацией
WITH last_curr_data AS (
	SELECT 
		currency.id
		, currency.name
		, currency.rate_to_usd
		FROM (
			SELECT 
				id
				, max(updated) AS updated
			FROM currency
			GROUP BY id
		) AS last_updated
		JOIN currency ON last_updated.id = currency.id AND last_updated.updated = currency.updated
)
SELECT 
	COALESCE(u.name, 'not defined') AS name
	, COALESCE(u.lastname, 'not defined') AS lastname
	, balance_grouped.type
	, balance_grouped.volume
	, COALESCE(last_curr_data.name, 'not defined') AS currency_name
	, COALESCE(last_curr_data.rate_to_usd, 1) AS last_rate_to_usd
	, balance_grouped.volume * COALESCE(last_curr_data.rate_to_usd, 1) AS total_volume_in_usd
FROM (
	SELECT 
		balance.user_id
		, balance.type
		, balance.currency_id
		, SUM(balance.money) AS volume
	FROM balance
	GROUP BY 
		balance.user_id
		, balance.type
		, balance.currency_id
	) AS balance_grouped
	LEFT JOIN "user" AS u ON balance_grouped.user_id = u.id
	LEFT JOIN last_curr_data ON balance_grouped.currency_id = last_curr_data.id
ORDER BY 
	COALESCE(u.name, 'not defined') DESC
	, COALESCE(u.lastname, 'not defined')
	, balance_grouped.type

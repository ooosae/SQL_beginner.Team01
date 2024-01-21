-- insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29');
-- insert into currency values (100, 'EUR', 0.79, '2022-01-08 13:29');

--   name                 берем из: user.name
--   lastname             берем из: user.lastname
--   currency_name        берем из: currency.name
--   currency_in_usd      берем из: currency.rate_to_usd, currency.updated, balance.updated

-- Sort the result by user name in descending mode and then by user lastname and
-- currency name in ascending mode.

SELECT
	COALESCE("user".name, 'not defined') AS name
	, COALESCE("user".lastname, 'not defined') AS lastname
	, cur.name AS currency_name
	, cur.money * COALESCE(min, max) AS currency_in_usd
FROM 
(
	SELECT
		balance.user_id
		, currency.id
		, currency.name
		, balance.money
		, (
			SELECT currency.rate_to_usd
			FROM currency
			WHERE currency.id = balance.currency_id
				AND currency.updated < balance.updated
			ORDER BY rate_to_usd
			LIMIT 1
		) AS min
		, (
			SELECT currency.rate_to_usd
			FROM currency
			WHERE currency.id = balance.currency_id
				AND currency.updated > balance.updated
			ORDER BY rate_to_usd
			LIMIT 1
		) AS max
	FROM currency
	JOIN balance ON currency.id = balance.currency_id
	GROUP BY 
		balance.money
		, currency.name
		, currency.id
		, balance.updated
		, balance.currency_id
		, balance.user_id
	ORDER BY min DESC, max, balance.updated
) AS cur
LEFT JOIN "user" ON cur.user_id = "user".id
ORDER BY name desc, lastname, currency_name
;


/* BASELINE PERFORMANCE */

-- Overall sessions, orders, conversion rate, bounce rate, cart abandonment rate (CAR), avg. session duration (minutes), and avg. pages per session.
WITH
pageviews_w_entry_exit_times AS (
SELECT
    website_session_id,
    COUNT(DISTINCT website_pageview_id) AS pages_visited,
    MIN(created_at) first_pg_time,
    MAX(created_at) last_pg_time
FROM website_pageviews
WHERE created_at < '2012-06-19'
GROUP BY 1
)

SELECT
    COUNT(DISTINCT pt.website_session_id) AS sessions,
    COUNT(DISTINCT od.order_id) AS orders,
    ROUND((COUNT(DISTINCT od.order_id)
                / COUNT(DISTINCT pt.website_session_id))
	* 100, 2) AS conv_rate,
    ROUND((COUNT(DISTINCT CASE WHEN pt.pages_visited = 1 THEN pt.website_session_id ELSE NULL END)
		/ COUNT(DISTINCT pt.website_session_id))
    	* 100, 2) AS bounce_rate,
    ROUND((1 - (COUNT(DISTINCT CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN pt.website_session_id END) 
		     / COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN pt.website_session_id END))
        ) * 100, 2) AS car,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, pt.first_pg_time, pt.last_pg_time)
        / 60), 2) AS avg_session_minutes,
    ROUND(AVG(pt.pages_visited), 2) AS avg_pages_per_session
FROM pageviews_w_entry_exit_times pt
     LEFT JOIN website_pageviews wp
       ON pt.website_session_id = wp.website_session_id
     LEFT JOIN orders od
       ON pt.website_session_id = od.website_session_id
;


-- Visits, clickthrough rates, and average minutes between pages per conversion funnel stage
WITH
session_timestamps AS (
    SELECT
        ws.website_session_id,
        MIN(CASE WHEN wp.pageview_url = '/home' THEN wp.created_at END) AS home_time,
        MIN(CASE WHEN wp.pageview_url = '/products' THEN wp.created_at END) AS products_time,
        MIN(CASE WHEN wp.pageview_url = '/cart' THEN wp.created_at END) AS cart_time,
        MIN(CASE WHEN wp.pageview_url = '/shipping' THEN wp.created_at END) AS shipping_time,
        MIN(CASE WHEN wp.pageview_url = '/billing' THEN wp.created_at END) AS billing_time,
        MIN(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN wp.created_at END) AS thanks_time
    FROM website_sessions ws
         JOIN website_pageviews wp 
           ON ws.website_session_id = wp.website_session_id
    WHERE ws.created_at < '2012-06-19'
    GROUP BY ws.website_session_id
)

SELECT metric, home, products, cart, shipping, billing, thank_you
FROM (
    -- Pageview sessions
    SELECT 
        'total_visits' AS metric,
        COUNT(home_time) AS home,
        COUNT(products_time) AS products,
        COUNT(cart_time) AS cart,
        COUNT(shipping_time) AS shipping,
        COUNT(billing_time) AS billing,
        COUNT(thanks_time) AS thank_you
    FROM session_timestamps

    UNION ALL

    -- Pageview clickthrough rates
    SELECT 
        'clickthrough_rate' AS metric,
        ROUND(COUNT(products_time) * 100.0 / COUNT(home_time), 2) AS home_click_rt,
        ROUND(COUNT(cart_time) * 100.0 / COUNT(products_time), 2) AS product_click_rt,
        ROUND(COUNT(shipping_time) * 100.0 / COUNT(cart_time), 2) AS cart_click_rt,
        ROUND(COUNT(billing_time) * 100.0 / COUNT(shipping_time), 2) AS shipping_click_rt,
        ROUND(COUNT(thanks_time) * 100.0 / COUNT(billing_time), 2) AS billing_click_rt,
        NULL AS home_click_rt -- Last page of funnel
    FROM session_timestamps

    UNION ALL

    -- Average time between funnel stages
    SELECT 
        'avg_minutes_between' AS metric,
        ROUND(AVG(TIMESTAMPDIFF(SECOND, home_time, products_time) / 60), 2) AS home_to_products,
	ROUND(AVG(TIMESTAMPDIFF(SECOND, products_time, cart_time) / 60), 2) AS products_to_cart,
	ROUND(AVG(TIMESTAMPDIFF(SECOND, cart_time, shipping_time) / 60), 2) AS cart_to_shipping,
	ROUND(AVG(TIMESTAMPDIFF(SECOND, shipping_time, billing_time) / 60), 2) AS shipping_to_billing,
	ROUND(AVG(TIMESTAMPDIFF(SECOND, billing_time, thanks_time) / 60), 2) AS billing_to_thank_you,
        NULL AS last_step -- No time difference after the last step
    FROM session_timestamps
) combined_results
;

-- Bounce rate, average session duration, and average pages per session by traffic source
WITH
pageviews_per_session AS (
SELECT
    website_session_id,
    COUNT(DISTINCT website_pageview_id) AS pages_visited,
    MIN(created_at) first_pg_time,
    MAX(created_at) last_pg_time
FROM website_pageviews
WHERE created_at < '2012-06-19'
GROUP BY 1
)

SELECT
    CASE
	WHEN utm_source IN ('gsearch', 'bsearch') AND utm_campaign IN ('nonbrand', 'brand') THEN 'paid_search'
	WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic_search'
	END AS traffic_source,
    COUNT(DISTINCT pageviews_per_session.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    ROUND((COUNT(DISTINCT orders.order_id)
		/ COUNT(DISTINCT pageviews_per_session.website_session_id))
    	* 100, 2) AS conv_rate,
    ROUND((COUNT(DISTINCT CASE WHEN pages_visited = 1 THEN website_sessions.website_session_id ELSE NULL END)
		/ COUNT(DISTINCT website_sessions.website_session_id))
    	* 100, 2) AS bounce_rate,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, first_pg_time, last_pg_time) / 60), 2) AS avg_session_minutes,
    ROUND(AVG(pages_visited), 2) AS avg_pages_per_session
FROM pageviews_per_session
     JOIN website_sessions
       ON pageviews_per_session.website_session_id = website_sessions.website_session_id
     LEFT JOIN orders
       ON pageviews_per_session.website_session_id = orders.website_session_id
GROUP BY 1
;


-- Sessions per paid search channel
SELECT
    utm_source,
    utm_campaign,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE utm_source IS NOT NULL
  AND created_at < '2012-06-19'
GROUP BY 1, 2
;


-- Sessions, orders, bounce rate, average session duration, and average pages per session by device type
WITH
pageviews_per_session AS (
SELECT
    website_session_id,
    COUNT(DISTINCT website_pageview_id) AS pages_visited,
    MIN(created_at) first_pg_time,
    MAX(created_at) last_pg_time
FROM website_pageviews
WHERE created_at < '2012-06-19'
GROUP BY 1
)

SELECT
    device_type,
    COUNT(DISTINCT pageviews_per_session.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    ROUND((COUNT(DISTINCT orders.order_id)
		/ COUNT(DISTINCT pageviews_per_session.website_session_id))
    	* 100, 2) AS conv_rate,
    ROUND((COUNT(DISTINCT CASE WHEN pages_visited = 1 THEN website_sessions.website_session_id ELSE NULL END)
		/ COUNT(DISTINCT website_sessions.website_session_id))
   	 * 100, 2) AS bounce_rate,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, first_pg_time, last_pg_time) / 60), 2) AS avg_session_minutes,
    ROUND(AVG(pages_visited), 2) AS avg_pages_per_session
FROM pageviews_per_session
     JOIN website_sessions
       ON pageviews_per_session.website_session_id = website_sessions.website_session_id
     LEFT JOIN orders
       ON pageviews_per_session.website_session_id = orders.website_session_id
GROUP BY 1
;



-- New/repeated sessions in gsearch nonbrand paid channel
SELECT
    CASE WHEN is_repeat_session = 0 THEN 'new_sessions' ELSE 'repeated_sessions' END AS session_type,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-06-19'
  AND utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand'
GROUP BY 1
;


-- Sessions, orders, bounce rate, average session duration, and average pages per session by session type (new/repeated)
WITH
pageviews_per_session AS (
    SELECT
        website_session_id,
        COUNT(DISTINCT website_pageview_id) AS pages_visited,
        MIN(created_at) first_pg_time,
        MAX(created_at) last_pg_time
    FROM website_pageviews
    WHERE created_at < '2012-06-19'
    GROUP BY 1
)

SELECT
    CASE WHEN is_repeat_session = 0 THEN 'new_sessions' ELSE 'repeated_sessions' END AS session_type,
    COUNT(DISTINCT pageviews_per_session.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    ROUND((COUNT(DISTINCT orders.order_id)
		/ COUNT(DISTINCT pageviews_per_session.website_session_id))
    	* 100, 2) AS conv_rate,
    ROUND((COUNT(DISTINCT CASE WHEN pages_visited = 1 THEN website_sessions.website_session_id ELSE NULL END)
		/ COUNT(DISTINCT website_sessions.website_session_id))
    	* 100, 2) AS bounce_rate,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, first_pg_time, last_pg_time) / 60), 2) AS avg_session_minutes,
    ROUND(AVG(pages_visited), 2) AS avg_pages_per_session
FROM pageviews_per_session
    JOIN website_sessions
      ON pageviews_per_session.website_session_id = website_sessions.website_session_id
    LEFT JOIN orders
      ON pageviews_per_session.website_session_id = orders.website_session_id
GROUP BY 1
;



-- LANDER PAGE TEST PEFORMANCE

-- Identify the first instance of /lander-1
SELECT
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
;


-- Sessions, orders, bounce rate, average session duration, and average pages per session
WITH
session_pageview_details AS (
    SELECT
	ws.website_session_id,
	COUNT(DISTINCT wp.website_pageview_id) AS pages_visited,
    MIN(wp.website_pageview_id) AS landing_page_id,
	MIN(wp.created_at) first_pg_time,
	MAX(wp.created_at) last_pg_time
    FROM website_sessions ws
	 JOIN website_pageviews wp
	   ON ws.website_session_id = wp.website_session_id
	   AND ws.created_at BETWEEN '2012-06-19' AND '2012-07-28'
	   AND ws.utm_source = 'gsearch'
	   AND ws.utm_campaign = 'nonbrand'
    GROUP BY 1
)

SELECT
    wp.pageview_url,
    COUNT(DISTINCT spd.website_session_id) AS sessions,
    ROUND((COUNT(DISTINCT CASE WHEN spd.pages_visited = 1 THEN spd.website_session_id ELSE NULL END)
		/ COUNT(DISTINCT spd.website_session_id))
    	* 100, 2) AS bounce_rate,
    COUNT(DISTINCT orders.order_id) AS orders,
    ROUND((COUNT(DISTINCT orders.order_id)
		/ COUNT(DISTINCT spd.website_session_id))
    	* 100, 2) AS conv_rate,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, spd.first_pg_time, spd.last_pg_time)
	/ 60), 2) AS avg_session_minutes,
    ROUND(AVG(spd.pages_visited), 2) AS avg_pages_per_session
FROM session_pageview_details spd
     LEFT JOIN website_pageviews wp
       ON spd.landing_page_id = wp.website_pageview_id
     LEFT JOIN orders
       ON spd.website_session_id = orders.website_session_id
GROUP BY 1
;


WITH
session_pageview_details AS (
    SELECT
	ws.website_session_id,
	COUNT(DISTINCT wp.website_pageview_id) AS pages_visited,
    MIN(wp.website_pageview_id) AS landing_page_id,
	MIN(wp.created_at) first_pg_time,
	MAX(wp.created_at) last_pg_time
    FROM website_sessions ws
	 JOIN website_pageviews wp
	   ON ws.website_session_id = wp.website_session_id
	   AND ws.created_at BETWEEN '2012-06-19' AND '2012-07-28'
	   AND ws.utm_source = 'gsearch'
	   AND ws.utm_campaign = 'nonbrand'
    GROUP BY 1
)

SELECT
    wp.pageview_url,
    COUNT(DISTINCT spd.website_session_id) AS sessions,
    ROUND((COUNT(DISTINCT CASE WHEN spd.pages_visited = 1 THEN spd.website_session_id ELSE NULL END)
		/ COUNT(DISTINCT spd.website_session_id))
    	* 100, 2) AS bounce_rate,
    COUNT(DISTINCT orders.order_id) AS orders,
    ROUND((COUNT(DISTINCT orders.order_id)
		/ COUNT(DISTINCT spd.website_session_id))
    	* 100, 2) AS conv_rate,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, spd.first_pg_time, spd.last_pg_time)
	/ 60), 2) AS avg_session_minutes,
    ROUND(AVG(spd.pages_visited), 2) AS avg_pages_per_session
FROM session_pageview_details spd
     LEFT JOIN website_pageviews wp
       ON spd.landing_page_id = wp.website_pageview_id
     LEFT JOIN orders
       ON spd.website_session_id = orders.website_session_id
GROUP BY 1
;




-- BILLING PAGE TEST PERFORMANCE

-- Identify first instance of /billing-2
SELECT
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/billing-2'
;


-- Sessions, orders, conversion rate, average session duration, and average pages per session for billing test pages
WITH
session_pageview_details AS (
    SELECT
	ws.website_session_id,
	COUNT(DISTINCT wp.website_pageview_id) AS pages_visited,
	MIN(wp.created_at) first_pg_time,
	MAX(wp.created_at) last_pg_time
    FROM website_sessions ws
	 JOIN website_pageviews wp
	   ON ws.website_session_id = wp.website_session_id
	   AND ws.created_at BETWEEN '2012-09-10' AND '2012-10-10'
    GROUP BY 1
)

SELECT
    wp.pageview_url,
    COUNT(DISTINCT spd.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    ROUND((COUNT(DISTINCT orders.order_id)
		/ COUNT(DISTINCT spd.website_session_id))
    	* 100, 2) AS conv_rate,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, spd.first_pg_time, spd.last_pg_time) / 60), 2) AS avg_session_minutes,
    ROUND(AVG(spd.pages_visited), 2) AS avg_pages_per_session
FROM session_pageview_details spd
     LEFT JOIN website_pageviews wp
       ON spd.website_session_id = wp.website_session_id
     LEFT JOIN orders
       ON spd.website_session_id = orders.website_session_id
WHERE pageview_url IN ('/billing', '/billing-2')
GROUP BY 1
;



-- MEASURING IMPACT


-- TOTAL SESSIONS BETWEEN '2012-10-01' AND '2012-12-31': 32,060


-- TEST GROUPS

-- Group 1 (Control-Control): Old landing page (A) → Old billing page (A)
-- Group 2 (Control-Treatment): Old landing page (A) → New billing page (B)
-- Group 3 (Treatment-Control): New landing page (B) → Old billing page (A)
-- Group 4 (Treatment-Treatment): New landing page (B) → New billing page (B)


-- Sessions by test landing page
WITH
session_landing_page AS (
SELECT
    ep.website_session_id,
    wp.pageview_url AS landing_page
FROM (
     SELECT
	 website_session_id,
	 MIN(website_pageview_id) AS landing_pv_id
     FROM website_pageviews
     GROUP BY website_session_id
     ) ep
    JOIN website_pageviews wp
      ON ep.landing_pv_id = wp.website_pageview_id
)

SELECT COUNT(DISTINCT wp.website_session_id) AS landing_sessions
FROM website_pageviews wp
     JOIN session_landing_page slp
       ON wp.website_session_id = slp.website_session_id
WHERE wp.created_at BETWEEN '2012-10-01' AND '2012-12-31'
  AND slp.landing_page = '/home'
;

-- Sessions where landing page was /home: 4,985
-- Sessions where landing page was /lander-1: 27,075


-- Sessions by test group
WITH
session_landing_page AS (
    SELECT
        ep.website_session_id,
        wp.pageview_url AS landing_page
    FROM (
         SELECT
             website_session_id,
             MIN(website_pageview_id) AS landing_pv_id
         FROM website_pageviews
         GROUP BY website_session_id
         ) ep
        JOIN website_pageviews wp
          ON ep.landing_pv_id = wp.website_pageview_id
)

SELECT COUNT(DISTINCT wp.website_session_id) AS group_sessions
FROM website_pageviews wp
     JOIN session_landing_page slp
       ON wp.website_session_id = slp.website_session_id
WHERE wp.created_at BETWEEN '2012-10-01' AND '2012-12-31'
  AND slp.landing_page = '/lander-1'
  AND wp.pageview_url = '/billing-2'
;

-- Total across all groups: 2785 sessions
-- Group 1: 252 sessions (9.1%)
-- Group 2: 265 sessions (9.5%)
-- Group 3: 1143 sessions (41%)
-- Group 4: 1125 sessions (40.4)


-- Group 1 Conversion Rate
WITH
session_landing_page AS (
    SELECT
        ep.website_session_id,
        wp.pageview_url AS landing_page
    FROM (
         SELECT
             website_session_id,
             MIN(website_pageview_id) AS landing_pv_id
         FROM website_pageviews
         GROUP BY website_session_id
         ) ep
	 JOIN website_pageviews wp
	   ON ep.landing_pv_id = wp.website_pageview_id
    WHERE created_at BETWEEN '2012-10-01' AND '2012-12-31'
),

sessions_without_billing_2 AS (
    SELECT website_session_id
    FROM website_pageviews
    GROUP BY website_session_id
    HAVING SUM(CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END) = 0  -- Exclude sessions that visited '/billing-2'
)

SELECT ROUND((COUNT(DISTINCT od.order_id) / COUNT(DISTINCT slp.website_session_id)) * 100, 2) AS g1_conv_rate
FROM session_landing_page slp
     JOIN sessions_without_billing_2 sb  -- Ensure no visits to '/billing-2'
       ON slp.website_session_id = sb.website_session_id
     LEFT JOIN orders od
       ON slp.website_session_id = od.website_session_id
WHERE landing_page = '/home'
;

-- CVR: 2.18%


-- Group 2 Conversion Rate
WITH
session_landing_page AS (
    SELECT
        ep.website_session_id,
        wp.pageview_url AS landing_page
    FROM (
         SELECT
             website_session_id,
             MIN(website_pageview_id) AS landing_pv_id
         FROM website_pageviews
         GROUP BY website_session_id
         ) ep
	 JOIN website_pageviews wp
	   ON ep.landing_pv_id = wp.website_pageview_id
    WHERE created_at BETWEEN '2012-10-01' AND '2012-12-31'
),

sessions_without_billing AS (
    SELECT website_session_id
    FROM website_pageviews
    GROUP BY website_session_id
    HAVING SUM(CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END) = 0  -- Exclude sessions that visited '/billing'
)

SELECT ROUND((COUNT(DISTINCT od.order_id) / COUNT(DISTINCT slp.website_session_id)) * 100, 2) AS g2_conv_rate
FROM session_landing_page slp
     JOIN sessions_without_billing sb  -- Ensure no visits to '/billing'
       ON slp.website_session_id = sb.website_session_id
     LEFT JOIN orders od
       ON slp.website_session_id = od.website_session_id
    WHERE landing_page = '/home'
;

-- CVR: 3.49%


-- Group 3 Conversion Rate
WITH
session_landing_page AS (
    SELECT
        ep.website_session_id,
        wp.pageview_url AS landing_page
    FROM (
         SELECT
             website_session_id,
             MIN(website_pageview_id) AS landing_pv_id
         FROM website_pageviews
         GROUP BY website_session_id
         ) ep
	 JOIN website_pageviews wp
	   ON ep.landing_pv_id = wp.website_pageview_id
    WHERE created_at BETWEEN '2012-10-01' AND '2012-12-31'
),

sessions_without_billing_2 AS (
    SELECT website_session_id
    FROM website_pageviews
    GROUP BY website_session_id
    HAVING SUM(CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END) = 0  -- Exclude sessions that visited '/billing-2'
)

SELECT ROUND((COUNT(DISTINCT od.order_id) / COUNT(DISTINCT slp.website_session_id)) * 100, 2) AS g3_conv_rate
FROM session_landing_page slp
     JOIN sessions_without_billing_2 sb  -- Ensure no visits to '/billing-2'
       ON slp.website_session_id = sb.website_session_id
     LEFT JOIN orders od
       ON slp.website_session_id = od.website_session_id
WHERE landing_page = '/lander-1'
;

-- CVR: 1.97%


-- Group 4 Conversion Rate
WITH
session_landing_page AS (
    SELECT
        ep.website_session_id,
        wp.pageview_url AS landing_page
    FROM (
         SELECT
             website_session_id,
             MIN(website_pageview_id) AS landing_pv_id
         FROM website_pageviews
         GROUP BY website_session_id
         ) ep
	 JOIN website_pageviews wp
	   ON ep.landing_pv_id = wp.website_pageview_id
    WHERE created_at BETWEEN '2012-10-01' AND '2012-12-31'
),

sessions_without_billing AS (
    SELECT website_session_id
    FROM website_pageviews
    GROUP BY website_session_id
    HAVING SUM(CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END) = 0  -- Exclude sessions that visited '/billing'
)

SELECT ROUND((COUNT(DISTINCT od.order_id) / COUNT(DISTINCT slp.website_session_id)) * 100, 2) AS g4_conv_rate
FROM session_landing_page slp
     JOIN sessions_without_billing sb  -- Ensure no visits to '/billing'
       ON slp.website_session_id = sb.website_session_id
     LEFT JOIN orders od
       ON slp.website_session_id = od.website_session_id
WHERE landing_page = '/lander-1'
;

-- CVR: 2.72%


SELECT AVG(price_usd) AS aov
FROM orders
WHERE created_at BETWEEN '2012-10-01' AND '2012-12-31'
;

SELECT COUNT(DISTINCT website_session_id) AS cart_sessions
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-01' AND '2012-12-31'
  AND pageview_url = '/cart'
;

-- Group 2 CAR
WITH
session_landing_page AS (
    SELECT
        ep.website_session_id,
        wp.pageview_url AS landing_page
    FROM (
         SELECT
             website_session_id,
             MIN(website_pageview_id) AS landing_pv_id
         FROM website_pageviews
         GROUP BY website_session_id
         ) ep
	 JOIN website_pageviews wp
	   ON ep.landing_pv_id = wp.website_pageview_id
    WHERE created_at BETWEEN '2012-10-01' AND '2012-12-31'
),

sessions_without_billing AS (
    SELECT website_session_id
    FROM website_pageviews
    GROUP BY website_session_id
    HAVING SUM(CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END) = 0  -- Exclude sessions that visited '/billing'
)

SELECT ROUND((1 - (COUNT(DISTINCT CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN slp.website_session_id END) 
                        / COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN slp.website_session_id END))
	    ) * 100, 2) AS car
FROM session_landing_page slp
     JOIN sessions_without_billing sb  -- Ensure no visits to '/billing'
       ON slp.website_session_id = sb.website_session_id
     JOIN website_pageviews wp
       ON slp.website_session_id = wp.website_session_id
     LEFT JOIN orders od
       ON slp.website_session_id = od.website_session_id
WHERE landing_page = '/home'
;

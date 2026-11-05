-- Title: Marketing Channel Attribution by Revenue Percentage
-- Business Question: What percentage of total revenue does each marketing channel contribute?
-- Technique: Window function SUM() OVER() to calculate total, then divide individual channel revenue by total

CREATE TABLE marketing_campaigns (
  campaign_id INTEGER PRIMARY KEY,
  channel TEXT NOT NULL,
  campaign_name TEXT NOT NULL,
  revenue DECIMAL(10, 2) NOT NULL,
  campaign_date DATE NOT NULL
);

INSERT INTO marketing_campaigns VALUES
(1, 'Email', 'Q1 Newsletter', 4500.00, '2024-01-15'),
(2, 'Social Media', 'Spring Promo', 8200.00, '2024-01-20'),
(3, 'Email', 'Flash Sale', 3150.00, '2024-02-10'),
(4, 'Paid Search', 'Google Ads', 12300.00, '2024-02-14'),
(5, 'Social Media', 'Instagram Influencer', 6800.00, '2024-02-28'),
(6, 'Organic', 'Blog Traffic', 2100.00, '2024-03-05'),
(7, 'Paid Search', 'Bing Ads', 9400.00, '2024-03-12'),
(8, 'Email', 'Birthday Campaign', 2700.00, '2024-03-18'),
(9, 'Social Media', 'TikTok Campaign', 7500.00, '2024-03-25'),
(10, 'Organic', 'SEO Traffic', 1950.00, '2024-04-01'),
(11, 'Paid Search', 'Yahoo Ads', 5600.00, '2024-04-10'),
(12, 'Email', 'Year-End Offer', 3400.00, '2024-04-15');

WITH channel_totals AS (
  SELECT
    channel,
    SUM(revenue) as channel_revenue,
    SUM(SUM(revenue)) OVER () as total_revenue
  FROM marketing_campaigns
  GROUP BY channel
)
SELECT
  channel,
  channel_revenue,
  total_revenue,
  ROUND(100.0 * channel_revenue / total_revenue, 2) as revenue_percentage
FROM channel_totals
ORDER BY revenue_percentage DESC;

-- Result (verified in SQLite):
-- channel | channel_revenue | total_revenue | revenue_percentage
-- Paid Search | 27300 | 67600 | 40.38
-- Social Media | 22500 | 67600 | 33.28
-- Email | 13750 | 67600 | 20.34
-- Organic | 4050 | 67600 | 5.99

CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status,
    p.payment_status,
    s.shipping_status
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN payment p ON o.order_id = p.order_id
LEFT JOIN shipping s ON o.order_id = s.order_id;
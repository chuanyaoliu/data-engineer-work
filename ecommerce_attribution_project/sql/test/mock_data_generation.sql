-- Mock数据生成脚本
-- 描述: 生成电商商详页流量归因分析的测试数据
-- 执行时间: 测试环境

-- =============================================
-- 生成ODS层点击日志测试数据
-- =============================================
INSERT INTO TABLE ods_ecommerce_click_log 
PARTITION (dt='2024-01-01')
SELECT 
    CONCAT('user_', LPAD(CAST(RAND() * 1000 AS INT), 4, '0')) as uid,
    CONCAT('session_', LPAD(CAST(RAND() * 500 AS INT), 3, '0')) as sid,
    UNIX_TIMESTAMP('2024-01-01 00:00:00') * 1000 + CAST(RAND() * 86400000 AS BIGINT) as ts,
    CASE 
        WHEN RAND() < 0.3 THEN 'homepage'
        WHEN RAND() < 0.6 THEN 'search_result'
        WHEN RAND() < 0.8 THEN 'recommend_list'
        WHEN RAND() < 0.9 THEN 'product_detail'
        ELSE 'category_list'
    END as page_type,
    CONCAT('https://example.com/', 
        CASE 
            WHEN RAND() < 0.3 THEN 'homepage'
            WHEN RAND() < 0.6 THEN 'search'
            WHEN RAND() < 0.8 THEN 'recommend'
            WHEN RAND() < 0.9 THEN 'product'
            ELSE 'category'
        END, 
        '?id=', CAST(RAND() * 10000 AS INT)
    ) as page_url,
    CASE 
        WHEN RAND() < 0.5 THEN CONCAT('https://example.com/referrer?id=', CAST(RAND() * 1000 AS INT))
        ELSE NULL
    END as referrer_url,
    CASE 
        WHEN RAND() < 0.25 THEN 'homepage'
        WHEN RAND() < 0.5 THEN 'search'
        WHEN RAND() < 0.75 THEN 'recommend'
        ELSE 'direct'
    END as source_channel,
    CASE 
        WHEN RAND() < 0.6 THEN 'mobile'
        WHEN RAND() < 0.8 THEN 'desktop'
        ELSE 'tablet'
    END as device_type,
    CASE 
        WHEN RAND() < 0.7 THEN 'web'
        WHEN RAND() < 0.9 THEN 'app'
        ELSE 'h5'
    END as platform,
    CASE 
        WHEN RAND() < 0.8 THEN CONCAT('product_', LPAD(CAST(RAND() * 1000 AS INT), 4, '0'))
        ELSE NULL
    END as product_id,
    CASE 
        WHEN RAND() < 0.3 THEN 'banner'
        WHEN RAND() < 0.6 THEN 'product_card'
        WHEN RAND() < 0.8 THEN 'search_button'
        ELSE 'recommend_item'
    END as click_element,
    CONCAT('{"extra": "test_data_', CAST(RAND() * 1000 AS INT), '"}') as extra_info
FROM (
    SELECT ROW_NUMBER() OVER() as rn
    FROM (SELECT 1 as x) t1
    LATERAL VIEW explode(split(repeat('1,', 1000), ',')) t2 as col
) t
WHERE rn <= 1000;

-- =============================================
-- 生成ODS层页面浏览日志测试数据
-- =============================================
INSERT INTO TABLE ods_ecommerce_page_view_log 
PARTITION (dt='2024-01-01')
SELECT 
    CONCAT('user_', LPAD(CAST(RAND() * 1000 AS INT), 4, '0')) as uid,
    CONCAT('session_', LPAD(CAST(RAND() * 500 AS INT), 3, '0')) as sid,
    UNIX_TIMESTAMP('2024-01-01 00:00:00') * 1000 + CAST(RAND() * 86400000 AS BIGINT) as ts,
    CASE 
        WHEN RAND() < 0.2 THEN 'homepage'
        WHEN RAND() < 0.4 THEN 'search_result'
        WHEN RAND() < 0.6 THEN 'recommend_list'
        WHEN RAND() < 0.8 THEN 'product_detail'
        WHEN RAND() < 0.9 THEN 'category_list'
        ELSE 'cart'
    END as page_type,
    CONCAT('https://example.com/', 
        CASE 
            WHEN RAND() < 0.2 THEN 'homepage'
            WHEN RAND() < 0.4 THEN 'search'
            WHEN RAND() < 0.6 THEN 'recommend'
            WHEN RAND() < 0.8 THEN 'product'
            WHEN RAND() < 0.9 THEN 'category'
            ELSE 'cart'
        END, 
        '?id=', CAST(RAND() * 10000 AS INT)
    ) as page_url,
    CASE 
        WHEN RAND() < 0.6 THEN CONCAT('https://example.com/referrer?id=', CAST(RAND() * 1000 AS INT))
        ELSE NULL
    END as referrer_url,
    CASE 
        WHEN RAND() < 0.25 THEN 'homepage'
        WHEN RAND() < 0.5 THEN 'search'
        WHEN RAND() < 0.75 THEN 'recommend'
        ELSE 'direct'
    END as source_channel,
    CASE 
        WHEN RAND() < 0.6 THEN 'mobile'
        WHEN RAND() < 0.8 THEN 'desktop'
        ELSE 'tablet'
    END as device_type,
    CASE 
        WHEN RAND() < 0.7 THEN 'web'
        WHEN RAND() < 0.9 THEN 'app'
        ELSE 'h5'
    END as platform,
    CASE 
        WHEN RAND() < 0.7 THEN CONCAT('product_', LPAD(CAST(RAND() * 1000 AS INT), 4, '0'))
        ELSE NULL
    END as product_id,
    CAST(RAND() * 300 + 10 AS INT) as stay_duration,
    CONCAT('{"extra": "test_data_', CAST(RAND() * 1000 AS INT), '"}') as extra_info
FROM (
    SELECT ROW_NUMBER() OVER() as rn
    FROM (SELECT 1 as x) t1
    LATERAL VIEW explode(split(repeat('1,', 1500), ',')) t2 as col
) t
WHERE rn <= 1500;

-- =============================================
-- 生成特定商详页访问数据
-- =============================================
-- 插入一些明确的商详页访问记录
INSERT INTO TABLE ods_ecommerce_page_view_log 
PARTITION (dt='2024-01-01')
SELECT 
    'user_0001' as uid,
    'session_001' as sid,
    UNIX_TIMESTAMP('2024-01-01 10:00:00') * 1000 as ts,
    'product_detail' as page_type,
    'https://example.com/product?id=product_0001' as page_url,
    'https://example.com/homepage' as referrer_url,
    'homepage' as source_channel,
    'mobile' as device_type,
    'app' as platform,
    'product_0001' as product_id,
    120 as stay_duration,
    '{"extra": "specific_test_data"}' as extra_info

UNION ALL

SELECT 
    'user_0002' as uid,
    'session_002' as sid,
    UNIX_TIMESTAMP('2024-01-01 11:00:00') * 1000 as ts,
    'product_detail' as page_type,
    'https://example.com/product?id=product_0002' as page_url,
    'https://example.com/search' as referrer_url,
    'search' as source_channel,
    'desktop' as device_type,
    'web' as platform,
    'product_0002' as product_id,
    180 as stay_duration,
    '{"extra": "specific_test_data"}' as extra_info

UNION ALL

SELECT 
    'user_0003' as uid,
    'session_003' as sid,
    UNIX_TIMESTAMP('2024-01-01 12:00:00') * 1000 as ts,
    'product_detail' as page_type,
    'https://example.com/product?id=product_0003' as page_url,
    'https://example.com/recommend' as referrer_url,
    'recommend' as source_channel,
    'mobile' as device_type,
    'h5' as platform,
    'product_0003' as product_id,
    90 as stay_duration,
    '{"extra": "specific_test_data"}' as extra_info;

-- 单元测试用例
-- 描述: 电商商详页流量归因分析单元测试
-- 执行时间: 测试环境

-- =============================================
-- 测试用例1：正常数据测试
-- =============================================
-- 测试目标：验证正常数据能够正确处理
-- 预期结果：返回10条商详页访问记录
SELECT 
    '测试用例1：正常数据测试' as test_case,
    COUNT(*) as actual_count,
    10 as expected_count,
    CASE WHEN COUNT(*) >= 10 THEN 'PASS' ELSE 'FAIL' END as test_result
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01'
LIMIT 10;

-- =============================================
-- 测试用例2：边界值测试
-- =============================================
-- 测试目标：验证边界值处理
-- 预期结果：路径长度在1-10之间
SELECT 
    '测试用例2：边界值测试' as test_case,
    MIN(path_length) as min_path_length,
    MAX(path_length) as max_path_length,
    CASE 
        WHEN MIN(path_length) >= 1 AND MAX(path_length) <= 10 THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';

-- =============================================
-- 测试用例3：空值处理测试
-- =============================================
-- 测试目标：验证空值处理
-- 预期结果：关键字段无空值
SELECT 
    '测试用例3：空值处理测试' as test_case,
    SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) as null_uid_count,
    SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) as null_sid_count,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as null_product_id_count,
    CASE 
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) = 0 
         AND SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) = 0
         AND SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';

-- =============================================
-- 测试用例4：数据类型测试
-- =============================================
-- 测试目标：验证数据类型正确性
-- 预期结果：时间戳为数字类型，归因权重为小数类型
SELECT 
    '测试用例4：数据类型测试' as test_case,
    COUNT(*) as total_records,
    SUM(CASE WHEN entry_ts > 0 AND product_detail_ts > 0 THEN 1 ELSE 0 END) as valid_timestamp_count,
    SUM(CASE WHEN attribution_weight >= 0 AND attribution_weight <= 1 THEN 1 ELSE 0 END) as valid_weight_count,
    CASE 
        WHEN SUM(CASE WHEN entry_ts > 0 AND product_detail_ts > 0 THEN 1 ELSE 0 END) = COUNT(*)
         AND SUM(CASE WHEN attribution_weight >= 0 AND attribution_weight <= 1 THEN 1 ELSE 0 END) = COUNT(*) THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';

-- =============================================
-- 测试用例5：业务逻辑测试
-- =============================================
-- 测试目标：验证业务逻辑正确性
-- 预期结果：商详页访问时间应晚于入口时间
SELECT 
    '测试用例5：业务逻辑测试' as test_case,
    COUNT(*) as total_records,
    SUM(CASE WHEN product_detail_ts >= entry_ts THEN 1 ELSE 0 END) as valid_sequence_count,
    CASE 
        WHEN SUM(CASE WHEN product_detail_ts >= entry_ts THEN 1 ELSE 0 END) = COUNT(*) THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';

-- =============================================
-- 测试用例6：归因权重测试
-- =============================================
-- 测试目标：验证归因权重计算正确性
-- 预期结果：直接访问权重为1.0，其他按路径长度递减
SELECT 
    '测试用例6：归因权重测试' as test_case,
    COUNT(*) as total_records,
    SUM(CASE WHEN is_direct_visit = true AND attribution_weight = 1.0 THEN 1 ELSE 0 END) as direct_visit_correct,
    SUM(CASE WHEN is_direct_visit = false AND attribution_weight < 1.0 THEN 1 ELSE 0 END) as indirect_visit_correct,
    CASE 
        WHEN SUM(CASE WHEN is_direct_visit = true AND attribution_weight = 1.0 THEN 1 ELSE 0 END) = 
             SUM(CASE WHEN is_direct_visit = true THEN 1 ELSE 0 END)
         AND SUM(CASE WHEN is_direct_visit = false AND attribution_weight < 1.0 THEN 1 ELSE 0 END) = 
             SUM(CASE WHEN is_direct_visit = false THEN 1 ELSE 0 END) THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';

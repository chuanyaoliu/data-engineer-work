-- 性能优化建议脚本
-- 描述: 提供性能优化建议和配置

-- =============================================
-- 分区优化建议
-- =============================================
-- 1. 按日期分区，便于数据管理和查询优化
-- 2. 可考虑按商品类目进行二级分区
-- 3. 定期清理历史分区数据

-- 示例：创建按商品类目的二级分区表
CREATE TABLE IF NOT EXISTS dws_ecommerce_product_detail_attribution_partitioned (
    uid STRING,
    sid STRING,
    product_id STRING,
    entry_channel STRING,
    entry_page_type STRING,
    entry_ts BIGINT,
    product_detail_ts BIGINT,
    path_length INT,
    conversion_time INT,
    is_direct_visit BOOLEAN,
    attribution_weight DECIMAL(10,4),
    device_type STRING,
    platform STRING,
    extra_attributes STRING
)
COMMENT '商详页流量归因汇总表(按商品类目分区)'
PARTITIONED BY (dt STRING, category_id STRING)
STORED AS PARQUET
LOCATION '/data/dws/ecommerce/product_detail_attribution_partitioned'
TBLPROPERTIES (
    'parquet.compression'='SNAPPY'
);

-- =============================================
-- 索引建议
-- =============================================
-- 1. 在uid字段上创建索引，加速用户维度查询
-- 2. 在product_id字段上创建索引，加速商品维度查询
-- 3. 在entry_channel字段上创建索引，加速渠道维度查询

-- 示例：创建索引
-- CREATE INDEX idx_uid ON dws_ecommerce_product_detail_attribution (uid);
-- CREATE INDEX idx_product_id ON dws_ecommerce_product_detail_attribution (product_id);
-- CREATE INDEX idx_entry_channel ON dws_ecommerce_product_detail_attribution (entry_channel);

-- =============================================
-- 资源调优建议
-- =============================================
-- Spark资源配置建议
SET spark.executor.memory=4g;
SET spark.executor.cores=2;
SET spark.executor.instances=10;
SET spark.driver.memory=2g;
SET spark.sql.adaptive.enabled=true;
SET spark.sql.adaptive.coalescePartitions.enabled=true;
SET spark.sql.adaptive.skewJoin.enabled=true;
SET spark.sql.adaptive.skewJoin.skewedPartitionFactor=5;
SET spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes=256MB;

-- =============================================
-- 数据倾斜处理
-- =============================================
-- 1. 识别数据倾斜
SELECT 
    uid,
    COUNT(*) as record_count
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01'
GROUP BY uid
ORDER BY record_count DESC
LIMIT 10;

-- 2. 数据倾斜处理方案
-- 方案1：增加随机前缀
-- 方案2：使用两阶段聚合
-- 方案3：调整分区策略

-- 示例：两阶段聚合处理数据倾斜
WITH first_stage AS (
    SELECT 
        CONCAT(CAST(RAND() * 10 AS INT), '_', uid) as uid_with_prefix,
        sid,
        product_id,
        entry_channel,
        entry_page_type,
        entry_ts,
        product_detail_ts,
        path_length,
        conversion_time,
        is_direct_visit,
        attribution_weight,
        device_type,
        platform,
        extra_attributes
    FROM dws_ecommerce_product_detail_attribution
    WHERE dt='2024-01-01'
),
second_stage AS (
    SELECT 
        SUBSTR(uid_with_prefix, 3) as uid,
        sid,
        product_id,
        entry_channel,
        entry_page_type,
        entry_ts,
        product_detail_ts,
        path_length,
        conversion_time,
        is_direct_visit,
        attribution_weight,
        device_type,
        platform,
        extra_attributes
    FROM first_stage
)
SELECT * FROM second_stage;

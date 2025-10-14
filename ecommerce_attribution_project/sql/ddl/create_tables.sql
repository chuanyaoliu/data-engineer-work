-- 电商商详页流量归因数据模型DDL
-- 创建时间: 2024-01-01
-- 描述: 电商商详页流量归因分析的四层数据模型

-- =============================================
-- ODS层表结构
-- =============================================

-- ODS层点击日志表
CREATE TABLE IF NOT EXISTS ods_ecommerce_click_log (
    uid STRING COMMENT '用户ID',
    sid STRING COMMENT '会话ID', 
    ts BIGINT COMMENT '时间戳',
    page_type STRING COMMENT '页面类型',
    page_url STRING COMMENT '页面URL',
    referrer_url STRING COMMENT '来源页面URL',
    source_channel STRING COMMENT '来源渠道',
    device_type STRING COMMENT '设备类型',
    platform STRING COMMENT '平台',
    product_id STRING COMMENT '商品ID',
    click_element STRING COMMENT '点击元素',
    extra_info STRING COMMENT '扩展信息'
)
COMMENT '电商点击日志原始数据表'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/data/ods/ecommerce/click_log'
TBLPROPERTIES (
    'parquet.compression'='SNAPPY'
);

-- ODS层页面浏览日志表
CREATE TABLE IF NOT EXISTS ods_ecommerce_page_view_log (
    uid STRING COMMENT '用户ID',
    sid STRING COMMENT '会话ID',
    ts BIGINT COMMENT '时间戳', 
    page_type STRING COMMENT '页面类型',
    page_url STRING COMMENT '页面URL',
    referrer_url STRING COMMENT '来源页面URL',
    source_channel STRING COMMENT '来源渠道',
    device_type STRING COMMENT '设备类型',
    platform STRING COMMENT '平台',
    product_id STRING COMMENT '商品ID',
    stay_duration INT COMMENT '停留时长(秒)',
    extra_info STRING COMMENT '扩展信息'
)
COMMENT '电商页面浏览日志原始数据表'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/data/ods/ecommerce/page_view_log'
TBLPROPERTIES (
    'parquet.compression'='SNAPPY'
);

-- =============================================
-- DWD层表结构
-- =============================================

-- DWD层用户行为路径表
CREATE TABLE IF NOT EXISTS dwd_ecommerce_user_behavior_path (
    uid STRING COMMENT '用户ID',
    sid STRING COMMENT '会话ID',
    ts BIGINT COMMENT '时间戳',
    action_type STRING COMMENT '行为类型(click/view)',
    page_type STRING COMMENT '页面类型',
    page_url STRING COMMENT '页面URL',
    referrer_url STRING COMMENT '来源页面URL',
    source_channel STRING COMMENT '来源渠道',
    device_type STRING COMMENT '设备类型',
    platform STRING COMMENT '平台',
    product_id STRING COMMENT '商品ID',
    click_element STRING COMMENT '点击元素',
    stay_duration INT COMMENT '停留时长(秒)',
    path_step INT COMMENT '路径步骤序号',
    is_product_detail BOOLEAN COMMENT '是否为商详页',
    extra_info STRING COMMENT '扩展信息'
)
COMMENT '电商用户行为路径明细表'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/data/dwd/ecommerce/user_behavior_path'
TBLPROPERTIES (
    'parquet.compression'='SNAPPY'
);

-- =============================================
-- DWS层表结构
-- =============================================

-- DWS层商详页流量归因汇总表
CREATE TABLE IF NOT EXISTS dws_ecommerce_product_detail_attribution (
    uid STRING COMMENT '用户ID',
    sid STRING COMMENT '会话ID',
    product_id STRING COMMENT '商品ID',
    entry_channel STRING COMMENT '入口渠道',
    entry_page_type STRING COMMENT '入口页面类型',
    entry_ts BIGINT COMMENT '入口时间戳',
    product_detail_ts BIGINT COMMENT '商详页访问时间戳',
    path_length INT COMMENT '路径长度',
    conversion_time INT COMMENT '转化时长(秒)',
    is_direct_visit BOOLEAN COMMENT '是否直接访问',
    attribution_weight DECIMAL(10,4) COMMENT '归因权重',
    device_type STRING COMMENT '设备类型',
    platform STRING COMMENT '平台',
    extra_attributes STRING COMMENT '扩展属性'
)
COMMENT '商详页流量归因汇总表'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/data/dws/ecommerce/product_detail_attribution'
TBLPROPERTIES (
    'parquet.compression'='SNAPPY'
);

-- =============================================
-- ADS层表结构
-- =============================================

-- ADS层商详页流量归因应用表
CREATE TABLE IF NOT EXISTS ads_ecommerce_attribution_summary (
    stat_date STRING COMMENT '统计日期',
    product_id STRING COMMENT '商品ID',
    entry_channel STRING COMMENT '入口渠道',
    entry_page_type STRING COMMENT '入口页面类型',
    pv_count BIGINT COMMENT '页面访问量',
    uv_count BIGINT COMMENT '独立用户数',
    session_count BIGINT COMMENT '会话数',
    avg_path_length DECIMAL(10,2) COMMENT '平均路径长度',
    avg_conversion_time DECIMAL(10,2) COMMENT '平均转化时长',
    direct_visit_rate DECIMAL(10,4) COMMENT '直接访问率',
    attribution_weight_sum DECIMAL(15,4) COMMENT '归因权重总和',
    device_type STRING COMMENT '设备类型',
    platform STRING COMMENT '平台'
)
COMMENT '商详页流量归因应用汇总表'
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION '/data/ads/ecommerce/attribution_summary'
TBLPROPERTIES (
    'parquet.compression'='SNAPPY'
);

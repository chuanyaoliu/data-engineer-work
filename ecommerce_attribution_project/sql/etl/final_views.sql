-- 创建标准化别名视图，便于本地沙箱读取最终结果
-- 说明：本视图不写入生产，仅用于本地回放与可视化

-- DWS 结果别名（需要在会话中设置 dt 参数）
CREATE OR REPLACE TEMP VIEW dws_result_view AS
SELECT * FROM dws_ecommerce_product_detail_attribution WHERE dt='${hiveconf:dt}';

-- ADS 结果别名（需要在会话中设置 dt 参数）
CREATE OR REPLACE TEMP VIEW ads_result_view AS
SELECT * FROM ads_ecommerce_attribution_summary WHERE dt='${hiveconf:dt}';



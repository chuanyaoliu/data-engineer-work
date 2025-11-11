## 示例：订单 GMV 指标偏差修复

- 场景：同比指标偏低
- 发现：`distribution_watch.sql` 告警 GMV 日波动 > 3σ
- 排查：参考 `sample_order_metrics.sql` 与分区产出正常，定位到状态枚举缺失映射
- 修复：在 ETL 增加枚举映射与默认值，回归通过



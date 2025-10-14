## Cursor 规则清单（可直接粘贴至 Rules 面板）

说明：将每段「标题 / 内容 / Scope」作为单独 Rule 创建。Scope 建议：
- Global：通用与安全
- Workspace：本项目专有
- File pattern：按目录/扩展名精准生效

---

### 1) SQL 风格与性能规范
Scope: `ecommerce_attribution_project/sql/**/*.sql`

内容（粘贴到 Rule 内容区）：

```
- 使用 ANSI SQL；禁止 SELECT *；字段显式列出并按业务含义排序
- 所有 JOIN 必须指明 ON 条件并考虑 NULL 语义；优先使用显式 JOIN 类型
- 聚合前先过滤；WHERE/ON 中避免对列包函数使索引失效
- 分区表：所有扫描必须包含分区裁剪条件（如 dt, ds, event_date）
- 禁止笛卡尔积；需要 CROSS JOIN 必须注明小表广播策略
- 对窗口函数：仅使用必要的 PARTITION BY/ORDER BY 列；限制窗口大小
- 命名: 表蛇形、小写；别名语义化；临时表以 tmp_ 开头
- 注释必须说明业务口径、粒度、时间窗口、去重策略
```

---

### 2) ETL 分层与口径一致性
Scope: `ecommerce_attribution_project/sql/etl/**`

```
- 分层命名: ODS(原始) -> DWD(明细) -> DWS(汇总) -> ADS(应用)
- 上下游字段口径必须一致；变更需在 README 与数据字典同步
- 去重/主键/幂等策略需显式说明；增量优先，避免全表扫描
- 任务依赖必须在调度层声明；SQL 内不要隐式等待
```

---

### 3) 数据质量与监控
Scope: `ecommerce_attribution_project/sql/**/*.sql`, `ecommerce_attribution_project/**/*.py`

```
- 为关键表添加质量校验：空值率、唯一性、引用一致性、边界值
- 每个任务输出指标: 输入/输出行数、过滤比例、延迟
- 异常阈值 -> 告警；失败必须 fail-fast，不可吞错误
- 对修复/补数脚本，需记录影响范围与回滚方案
```

---

### 4) PySpark/Spark 代码规范
Scope: `**/*.py`, `**/*.scala`

```
- DataFrame API 优先；避免过度 UDF；如需 UDF 优先 pandas_udf 并注明向量化
- 控制分区数与 shuffle：读后 coalesce/repartition 需解释原因
- 广播小表: 使用 broadcast() 并限制大小；避免无界广播
- 缓存仅在多次重用时启用，并在最后 unpersist
- 禁止在 driver 收集大数据；collect 限制样本量并注释用途
- 所有 I/O 必须显式 schema；禁止推断 schema 于生产
- 严格日志：关键指标、行数、分区数、耗时
```

---

### 5) Airflow/DAG 规范
Scope: `**/dags/**/*.py`

```
- DAG 命名: 业务_对象_动作；dag_id 唯一且小写
- 任务原子化；id 语义化；不可在 task 内做多阶段逻辑
- 依赖用 >> / << 明确；禁止隐式依赖
- 重试与超时必须设置；对幂等任务说明去重策略
- XCom 控制体积；跨任务传递仅元数据，不传大对象
- 所有外部系统连接通过连接管理（Conn Id），禁止硬编码凭据
```

---

### 6) 测试与可回放性
Scope: `ecommerce_attribution_project/sql/test/**`, `**/tests/**`

```
- 提供最小可复现的 mock 数据；覆盖边界与异常路径
- SQL 结果校验必须断言主口径字段；数值容忍范围需说明
- 本地与 CI 可回放：固定种子、固定时间窗口、固定输入
```

---

### 7) 元数据与文档
Scope: `ecommerce_attribution_project/README.md`, `ecommerce_attribution_project/docs/**`

```
- 每次口径/字段变更必须更新数据字典与血缘图
- 文档模板：目的、输入输出、粒度、时间窗、去重与主键、调度、失败回滚、SLA
- 对外暴露 ADS 表需提供查询样例与注意事项
```

---

### 8) 安全与合规（Global）
Scope: Global

```
- 禁止在代码/SQL 中出现明文凭据、令牌、隐私数据样例
- 导出/审计日志需脱敏；遵循最小权限原则
- 本地调试数据不得提交仓库
```

---

### 9) 性能回归防护（Global）
Scope: Global

```
- 任何新增扫描必须提供基线行数/耗时与变更后对比
- 大表 JOIN/窗口/去重需给出数据量级与分区裁剪说明
- 若可能引入全表重算，必须提方案避免或降低频率
```

---

### 10) 项目特定：电商归因口径
Scope: `ecommerce_attribution_project/**`

```
- 分层字段命名与口径需与 docs/technical_documentation.md 保持一致
- 归因窗口、去重规则、主键策略如有变更必须同步更新文档与测试
- ADS 查询样例需覆盖商详页入口渠道与转化指标
```



# 文件摘要（26项，中文）

- context/catalog/README.md：说明物理目录树用途与字段信息；驱动 GE 规则与数据契约。
- context/catalog/sample_catalog.yaml：示例目录，含 ODS/DWD 表、主键/分区/字段与敏感级别。
- context/subject/README.md：说明语义主题树；MetricFlow 风格指标与 reference SQL 约定。
- context/subject/ecommerce/metrics.yaml：电商订单主题；指标、维度、规则，含主键/事件时间/分区。
- context/subject/ecommerce/reference_sql/sample_order_metrics.sql：日粒度订单指标参考 SQL（计数与金额）。
- context/success_stories/README.md：记录成功/失败案例的方法，用于上下文与评测集沉淀。
- context/success_stories/samples.md：示例事件：GMV 偏差的原因定位与修复结论。
- agents/subagents/ecommerce/config.yaml：电商 scoped subagent 配置，绑定 catalog/subject 路径与工具权限。
- agents/subagents/ecommerce/prompts.md：subagent 系统提示：优先召回/小步改写，展示 explain 与优化建议。
- requirements/templates/requirement_intake.md：需求收集模板，覆盖输入/输出/SLA/质量/依赖。
- requirements/templates/data_contract.json：数据契约 JSON Schema；生成上下文/规则的依据。
- requirements/transformers/gen_context_from_requirement.py：占位转换脚本；根据契约输出计划产物。
- sql/reference/README.md：高价值 reference SQL 目录说明，便于召回与小步改写。
- sql/etl/dwd_etl.sql：标准 Spark SQL 骨架：增量边界、去重、晚到处理、审计字段。
- sql/tests/regression/compare_rowcount.sql：基线 vs 当前的行数回归对比。
- sql/tests/regression/compare_pk_unique.sql：基线 vs 当前的主键唯一性与行数对比。
- tests/pyspark/local_selftest_example.py：本地最小 PySpark 自测脚本（样例数据与断言）。
- tests/expectations/ge_basic.yml：GE 基本规则：最小行数、主键非空/唯一、状态枚举正则。
- tests/expectations/ge_catalog_expectations.yml：由目录派生的 GE 规则：非空、唯一、枚举。
- monitoring/sql/sla_partition_ready.sql：当日分区产出就绪检查（SLA）。
- monitoring/sql/quality_core_checks.sql：质量核心快照：空值、主键基数、总行数。
- monitoring/sql/distribution_watch.sql：滚动分布与波动监控（行数/GMV 的 Z 分数）。
- workflows/cli_recipes.md：CLI 工作流：召回 → 执行/解释 → 观测 → 反思 → 记录。
- workflows/runbook.md：运维手册：常见问题与自愈建议。
- docs/README.md：顶层指引，四环节的使用路径与入口。
- docs/ADRs/adr-0001-context-engine.md：架构决策：双树 Context Engine 与 subagent 交付。\n


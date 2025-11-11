# 数据工程 Agent 脚手架（Datus 风格）

覆盖四环节：需求拆解 → Spark SQL 自测调试 → 测试验证（GE + 回归）→ 数据监控（SLA/质量/波动）。
参考：`https://docs.datus.ai/`

快速开始：
1) 填写 `requirements/templates/requirement_intake.md` 与 `data_contract.json`
2) 运行转换脚本生成上下文草案：`requirements/transformers/gen_context_from_requirement.py`
3) 在 `sql/etl/` 按骨架开发 SQL，并用 `tests/pyspark/local_selftest_example.py` 本地自测
4) 运行 `tests/expectations/*.yml` 与 `sql/tests/regression/*.sql` 做回归验证
5) 上线后用 `monitoring/sql/*.sql` 监控 SLA/质量/分布波动，并记录 success_stories



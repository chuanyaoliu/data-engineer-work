# Runbook（异常与自愈建议）

- 分区未产出：延迟容忍阈值内可等待；超阈值触发上游检查与重放
- 主键不唯一：定位重复来源表分区，执行去重修复 SQL，回归验证
- 状态枚举异常：回滚映射或补充默认值，触发 GE 与回归
- 波动超阈值：分析 Top 维度贡献，确认是否业务活动/促销导致

## 使用指引（AI 助力端到端）
- 初始化目录与模板：
  - `python scripts/cli/ai_de_helper.py init`
  - `python scripts/cli/ai_de_helper.py gen-templates`
- 依提示完成：需求拆解 → SQL 草案与自测 → 用例与断言 → 监控配置
- 产物目录：`artifacts/` 下的 requirements/sql/tests/monitoring
- 方案总览见：`docs/solution/AI_assisted_data_engineering_workflow.md`



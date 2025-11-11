## AI 助力数据工程端到端方案（需求→SQL→测试→监控）

### 目标
- 将需求拆解、Spark SQL 开发与自测、测试验收、数据监控四环整合为可复制的工程化流程。
- 通过固定提示模板与轻量脚手架，显著缩短从需求到上线的周期。

### 目录结构建议
- `templates/prompt/`：标准提示词模板
- `scripts/cli/`：轻量 CLI 脚手架
- `artifacts/`：各环节产物输出（自动生成）
  - `artifacts/requirements/` 名词口径、映射、澄清
  - `artifacts/sql/` SQL 草案、校验 SQL
  - `artifacts/tests/` 用例表、断言 SQL、报告
  - `artifacts/monitoring/` 监控规则与配置

### 使用步骤
1) 初始化与模板生成
- 复制 `templates/prompt/` 到本需求目录，或使用 CLI 自动生成：
  - `python scripts/cli/ai_de_helper.py init`
  - `python scripts/cli/ai_de_helper.py gen-templates`

2) 需求拆解
- 将业务需求黏贴到 `artifacts/requirements/requirement.md`
- 用 `templates/prompt/01_requirement_decomposition.md` 向 AI 提交，产出：
  - `artifacts/requirements/glossary.md`
  - `artifacts/requirements/source_mapping.xlsx`
  - `artifacts/requirements/dag_tasks.csv`
  - `artifacts/requirements/clarifications.md`

3) SQL 开发与自测
- 基于映射与口径，用 `02_sql_generation.md` 生成：
  - `artifacts/sql/create_table.sql`（如需要）
  - `artifacts/sql/query.sql`
  - `artifacts/sql/checks.sql`
- 使用 `03_mock_and_selftest.md` 生成 mock 数据与 Notebook 步骤，完成本地小样本验证。

4) 测试与验收
- 用 `04_testcases_and_assertions.md` 产出：
  - `artifacts/tests/testcases.csv`
  - `artifacts/tests/assertions.sql`
- 在 CI 中执行断言 SQL，产出 JUnit/HTML 报告 `artifacts/tests/report/`。

5) 监控与告警
- 使用 `05_monitoring_rules.md` 生成监控 SQL/配置：
  - `artifacts/monitoring/rules.sql` 或 `rules.yaml`
- 对接现有调度/告警系统，设置预警/严重分级与接收人。

### 持续化做法
- 将产物纳入知识库（RAG）：历史口径、映射、范式与风格，提升 AI 生成稳定性。
- 保持模板版本化，每次复盘产出模板改进点。

### 成功标准
- 需求到 SQL 草案 ≤ 0.5 天；自测与回归 ≤ 0.5 天；上线当日产出可被监控覆盖。
- 回归失败率下降、告警可解释性增强、修复时长缩短。



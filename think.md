
## 数据开发提效

agent

mcp

理解需求，编码测试逻辑准确，mock数据测试验收



git remote add origin https://github.com/chuanyaoliu/data-engineer-work.git

### 方案一

大数据数仓开发，包括需求拆解，写spark sql自测调试，测试验证，数据监控 这四个环节，我想节约ai的能力做提效，你有什么好的方法

提示词（可直接在 Cursor 使用）
- 连接与上下文注入：请加载当前仓库与这份需求描述/PRD/会议纪要，读取相关表的Schema与血缘（若有），输出你需要补充的信息清单和最终应产出的物料列表（需求单、口径卡片、开发Checklist、测试用例、监控策略）。
- Agent 协作（多角色）：现在分别扮演数据建模师、SQL优化师、测试工程师、运维监控工程师。基于口径卡片，各自给出产出：建模方案与命名规范、优化后的Spark SQL与Explain解读、测试数据与断言、监控与告警策略。最后汇总成一份交付清单。
- MCP 工具调用：使用可用工具读取表Schema、采样100行、生成Explain、执行质量规则。若缺少信息，先生成最小查询或探测SQL并标注风险，再给出下一步需要的上下文。
- 需求理解：基于以下需求，请生成“指标口径卡片”和“开发Checklist”，并列出需要业务方澄清的问题（按优先级排序）。
- 编码自测：这是我的Spark SQL与样例数据，请审查是否符合口径，指出语义与性能风险，并给出3条可执行优化建议（附修改片段）。
- Mock 与验收：请基于口径生成覆盖边界/异常的Mock数据、期望输出样例，以及可直接用于Great Expectations/dbt tests的质量规则配置。

下面给出可落地的“四段式”AI助力方案（含可复制提示词模版与工具建议）：

1) 需求拆解（对齐口径与产出物）
- 目标：把模糊业务需求转成标准化工单（口径、口径边界、口径版本、口径Owner、依赖、产出表/字段、验收口径）。
- 做法：
  - 用AI生成“需求澄清清单”和“口径词典”，要求输出：业务背景、指标定义、口径边界、时间粒度、维度口径、历史回补、数据新鲜度SLA、依赖上游、影响评估、验收样例。
  - 输入：原始需求/会议纪要/PRD + 现有数仓分层与血缘。
  - 产出：标准化需求单、依赖图、开发Checklist。
- 提示词模版：
  - 请基于以下需求，按模板生成“指标口径卡片”和“开发Checklist”。模板要求字段：指标名称、业务口径、计算口径（SQL草案/伪码）、时间/空间粒度、维度定义、过滤条件、边界与例外、上游依赖表/字段、落库层级与命名、数据新鲜度与SLA、回补策略、验收样例（输入/期望输出）。

2) Spark SQL 自测与调优（本地/开发环境）
- 目标：更快写出可跑、可解释、可复用的SQL，并提前发现性能与语义问题。
- 做法：
  - 代码伴侣：基于表Schema与样例数据，用AI补全SQL骨架、生成注释、产出可视化执行计划解读（Explain分析要点：Shuffle、Skew、Broadcast、Filter下推等）。
  - 语义守卫：让AI进行“口径对照审查”（是否遗漏过滤、Join口径是否一致、时间窗是否正确、Late Data处理）。
  - 性能建议：给出分区裁剪、重分区、Broadcast Hint、窗口函数替代、物化中间表等建议，并标注收益预估。
- 提示词模版：
  - 这是表Schema与样例数据、以及我的SQL草案。请审查是否符合口径卡片；指出潜在语义风险（具体到字段/过滤/Join条件）；根据Explain计划给出3条可操作调优建议（附修改后的SQL片段）。

3) 测试与验收（单测/集成/回归）
- 目标：把“对不对”自动化，覆盖口径正确性与数据质量。
- 做法：
  - 合成数据：提供口径边界样例，让AI生成覆盖边界/异常/极值/历史回补的Mock数据。
  - 期望结果：AI根据口径卡片自动生成期望输出样例与断言。
  - 质量规则：让AI从SQL推导数据质量校验（唯一性、非空、值域、分布漂移、时间完整性等），输出可直接用于Great Expectations/dbt tests的规则。
- 提示词模版：
  - 基于这份“口径卡片”和SQL，请生成：
    1) Mock数据（CSV/INSERT语句，覆盖边界与异常）；
    2) 期望输出（含关键字段）；
    3) 数据质量校验清单（唯一/非空/范围/Referential/分布漂移），并生成Great Expectations或dbt tests配置样例。

4) 数据监控（运行期可观测性与告警）
- 目标：问题可提前预警、定位可追踪、回滚与修复有SOP。
- 做法：
  - 运行监控：让AI基于SLA与血缘生成DAG监控规则（延迟、失败重试、上游卡顿影响评估）。
  - 质量监控：从测试规则自动同步到生产：行数阈值、空值率、唯一性、分布漂移、口径对比（对标黄金指标）。
  - 异常解释：当出现异常，AI读取最近变更（SQL Diff、依赖变更、数据分布漂移），生成“可读异常报告”和“处置建议/回滚策略”。
- 提示词模版：
  - 请基于该表的SLA与血缘生成生产监控策略：调度频率、延迟阈值、质量规则、联系人与升级路径；当出现延迟/指标突变时，请输出自动化排障步骤（检查项清单与命令/SQL）。

工具与落地建议
- 开发侧：VSCode/Cursor + SQL插件 + Spark shell/Notebook；接入AI代码伴侣和Explain解析器。
- 质量侧：Great Expectations 或 dbt tests；用AI从口径自动生成校验配置。
- 监控侧：Airflow/Dagster + 数据质量平台（开源或自建）+ 告警到IM；AI用于异常解释与修复SOP生成。
- 知识侧：沉淀“口径卡片”“需求澄清清单”“变更记录”，让AI以库为上下文持续学习复用。

度量闭环（评估提效）
- 记录每单需求的：沟通轮次、开发耗时、自测缺陷数、上线缺陷数、回滚次数、MTTR。上线前后做A/B对比，量化AI带来的减少比例。

最小可行实践(MVP)
- 从一个指标域开始：挑选1个需求，完整使用以上模版与工具；沉淀首批口径卡片与测试配置；将监控告警打通到IM；复盘并微调提示词与流程。

MCP 工具清单与调用示例（可作模板）
- 目标：把“会话里的口径与SQL”落到行动：取Schema、采样、Explain、质量校验、产物落盘。
- 工具位（根据你实际安装的 MCP 工具替换名称）：
  - sql.introspect(schema_name, table_name)：拉取表结构与分区信息
  - sql.sample(table, limit, where?)：采样数据（可附过滤）
  - sql.explain(query)：返回执行计划文本
  - files.write(path, content)：将生成的卡片/测试/配置落盘
  - shell.exec(cmd, cwd?)：调用本地命令（如 dbt、great_expectations）
- 调用提示词模板：
  - 请调用 sql.introspect(schema='dwd', table='fact_order') 并输出字段名、类型、分区字段、注释，随后基于结果补全“口径卡片”的字段定义区段。
  - 请调用 sql.sample(table='dwd.fact_order', limit=100, where='dt >= current_date - 3')，用采样数据校验口径中的过滤条件是否满足，输出发现的问题与修正建议。
  - 请对以下 Spark SQL 调用 sql.explain，并从 Shuffle 次数、数据倾斜、Broadcast 使用、过滤下推四个维度给出优化建议，附修改后的SQL片段。
  - 请根据“质量规则清单”为 great_expectations 生成一个表级与列级的配置样例，并使用 files.write 将其保存到 tests/expectations/fact_order.json，然后给出 shell.exec 的命令示例以运行校验。
  - 请将“指标口径卡片”“开发Checklist”“监控策略”分别写入 docs/metrics/fact_order.md、docs/checklists/fact_order.md、docs/monitoring/fact_order.md（使用 files.write）。

Mock 数据（已生成）
- 路径：data/mock/fact_order.csv
- 覆盖：
  - 正常订单、多渠道/多区域
  - 零金额、负金额、数量为0（边界）
  - 重复订单行（去重验证）
  - 延迟到达数据（order_time=2025-11-01，dt=2025-11-05）
  - 未来时间（2025-12-01）与极大金额

MVP 可执行样例
- Spark DDL：sql/reference/fact_order_create.sql
- Spark 加载：sql/reference/fact_order_load.sql（从 data/mock/fact_order.csv 导入）
- Great Expectations：tests/expectations/fact_order.json（表结构、非空、唯一、范围、格式）
- dbt tests：models/dwd/fact_order.yml（unique/not_null）

运行提示（可用于 MCP shell.exec）
- spark-sql -f sql/reference/fact_order_create.sql
- spark-sql -f sql/reference/fact_order_load.sql
- great_expectations checkpoint run fact_order_suite  或 使用 data-context 方式加载 tests/expectations/fact_order.json
- dbt test --select fact_order

Demo 运行
- Windows（PowerShell）：
  - powershell -ExecutionPolicy Bypass -File scripts/run_fact_order_demo.ps1
- 可选（Airflow）：
  - 将仓库挂载到 Airflow 工作目录后，在 UI 中触发 DAG `fact_order_demo`





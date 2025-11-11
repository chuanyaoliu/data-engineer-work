# ADR-0001: 采用两棵树的 Context Engine

决策：以物理目录树（catalog）与语义主题树（subject）组织上下文，沉淀 metadata、reference SQL、metrics 与 success stories；通过 subagent 以 scoped context 交付；workflow 退居兜底。

动机：与 `https://docs.datus.ai/` 的设计一致，解决数据工程效率瓶颈来自“理解/验证/反馈闭环”，非单纯 SQL 生成。

后果：上下文可持续演化，可回归评测；工具以原生数据库优先，MCP/编排仅为扩展与兜底。



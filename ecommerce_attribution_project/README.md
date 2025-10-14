# 电商商详页流量归因数据需求开发项目

## 项目概述

本项目实现了电商商详页流量归因分析系统，通过分析用户从不同入口（首页营销、搜索、推荐页）到达商详页的流量路径，为营销策略优化和用户体验改进提供数据支持。

## 项目结构

```
ecommerce_attribution_project/
├── README.md                           # 项目说明文档
├── sql/                               # SQL脚本目录
│   ├── ddl/                          # DDL语句
│   │   └── create_tables.sql         # 创建表结构
│   ├── etl/                          # ETL脚本
│   │   ├── ods_etl.sql              # ODS层ETL
│   │   ├── dwd_etl.sql              # DWD层ETL
│   │   ├── dws_etl.sql              # DWS层ETL
│   │   ├── ads_etl.sql              # ADS层ETL
│   │   └── run_all_etl.sql          # 完整ETL执行
│   ├── test/                         # 测试脚本
│   │   ├── mock_data_generation.sql  # Mock数据生成
│   │   ├── script_debug.sql         # 脚本调试
│   │   ├── performance_optimization.sql # 性能优化
│   │   ├── unit_tests.sql           # 单元测试
│   │   ├── integration_tests.sql    # 集成测试
│   │   ├── boundary_tests.sql       # 边界条件测试
│   │   └── run_all_tests.sql        # 完整测试执行
│   └── monitoring/                   # 监控脚本
│       ├── data_quality_monitor.sql # 数据质量监控
│       └── performance_monitor.sql  # 性能监控
├── scripts/                          # 脚本目录
│   └── deploy/                       # 部署脚本
│       └── deploy.sh                # 部署脚本
├── config/                           # 配置目录
│   └── monitoring/                   # 监控配置
│       └── alerts.yml               # 告警配置
└── docs/                            # 文档目录
    ├── technical_documentation.md   # 技术文档
    ├── architecture_diagram.md      # 架构图
    ├── test/                        # 测试文档
    │   ├── test_report.md           # 测试报告
    │   └── issue_tracking.md        # 问题跟踪
    └── operations/                  # 运维文档
        └── maintenance_manual.md    # 运维手册
```

## 功能特性

### 核心功能
- **用户行为路径构建**：基于点击和浏览日志构建完整的用户行为路径
- **流量归因分析**：识别用户从不同入口到达商详页的转化路径
- **入口渠道识别**：支持首页营销、搜索、推荐页等入口渠道识别
- **归因权重计算**：基于路径长度和转化时间计算归因权重

### 技术特性
- **四层数据模型**：ODS/DWD/DWS/ADS分层设计
- **实时数据处理**：支持准实时数据处理
- **数据质量监控**：完善的数据质量监控体系
- **性能优化**：针对数据倾斜和性能问题的优化方案

## 快速开始

### 环境要求
- Hadoop 3.2.0+
- Hive 3.1.0+
- Spark 3.2.0+
- Java 1.8+

### 部署步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd ecommerce_attribution_project
```

2. **创建表结构**
```bash
hive -f sql/ddl/create_tables.sql
```

3. **执行部署脚本**
```bash
chmod +x scripts/deploy/deploy.sh
./scripts/deploy/deploy.sh 2024-01-01
```

4. **验证部署**
```bash
hive -f sql/test/run_all_tests.sql
```

## 使用说明

### 数据源配置
- 点击日志表：包含用户点击行为数据
- 页面浏览日志表：包含用户页面浏览数据

### 参数配置
- `dt`：处理日期，格式：YYYY-MM-DD
- `hiveconf:dt`：Hive参数，用于分区过滤

### 监控配置
- 数据质量监控：监控各层数据质量指标
- 性能监控：监控ETL执行性能
- 业务监控：监控商详页访问量和转化率

## 测试说明

### 测试覆盖
- **单元测试**：6个测试用例，覆盖数据质量、业务逻辑等
- **集成测试**：6个测试用例，覆盖数据一致性、完整性等
- **边界条件测试**：8个测试用例，覆盖异常情况处理

### 测试执行
```bash
# 执行所有测试
hive -f sql/test/run_all_tests.sql

# 执行特定测试
hive -f sql/test/unit_tests.sql
hive -f sql/test/integration_tests.sql
hive -f sql/test/boundary_tests.sql
```

## 监控告警

### 监控指标
- 数据质量：空值率、重复率、完整性
- 性能指标：执行时间、资源使用率
- 业务指标：访问量、转化率、异常检测

### 告警规则
- 数据质量告警：空值率超过阈值时告警
- 性能告警：执行时间超过阈值时告警
- 业务告警：业务指标异常时告警

## 维护说明

### 日常维护
- 监控数据质量报告
- 检查ETL执行状态
- 优化查询性能
- 清理历史数据

### 故障处理
- 数据质量问题：检查源数据，重新执行ETL
- 性能问题：优化SQL，调整资源配置
- 系统故障：检查日志，重启服务

## 版本信息

- **版本**：v1.0
- **创建时间**：2024-01-01
- **维护团队**：数据开发团队
- **技术支持**：技术负责人

## 联系方式

- **项目负责人**：数据开发团队
- **技术支持**：技术负责人
- **问题反馈**：通过GitHub Issues提交

## 许可证

本项目采用MIT许可证，详情请参见LICENSE文件。

---

**最后更新**：2024-01-01  
**文档版本**：v1.0

## Cursor 规则与使用

- 规则清单见：`docs/rules/cursor_rules.md`
- 在 Cursor 中打开 Rules 面板，按文档的「标题 / Scope / 内容」逐条创建：
  - Global：启用「安全与合规」「性能回归防护」
  - Workspace（本仓库）：启用「项目特定：电商归因口径」
  - File pattern：为 `sql/**/*.sql`、`sql/etl/**`、`sql/test/**`、`**/dags/**/*.py`、`**/*.{py,scala}` 等按文档设置对应规则

设置完成后，建议在提交前执行：
```bash
hive -f sql/test/run_all_tests.sql
```
以确保口径与规则一致。

## 本地 Spark SQL 调试与测试

### 依赖安装
```bash
pip install -r requirements.txt
```

### 本地回放与断言（沙箱）
```bash
python ecommerce_attribution_project/dev/dev_spark_sql_sandbox.py --target ecommerce_attribution_project/sql/etl/dws_etl.sql --mock ecommerce_attribution_project/sql/test/mock_data_generation.sql --assert-row-count -1 --show 50
```

### 运行 PyTest
```bash
pytest -q ecommerce_attribution_project/tests/spark/test_sql_logic.py
```

### PowerShell 一键回放
```powershell
powershell -ExecutionPolicy Bypass -File ecommerce_attribution_project/scripts/dev/run_spark_sandbox.ps1 -Target ecommerce_attribution_project/sql/etl/dws_etl.sql -Mock ecommerce_attribution_project/sql/test/mock_data_generation.sql -AssertRowCount -1 -Show 50

# 当目标 SQL 为多语句且产出为视图/表时，可指定最终视图：
powershell -ExecutionPolicy Bypass -File ecommerce_attribution_project/scripts/dev/run_spark_sandbox.ps1 -Target ecommerce_attribution_project/sql/etl/run_all_etl.sql -Mock ecommerce_attribution_project/sql/test/mock_data_generation.sql -FinalView ads_result_view -Show 50

# 可选在回放前创建标准化别名视图（便于固定 FinalView 名称）
powershell -ExecutionPolicy Bypass -File ecommerce_attribution_project/scripts/dev/run_spark_sandbox.ps1 -Target ecommerce_attribution_project/sql/etl/run_all_etl.sql -Mock ecommerce_attribution_project/sql/test/mock_data_generation.sql -Prepare ecommerce_attribution_project/sql/etl/final_views.sql -FinalView ads_result_view -Show 50
```
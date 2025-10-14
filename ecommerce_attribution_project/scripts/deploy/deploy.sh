#!/bin/bash
# 电商商详页流量归因数据需求部署脚本
# 版本: v1.0
# 创建时间: 2024-01-01

set -e

# 配置参数
PROJECT_NAME="ecommerce_attribution"
HIVE_DB="ecommerce_attribution_db"
HDFS_BASE_PATH="/data/ecommerce_attribution"
LOG_DIR="/var/log/ecommerce_attribution"
DT=${1:-$(date +%Y-%m-%d)}

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# 检查环境
check_environment() {
    log_info "检查环境配置..."
    
    # 检查Hive是否可用
    if ! command -v hive &> /dev/null; then
        log_error "Hive命令不可用，请检查Hive安装"
        exit 1
    fi
    
    # 检查HDFS是否可用
    if ! hdfs dfs -ls / &> /dev/null; then
        log_error "HDFS不可用，请检查HDFS服务"
        exit 1
    fi
    
    # 检查Spark是否可用
    if ! command -v spark-submit &> /dev/null; then
        log_error "Spark命令不可用，请检查Spark安装"
        exit 1
    fi
    
    log_info "环境检查通过"
}

# 创建HDFS目录
create_hdfs_directories() {
    log_info "创建HDFS目录结构..."
    
    # 创建基础目录
    hdfs dfs -mkdir -p ${HDFS_BASE_PATH}/ods/click_log
    hdfs dfs -mkdir -p ${HDFS_BASE_PATH}/ods/page_view_log
    hdfs dfs -mkdir -p ${HDFS_BASE_PATH}/dwd/user_behavior_path
    hdfs dfs -mkdir -p ${HDFS_BASE_PATH}/dws/product_detail_attribution
    hdfs dfs -mkdir -p ${HDFS_BASE_PATH}/ads/attribution_summary
    
    # 创建日志目录
    hdfs dfs -mkdir -p ${HDFS_BASE_PATH}/logs
    
    log_info "HDFS目录创建完成"
}

# 创建表结构
create_tables() {
    log_info "创建表结构..."
    
    # 执行DDL语句
    hive -f sql/ddl/create_tables.sql
    
    if [ $? -eq 0 ]; then
        log_info "表结构创建成功"
    else
        log_error "表结构创建失败"
        exit 1
    fi
}

# 执行ETL脚本
run_etl() {
    log_info "执行ETL脚本..."
    
    # 设置Hive参数
    export HIVE_CONF_DIR=/opt/hive/conf
    export HIVE_OPTS="-Ddt=${DT}"
    
    # 执行ODS层ETL
    log_info "执行ODS层ETL..."
    hive -hiveconf dt=${DT} -f sql/etl/ods_etl.sql
    
    if [ $? -eq 0 ]; then
        log_info "ODS层ETL执行成功"
    else
        log_error "ODS层ETL执行失败"
        exit 1
    fi
    
    # 执行DWD层ETL
    log_info "执行DWD层ETL..."
    hive -hiveconf dt=${DT} -f sql/etl/dwd_etl.sql
    
    if [ $? -eq 0 ]; then
        log_info "DWD层ETL执行成功"
    else
        log_error "DWD层ETL执行失败"
        exit 1
    fi
    
    # 执行DWS层ETL
    log_info "执行DWS层ETL..."
    hive -hiveconf dt=${DT} -f sql/etl/dws_etl.sql
    
    if [ $? -eq 0 ]; then
        log_info "DWS层ETL执行成功"
    else
        log_error "DWS层ETL执行失败"
        exit 1
    fi
    
    # 执行ADS层ETL
    log_info "执行ADS层ETL..."
    hive -hiveconf dt=${DT} -f sql/etl/ads_etl.sql
    
    if [ $? -eq 0 ]; then
        log_info "ADS层ETL执行成功"
    else
        log_error "ADS层ETL执行失败"
        exit 1
    fi
}

# 数据质量检查
data_quality_check() {
    log_info "执行数据质量检查..."
    
    # 检查各层数据量
    hive -hiveconf dt=${DT} -f sql/test/script_debug.sql > ${LOG_DIR}/data_quality_${DT}.log
    
    if [ $? -eq 0 ]; then
        log_info "数据质量检查完成"
    else
        log_warn "数据质量检查发现问题，请查看日志"
    fi
}

# 设置监控
setup_monitoring() {
    log_info "设置监控配置..."
    
    # 创建监控视图
    hive -f sql/monitoring/data_quality_monitor.sql
    hive -f sql/monitoring/performance_monitor.sql
    
    # 设置告警规则
    cp config/monitoring/alerts.yml /etc/prometheus/alerts/
    
    log_info "监控配置完成"
}

# 主函数
main() {
    log_info "开始部署电商商详页流量归因数据需求..."
    log_info "处理日期: ${DT}"
    
    # 创建日志目录
    mkdir -p ${LOG_DIR}
    
    # 执行部署步骤
    check_environment
    create_hdfs_directories
    create_tables
    run_etl
    data_quality_check
    setup_monitoring
    
    log_info "部署完成！"
    log_info "处理日期: ${DT}"
    log_info "日志目录: ${LOG_DIR}"
    log_info "HDFS路径: ${HDFS_BASE_PATH}"
}

# 错误处理
trap 'log_error "部署过程中发生错误，请检查日志"; exit 1' ERR

# 执行主函数
main "$@"

from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

def_cmd = """
set -e
spark-sql -f sql/reference/fact_order_create.sql
spark-sql -f sql/reference/fact_order_load.sql
spark-submit scripts/validate_fact_order_spark.py
"""

default_args = {
    "owner": "data",
    "start_date": datetime(2025, 1, 1),
    "retries": 0,
}

with DAG(
    dag_id="fact_order_demo",
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=["demo", "dwd"],
) as dag:

    run_demo = BashOperator(
        task_id="run_demo",
        bash_command=def_cmd,
        cwd="/opt/airflow/dags/.."
    )

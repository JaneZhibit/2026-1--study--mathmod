import logging
import sys
import os
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.datastream.connectors.kafka import KafkaSource, KafkaOffsetsInitializer, KafkaSink, KafkaRecordSerializationSchema
from pyflink.datastream.formats.json import JsonRowDeserializationSchema, JsonRowSerializationSchema
from pyflink.common import Types, WatermarkStrategy, Time
from pyflink.datastream.window import TumblingProcessingTimeWindows
from pyflink.datastream.functions import ReduceFunction

# Настройка логирования
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

click_type = Types.ROW_NAMED(,
)

agg_type = Types.ROW_NAMED(,)

class CountReducer(ReduceFunction):
    def reduce(self, value1, value2):
        return (value1, value1 + value2)

def main():
    env = StreamExecutionEnvironment.get_execution_environment()
    
    # Подключаем скачанный JAR файл автоматически
    jar_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "flink-sql-connector-kafka-3.0.1-1.18.jar")
    env.add_jars(f"file://{jar_path}")

    deserialization_schema = JsonRowDeserializationSchema.builder() \
        .type_info(click_type) \
        .build()

    kafka_source = KafkaSource.builder() \
        .set_bootstrap_servers("localhost:9092") \
        .set_topics("clicks") \
        .set_group_id("flink-group") \
        .set_starting_offsets(KafkaOffsetsInitializer.latest()) \
        .set_value_only_deserializer(deserialization_schema) \
        .build()

    stream = env.from_source(kafka_source, WatermarkStrategy.no_watermarks(), "Kafka Source")

    mapped = stream.map(lambda click: (click, 1), output_type=Types.TUPLE())

    windowed = mapped.window_all(TumblingProcessingTimeWindows.of(Time.minutes(5))) \
        .reduce(CountReducer())

    serialization_schema = JsonRowSerializationSchema.builder() \
        .with_type_info(agg_type) \
        .build()

    kafka_sink = KafkaSink.builder() \
        .set_bootstrap_servers("localhost:9092") \
        .set_record_serializer(
            KafkaRecordSerializationSchema.builder()
            .set_topic("aggregated_clicks")
            .set_value_serialization_schema(serialization_schema)
            .build()
        ) \
        .build()

    windowed.sink_to(kafka_sink)
    env.execute("Click Aggregation Job")

if __name__ == "__main__":
    main()

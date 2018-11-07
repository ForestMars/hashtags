from kafka import KafkaConsumer, KafkaProducer
log = print
#topic_name = test
#key = 'foo'
#value = 'bar'

def k_message(producer_instance, topic_name, key, value):
    try:
        key_bytes = bytes(key, encoding='utf-8')
        value_bytes = bytes(value, encoding='utf-8')
        producer_instance.send(topic_name, key=key_bytes, value=value_bytes)
        producer_instance.flush()
        print('Message published successfully.')
    except Exception as e:
        log('Exception publishing message', e)

def connect_kafka_producer():
    _producer = None
    try:
        _producer = KafkaProducer(bootstrap_servers=['localhost:9092'], api_version=(0, 10))
    except Exception as e:
        log('Exception in Kafka producer', e)
    finally:
        return _producer

if __name__ == '__main__':
    kafka_producer = connect_kafka_producer()
    k_message(kafka_producer, 'test', 'foo', 'bar')
    if kafka_producer is not None:
        kafka_producer.close()

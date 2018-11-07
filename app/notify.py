from time import sleep
from kafka import KafkaConsumer

if __name__ == '__main__':

    consumer = KafkaConsumer(parsed_topic_name, auto_offset_reset='earliest',
                             bootstrap_servers=['localhost:9092'], api_version=(0, 10), consumer_timeout_ms=1000)
    for msg in consumer:
        title = record['title']

        if calories > calories_threshold:
            print('Alert: {} new document added to corpus: {}'.format(title))
        sleep(3)

    if consumer is not None:
        consumer.close()

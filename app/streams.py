import sys
import io
import os
from os import listdir
from os.path import isfile, join
from glob import glob
import pickle
from pymemcache.client import base
from kafka import KafkaClient, KafkaConsumer, SimpleConsumer

PICKLE_DIR = 'pickles/'

class Stream(object):

    def __init__(self):
        pass

    def __str__(self):
        pass

    def run(self):
        pass

class Storage(Stream):

    def __init__(self):
        Stream.__init__(self)

    def get_document_list(UPLOAD_FOLDER):
        """ Legacy method, should be removed. """
        file_dir = os.path.join(UPLOAD_FOLDER)
        filelist = [f for f in listdir(file_dir) if isfile(join(file_dir, f))]
        return(filelist)

    def get_files_from_dir(dir: str) ->list:
        #file_dir = os.path.join(UPLOAD_FOLDER)
        file_dir = os.path.join(dir)
        file_list = []
        ext   = "*.txt"

        # This won't handle sub-folders, which is needed if the uploaded zip file contains a compressed directory:
        # filelist = [f for f in listdir(file_dir) if isfile(join(file_dir, f)) and f.split('.')[-1] == 'txt']

        for dir,_,_ in os.walk(file_dir):
            file_list.extend(glob(os.path.join(dir,ext)))

        return file_list

    def read_files(self, target):
        """ read in a list of files from a storage resource """
        pass

    def read_file(self, file):
        """ read contents of a single file """
        file = open(file)
        text = file.read()
        return text

    def remove_resource(self, target):
        pass

    # This should probably be an attr on Corpus() invoking a storage handler
    def reset_corpus_files(self, UPLOAD_FOLDER):
        print("about to reset")
        print(os.path.exists)
        path = r""
        UPLOAD_FOLDER = 'app/corpus'
        print(UPLOAD_FOLDER)
        print(os.path.exists(UPLOAD_FOLDER))
        print("did it")
        file_dir = os.path.join(UPLOAD_FOLDER) #FIXME
        print(file_dir)
        # filelist should be method on our storage object
        # also, should delete everything incl dirs not just files
        filelist = [f for f in listdir(file_dir) if isfile(join(file_dir, f))]
        for f in filelist:
            os.remove(os.path.join(file_dir, f))

    def pickleme(pickle_name, data):
        """ serializes & saves anything you give it, input data is not strongly typed """
        pickle_dir = PICKLE_DIR
        pickle_file = pickle_dir + pickle_name + '.pkl'
        pickle.dump(data, open(pickle_file, "wb"))

class Redis():

    def __init__(self):
        import redis # This is such an anti-pattern!
        redis_db = redis.StrictRedis(host="localhost", port=6379, db=0)

        def set(self, key, val: object):
            redis_db.set(key, val)

        def get(self, key):
            redis_db.get(key)

        def del_key(key):
            redis_delete.set(key)

class Skrapr(Stream):

    def __init__(self):
        super(Skrapr, self).__init__()

    def scrape():
        options = Options()
        options.add_argument('--headless')
        options.add_argument('--disable-gpu')
        options.add_argument('--disable-extensions')
        options.add_argument('--no-sandbox')
        browser = webdriver.Chrome('./chromedriver', chrome_options=options)

class Kafka(Stream):

    def __init__(self):
        super(Kafka, self).__init__()

    def client(group,host,topic):
        return KafkaClient('0.0.0.0:9092')

    def kafka_consumer(id,group,host):
        #auto_offset_reset='earliest'
        return KafkaConsumer(id,group,host)

    def simple_consumer():
        consumer = SimpleConsumer(kafka, 'group', sys.argv[1])
        consumer.max_buffer_size=0
        consumer.seek(0,2) # Most recent, not stream begin
        return consumer

    def consumer_test(topic='topic'):
        consumer = self.kafka_consumer()
        consumer.subscribe(topic)
        for msg in consumer:
            print(msg)

foo = Storage
foo.pickleme('test_pickleme', 'test data')

import os
import unittest
import pickle
from app.streams import Storage

UPLOAD_FOLDER = 'corpus'

class StreamsTestCase(unittest.TestCase):
    """ class, __module__ and __file__ all set to __name__ """

class TestStorage(StreamsTestCase):

    def test_document_retrieval(self): # Y U NO match function name ?
        """ unit test that actually tests multiple storage functions as a single unit #heresy """
        self.assertTrue(Storage.get_document_list(UPLOAD_FOLDER))
        self.assertTrue(Storage.get_files_from_dir(UPLOAD_FOLDER))

    def test_get_corpus(self):
        pass

    def def_reset_corpus_files(self, UPLOAD_FOLDER):
        """ kind of an important test, since the function deletes from file system """
        reset_corpus_files(UPLOAD_FOLDER)
        self.assertTrue(os.stat(UPLOAD_FOLDER)) # confirm directory still exists
        self.assertTrue(os.listdir(UPOAD_FOLDER)=="")

        self.assertTrue(os.stat('pickles/'+'test_pickleme'+'.pkl'))

        pass

    def test_pickleme(self):
        Storage.pickleme('test_pickleme', 'test data')
        self.assertTrue(os.stat('pickles/'+'test_pickleme'+'.pkl'))

    def test_create_dir(dir):
        # self.assertTrue(os.stat(dir))
        pass

class TestKafka(StreamsTestCase):

    def test_kafka_client(self):
        #self.assertTrue(Kafka.exists())
        pass

    def test_kafka_topic(self):
        #self.assertExists(topic.exists())
        pass

if __name__ == '__main__':
    unittest.main()

#!/usr/bin/python

""" App.py: handles logic, data processing & display of information about the most common words in a corpus of text """

import os
from os import listdir
from os.path import join
import collections
from collections import OrderedDict
from operator import itemgetter
import logging
import zipfile
import nltk
from nltk.corpus import stopwords
from stop_words import get_stop_words
import re
import string
import flask
from flask import Flask, render_template, request, redirect, Response, url_for
from werkzeug.utils import secure_filename
import math
from textblob import TextBlob as tb

# Needed to support v large corpus uploads
#from flask import copy_current_request_context

from streams import Storage
from cache import Mcache

UPLOAD_FOLDER = 'corpus/' #
# UPLOAD_FOLDER_PATH = os.path.join('corpus/')
ALLOWED_FILES = set(['zip', 'txt'])
MOST_COMMON = 20 # top 10? top 100?
MIN_WORD_SIZE = 4

# Quick logging function to handle exceptions.
logging.getLogger().setLevel(logging.INFO)
def log(logmsg, e=None):
    if e:
        err = ' ('+str(e)+')'+' ERROR: ' + repr(e)
    else:
        err = ''
    logging.info(' ' + logmsg + err)

# Let's use flask to dsiplay the results, because the web is more user friendly than a console.
app = Flask(__name__)

# Load config: Overkill for a simple exercise but used for containerized CI/CD
try:
    print() #app.config.from_object('create_hashtags.configmodule.DevelopmentConfig')
except Exception as e:
    log("Error finding or loading DevelopmentConfig object. You probably need to specify package.", e)
    try:
        app.config.from_pyfile('../config.py')
        log("Loaded the configuration from file")
    except EOFError:
        log("Error reading config.py (lint file)", EOFError)
    except IOError:
        log("Error finding or loading config.py", IOError)
    except Exception as e:
        log("Ignoring unknown exception when loading config.py", e)
    except:
        handle_unhandled_error("no idea.")

@app.route('/', defaults={'path': ''})
def web(path):
    try:
        return render_template('index.html')
    except Exception as e:
        log('Could not render template', e)
        return("We'll be right back.")

# Using path:path here would decouple route to make this a React SPA instead of MV*
# (This exercise however won't be using React)
# @app.route('/<path:path>')
# def spa(path):
#    return redirect('/')

@app.route('/upload', methods=['GET', 'POST'])
def uploadfile():
    # @TODO: attr on Storage() object
    try:
        files = Storage.get_document_list(UPLOAD_FOLDER)
    except Exception as e:
        log("Could not load corpus", e)

    try:
        return render_template('upload.html', files=files)
    except Exception as e:
        log("Could not render template - ", e)

@app.route('/uploadfiles', methods=['POST'])
def uploadfiles(): #
    try:
        fileup = Upload()
        fileup.file_uploader(request)
        return redirect('upload')
    except Exception as e:
        log("File transfer borked:", e)
        return redirect('/') # @TODO: Should be error page

@app.route("/results", methods=['GET','POST'])
def results():
    table = main('corpus')

    return render_template('results.html', table=table)

    try:
        return render_template('results.html', table=table)
    except Exception as e:
            log("Could not render template - ", e)

@app.route("/demo")
def demo():
    table = main('demo')

    try:
        return render_template('results.html', table=table)
    except Exception as e:
        log("Could not render template - ", e)

@app.route("/reset")
def reset():

    try:
        file_store = Storage()
        file_store.reset_corpus_files(UPLOAD_FOLDER)
    except Exception as e:
        # this is not being caught!
        log("Could not reset Corpus", e)

    return redirect('/')

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404
    # Everyone loves a custom 404

# initialize corpus dictionary
corpus = {} # @FIXME: Not needed.

# class Stopwords():
""" Yes, 3 different lists: stopwords, stopwords_ & stop_words. :-\ """
stop_words = list(get_stop_words('en'))
nltk_stops = list(stopwords.words('english'))
stop_words.extend(nltk_stops)
# some overlap here obvi
moar_stopwords = ['a', 'al', 'able', 'about', 'across', 'after', 'all', 'almost', 'also', 'am', 'among', 'an', 'and', 'any', 'are', 'as', 'at', 'b', 'be', 'because', 'been', 'but', 'by', 'c', 'cause', 'can', 'cannot', 'could', 'd', 'day', 'dear', 'did', 'do', 'does', 'e', 'either', 'else', 'end', 'ever', 'every', 'f', 'for', 'from', 'get', 'gi', 'go', 'got', 'h', 'had', 'has', 'hat', 'have', 'he', 'her', 'hers', 'him', 'his', 'how', 'however', 'i', 'if', 'in', 'into', 'is', 'it', 'its', 'just', 'least', 'let', 'like', 'likely', 'm', 'may', 'me', 'might', 'most', 'must', 'my', 'n', 'neither', 'no', 'nor', 'not', 'o', 'of', 'off', 'often', 'on', 'only', 'or', 'other', 'our', 'own', 'rather', 'said', 'say', 'says', 'she', 'should', 'since', 'so', 'some', 't', 'take', 'than', 'then', 'that', 'the', 'their', 'them', 'then', 'there', 'these', 'they', 'this', 'tis', 'to', 'too', 'twas', 'u', 'us', 'use', 'v', 'w', 'wants', 'was', 'we', 'were', 'what', 'when', 'where', 'which', 'while', 'who', 'whom', 'why', 'will', 'with', 'would', 'x', 'y', 'yet', 'you', 'your', 'z', '-', '?']
# Today's STOP words are yesteday's GO words
optional_stopwords = ['care', 'come', 'even', 'make', 'man', 'men', 'part', 'tell', 'time', 'work']
stop_words.extend(moar_stopwords)
stop_words.extend(optional_stopwords) # Let's give the user an option to add results to ignored stop words (or remove.) We can't be sure what they are really looking for.
stopwords_ = stop_words
# @TODO: Pickl stopword automaton
for i, key in enumerate(stopwords_):
    aho.add_word(key, (i, key))
    aho.make_automaton()

def tf(word, docblob):
    return docblob.words.count(word) / len(docblob.words)

def n_containing(word, docs):
    return sum(1 for docblob in docs if word in docblob.words)

def idf(word, docs):
    return math.log(len(docs) / (1 + n_containing(word, docs)))

def tfidf(word, docblob, docs):
    return tf(word, docblob) * idf(word, docs)


# This bad boy can fit so many def's in it *slaps roof*
class Corpus(object):
    """ Class to handle cleaning & parsing documents and storing in dictionary """
    ID = 0 # initialize document id, Seemed like a good idea at the time.

    def __init__(self, dir: str):

        # list_corpus = list docs in directory
        #corpusIndex = 1 # For now we have only a single corpus, but package supports handling multiple.

        docs = Storage.get_files_from_dir(dir) # Given a directory, returns a document list.
        corpus = self.get_docs(docs) # Given a document list, returns a corpus object {dictionary}
        self.corpus = corpus # redundant

        try:
            corpusIndex = corpus # anticipated support for multiple corpuses
        except:
            log("Can't find corpus to add to index.")
            #raise

        self.save_corpus(corpusIndex)

    def getCorpus(self):
        """ Called by get results function to build result object """
        return self.corpus

    def get_corpus(self, corpusIndex):
        """ Returns a complete Corpus object when asked nicely. """
        pass


    def get_docs(self, docs: list) ->dict:  ## really should be get_corpus()
        """ Given a list of documents, returns a corpus (containing document dictionaries) """
        corpus = self.parse_dox(docs)
        return corpus

        docs = {}
        for docID in doc_list:
            doc = parse_doc(docID)
            docs[docID] = doc

        return docs

    def parse_dox(self, docs): # Y U NO type hint?
        """ [Legacy method] Given a list of documents, returns a dictionary keyed to each document
        """
        corpus.clear()
        for d, doc in enumerate(docs):
            docID = self.docID()
            file = self.file(doc) # (this is just doc)
            text = self.get_text_from_file(file)
            text_clean = self.clean_text(text)
            sentences = self.sentences(doc)
            freq_count = self.freq_count(text_clean.lower()) # sorted list of words with count
            blob = tb(text)

            corpus[docID] = {
                'file': file,
                 # 'text': text ## do we really need text attr if we also have blob attr ?
                'sentences': sentences,
                'freq_count': freq_count,
                'blob': blob
                }

        return corpus

    def parse_doc(docID) ->dict:
        """ Given a document, returns a dictionary containing the parsed document
            NOT USED IN THIS VERSION
        """
        doc = { # redundancy
            'id': docID,
            'file': docID,
            'name': docID,
            'text': ''    }
        #c_safe_text = get_doc_text(doc)['text']
        #doc['text'] = c_safe_text
        #c_safe_blob = blobify_doc(doc)
        #doc['blob'] = c_safe_blob

        return doc

    def docID(self):
        """ DocID created when corpus initialized. Adding doc to existing corpus not supported in this version. """
        self.ID += 1
        docID = self.ID
        return docID

    def file(self, doc):
        """ Currently unimplemented, takes a document and returns the file containing it. """
        return doc

    def sentences(self, doc):
        text = self.get_text_from_file(doc)
        return(self.tokenize_sentences(text))

    # touches fs so should be in Storage class
    def get_text_from_file(self, file: str) ->str:
        """ Reads file using filehandler """
        file = open(file)
        text = file.read()
        return text

    def get_doc_text(doc: dict) ->dict:
        """ Given a document (objct/dict), returns that object with an attr for the raw text """
        # from Storage resource / stream
        doc['text'] = open(doc['file']).read()

        return doc

    def clean_text(self, doc: str) -> str:
        """ Removes all punctuation, terms containing numbers, terms in brackets
            NB. doesn't clean unicode characters
        """
        #remove_stopwords()
        doc = doc.lower()
        doc = re.sub('\[.*?\]', '', doc)
        doc = re.sub('[%s]' % re.escape(string.punctuation), '', doc)
        doc = re.sub('\w*\d\w*', '', doc)
        return doc # a mostly clean text blob of words + letters a-z

    def cat_docs(corpus_list: list):
        """ Takes a list of document strings and combines them into one large corpus blob
            NB. This function is not Cython safe.
        """
        #big_blog = ' '.join(corpus_list)
        #return big_blob

    def check_encoding(self):
        """ not used in current version but needed for a mixed encodings corpus, which is common.
        (Also, there's no absolute test to confirm encoding matches what's declared in file header)
        """
        pass

    def tokenize_sentences(self, text: str) ->dict:
        sentences_list = {} # used to build iterable sentences object
        sentences = text.split('.') # Shouldn't that be '. ' ? And what about questions?

        for s, sentence in enumerate(sentences):
            if len(sentence) > 0:
                sentences_list[s] = sentence + '.' # This won't support documents with questions as well as sentences, obvi.

        return sentences_list

    def clean_collection():
        # confirm encoding
        # catch typos
        pass


    def freq_count(self, text: str) -> list:
        words = collections.Counter(text.lower().replace(',','').replace('.','').split()) # um...
        #aho = aho

        # @TODO: Stopwords should be their own function, obvi.
        for stopword in aho.iter(text):
        #for stopword in stopwords_:
            #if stopword in words: # We should use Aho-Corasick here
                words.pop(stopword)

        word_freq = sorted(words.items(), key=lambda x: x[1], reverse=True)

        return(word_freq)

    def serialize_corpus(self, corpusIndex):
        # self.getCorpus(corpusIndex)
        # pickleme(corpusIndex, )
        pass


    def save_corpus(self, corpusIndex):
        # pickle me
        pass

class Word(object):
    """ Class for scoring TF & TF-IDF across our corpus """
    def __init__(self):
        #doc_list = get_docs_by_word() # dictionary with docID as key and sentence_list as value
        self.occurances = self.topwords_by_doc()
        self.sorted = self.topwords_by_corpus(self.occurances)

    def topwords_by_doc(self):
        occurances = {} # returns dictionary of most common word occurances across corpus

        for docID in corpus:
            word_freq = corpus[docID]['freq_count']
            sentences = corpus[docID]['sentences']
            for word,freq in word_freq: #
                per_doc = {} # word occurances per document used to build occurances
                sentence_list = [] # initialize list of sentences for word:documents
                if len(word) > MIN_WORD_SIZE - 1:
                    for s, sentence in sentences.items():

                        if word.lower() in sentence.lower(): # iterative str compare, not fancy
                            sentence_list.append(s)

                if word in occurances:
                    occurances[word][docID] = sentence_list

                else:
                    occurances[word] = {docID: sentence_list}

        return(occurances)

    def topwords_by_corpus(self, occurances):
        """ quick if not overly elegant way to find most common words for entire corpus """
        wordcounts = {}
        for word in occurances:
            for docID in occurances[word]:
                ox = len(occurances[word][docID]) #
                if word in wordcounts:
                    wordcounts[word] += ox
                else:
                    wordcounts[word] = ox
        wc_sorted = sorted(wordcounts.items(), key=lambda x: x[1], reverse=True)
        return(wc_sorted)

    def save_wordcount():
        # pickle me
        pass

    def get_sorted(self):
        return self.sorted

    def get_occurances(self):
        return self.occurances

    def get_TF(word: string, corpusIndex: int) -> float:
        """ Given a word and a list of documents, returns Term Frequncy score """

        # term_frequency = doc.words.count(word) / len(tb(doc.words))
        # return term_frequency

    # def get_IDF(word, corpusIndex as ci): ## I can dream, can't I?
    def get_IDF(word, corpusIndex: int) -> float:
        """ Given a word and a list of documents, returns Inverse Document Frequency score
            Not used? >>> tfidf invoked from global namespace.
        """
        #for docs in corpusIndex:
        #    c_idl = in_docs_len(word, docs)
        #    return math.log(len(docs) / (1 + c_idl))

        # return inv_term_frequency

    def TFIDF(word, doc, docs):
        """ Returns TF-IDF score """
        # return tf(word, tb(doc)) * idf(word, docs)
        pass

    def part_of_speech():
        """ Given a word token, makes 2 best guesses what part of speech it is, based on grammatical and semantic context """
        pass

    def ngrammify(n: int):
        pass

class Upload(object):

    def __init__(self):
        pass

    def file_uploader(self, request):

        if request.method == 'POST':
            file = request.files['file']
            if self.file_check(file) == 'application/zip':
                self.extract_zip(file)
            elif self.file_check(file):
                filename = secure_filename(file.filename)
                print(type(os))
                print(os.path)
                print(os.path)
                file.save(os.path.join(UPLOAD_FOLDER,filename))
                print("okl")
            else:
                raise Exception("Sorry, files could not be uploaded.")
        else:
            return request.args.get['file']

    def file_check(self, file):
        supported_filetypes = ('text/plain', 'application/zip')
        unsupported_filetypes = ('text/rtf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') #Incomplete list, OBVI
        mimetype = file.content_type
        try:
            if mimetype in supported_filetypes:
                return mimetype
            else:
                raise ValueError('Tried to upload Unsupported file type: %s' % (mimetype))

        except Exception as e:
            log("Error during upload file check", e)
            # TODO: Let user know what happened

    def extract_zip(self, file):
        zippy = zipfile.ZipFile(file, 'r')
        zippy.extractall(UPLOAD_FOLDER)
        zippy.close()

class AppError(object):
    """ Class for handling any unhandled exceptions """
    def unhandled():
        log("unhandled error was handled")
        pass

#  There are many excellent reasons for not instantiating class from main()
def get_corpus(documents: str ) ->object:
    """ currently takes str representing directory name """
    return Corpus(documents)

def get_sentences(corpus: object, wordup: object) ->dict:
    """ somewhat misnamed function that gets all results needed for display
        >>> function where the most time is spent <<<
    """
    counted_words = wordup.get_sorted()
    occurances = wordup.get_occurances()
    data = corpus.getCorpus()
    results = {}

    #bloblist = for bloblist in
    bloblist = []
    for k, v in data.items():
        bloblist.append(v['blob'])

    for word, c in counted_words:
        in_docs = []
        in_sentences = []

        for docID, ox in occurances[word].items():
            doc_file = os.path.basename(data[docID]['file'])

            #doc_tf = tf(word, data[docID]['blob'])
            doc_tfidf = tfidf(word, data[docID]['blob'], bloblist)

            in_docs.append({doc_file: round(doc_tfidf, 7)})
            for k,v in enumerate(ox):
                ss = data[docID]['sentences'][v].strip('"') # @FIXME: should already be cleaned
                in_sentences.append(ss)

        #results[word] = {'docs': in_docs, 'sctw': in_sentences}
        results[word] = {
            'docs': in_docs,
            'sctw': in_sentences
            }
        #results['word']['docs'] = in_docs # dict with docID:term_freq
        #results['word']['sctw'] = in_sentences

    return results

def get_results(corpus, wordup):
    """ Given a result set, builds table to pass to display handler """
    table = {}
    results = get_sentences(corpus, wordup) # hmm

    for word in results:
        docs = results[word]['docs']
        sctw = results[word]['sctw']
        foo='bar'
        table[word] = dict(docs=docs, sctw=sctw, foo=foo)

    d = collections.OrderedDict(((table)))
    return {k:d[k] for k in list(d.keys())[:MOST_COMMON]} # return comprehension

def main(documents: str):
    """ Given a string reprsenting a directory name, returns a corpus for all docs in the directory """
    corpus = get_corpus(documents)
    wordup = Word()

    return(get_results(corpus, wordup))

if __name__ == '__main__':
    main('demo/')
    handle_unhandled_error = AppError.unhandled()
    app.run(host='0.0.0.0', port=6174, debug=True)

# print(__NAME__) # heh.

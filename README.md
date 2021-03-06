

# Quick topic modeling exercise ![CI status](https://img.shields.io/badge/build-passing-brightgreen.svg)
A quick demo in Python 3 to find and display word occurrences in a corpus of documents.

## Author
Forest Mars

### Supported Architectures / OS
Tested on x86_64 Linux & OS X. (Untested on Microsoft Windows.)

### Requirements
* Unix/Linux/OSX
* Requires Python >= 3.6 (Uses ordered dictionaries; also using type hinting, introduced in 3.5.)
* NLTK stopwords: ```$ nltk.download('stopwords')```

While it’s possible to take advantage of ordered dictionaries (Python 3.6) in a way that’s compatible all the way back to 2.7, this package requires Python 3.6.

### Installation
```python
$ tar -xzf mars_eigentech.tgz
$ cd create_hashtags
$ pip3 install -r requirements.txt
```
## Usage
```python
$ cd app
$ python3 create_hashtags.app
$ open http://localhost:6174
```
The webapp (flask) offers a choice between viewing a demo shipped with the test documents, or uploading your own corpus of documents. You may upload text documents singly, or a zip archive containing multiple (ASCII) text files.

## Documentation
Code documentation of classes & functions including API documentation can be found in the /docs directory. This was automatically generated with epydoc using docstrings. The goal here was not to exhaustively document every definition and value in the code, but rather to provide examples of correct documentation (For example, function comments should describe the intent of a function, not the implementation.)  Open ```/docs/toc.html``` to get started.  

## Open Issues
   * Makes no attempt to de-duplicate identical documents in a corpus (eg. nested at different levels, or misnamed.)
   * Expand/collapse sentence list returns to top of page. :-\
   * Needs lemmatization (cf. America/American, Kenya/Kenyan) so it's a proper word count, not merely n-grams.
   * An intelligent NLP should be able to count apple and Apple as separate words. This version doesn't do that.

## Approach
After getting a sense of the requirements (which are somewhat ambivalent/open-ended) I went back and forth whether to use an existing library for calculating term frequency with minimal loc, or going for it and writing my own implementations for calculating all the scores.

Is it more interesting as an exercise to write an implementation yourself, or invoke higher level library? A question reflecting a similar consideration when building live products– when to leverage existing libraries when to take a more custom approach.

A deciding factor here was the desire to insure the app will run on a reviewer's machine with a minimum of manual configuration. So that ruled out textblob, for example which requires an additional install step. And while I assume the target machine would have scikit-learn, I tried to follow the principle of reducing external dependencies, and just writing code using built-ins functions and modules as much as possible.

Other considerations included whether to use a dictionary or a data frame; both have similar lookup performance in near constant time. I decided I wanted to start with a dictionary, which is better suited for nested structures (to implement the business logic) then use pandas to convert final results to a data frame to handle any display logic that doesn't belong in a view. Again looking to follow the principle of managing external dependencies.

## Flair
While I didn't want to overload this demo with an excess of flair, if I had had a little more time this weekend I wanted to add a few more bonus bells & whistles, such as pickling the corpus for storage/retrieval (instead of storing bare files on the filesystem), additional display of a per document tf-idf score for each word, a sentiment (polarity) score for each sentence, and a plot of the sentiment scores for each sentence “over time” (since the test documents are speeches Obama gave in real time.)

I would have really liked to include a comparison of most common words from Barack Obama’s recent tweets for comparison since some of the most common words in the test corpus are somewhat dated (iraq, kenya, john mccain). However I definitely did not want to inflict the complications of chromedriver on DX. (Although you really just need to copy the appropriate driver for your architecture up into the app directory and rename it “chromedriver”.)

Finally, counting top words is really about stop words, IMO. To make the tool really useful, the user should be able to adjust word size (I wanted to set the minimum word size to 5 letters, but "Iraq" is actually 1 of the top 3 words in this corpus. And ideally, the user would have an easy way to remove a top-ranked word by adding it to a custom stop list. So it's not outputting the canonical top words according to a perfect algorithm, but can be used more as a tool for the exploration and understanding of texts.

If you've read this far, thanks! This was a fun exercise and I look forward to discussing more in person, should you have interest.

## Feedback
Any comments of questions should be sent to ```themarsgroup@gmail.com```


## License
See ```LICENSE.md```

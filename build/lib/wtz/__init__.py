from flask import Flask

__NAME__ = 'hashtags'

__ALL__ = [
    'Storage',
    'Skrapr',
    'Kafka',
    'Pickle',
    'Kinesis'
    ]

FLASK_DEBUG = 1
TEMPLATES_AUTO_RELOAD = True

#appz = Flask(__NAME__)

print(__NAME__) # hashtags
print(__name__) # app
print(appz)  # <Flask 'hashtags'>

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

app = Flask(__NAME__)

print(__NAME__) # hashtags
print(__name__) # hashtags app
print(app)  # <Flask 'hashtags'>

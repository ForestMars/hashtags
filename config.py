import os

basedir = os.path.abspath(os.path.dirname(__file__))

class Config:

    @staticmethod
    def init_app(app):
        pass

    #MAX_CONTENT_LENGTH = 16 * 1024 * 1024 # 16MB
    #UPLOADED_FILES_DEST = "corpus/" #
    #UPLOADS_DEFAULT_DEST = "corpus" #
    UPLOAD_FOLDER = "corpus/"
    TEMPLATES_AUTO_RELOAD = True

class DevelopmentConfig(Config):
    DEBUG = True
    TEMPLATES_AUTO_RELOAD = True

class TestingConfig(Config):
    TESTING = True

extra_dirs = [
    'templates',
    'corpus',
    'demo'
]

config = {
    'development' : DevelopmentConfig
}

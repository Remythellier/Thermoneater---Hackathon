
from flask import Flask, request
from flask_restful import Resource, Api, reqparse
import time
import datetime

import data_manager

DATA = {}

app = Flask(__name__)
api = Api(app)

class getData(Resource):
    def get(self):
        data = data_manager.get_data()
        data_manager.empty_data()
        return {'data': data}

class getStatus(Resource):
    def get(self):
        return {'status': "live"}

class collectData(Resource):
    def post(self):
        data_id = datetime.datetime.now()
        DATA[data_id] = request.data
        return DATA[data_id], 201

api.add_resource(getData, '/data/')
api.add_resource(collectData, '/collect/')
api.add_resource(getStatus, '/')

def run():
    app.run(host="0.0.0.0", debug=False)

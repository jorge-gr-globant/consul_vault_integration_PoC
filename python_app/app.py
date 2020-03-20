import consul
import requests
from flask import Flask, jsonify, request
from redisWrapper import RedisWrapper
from dotenv import load_dotenv
import os
import logging
app = Flask(__name__)


class ServiceDiscoverer():
    def __init__(self, index=None, consistency='default'):
        load_dotenv()
        self.index = index
        self.consistency = consistency
        self.consul_conn = consul.Consul(host='consul_server', port='8500',
                                         scheme='http', token=os.getenv('KV_TOKEN'))

    def get(self, service_name):
        service = self.consul_conn.catalog.service(service_name,
                                                   index=self.index,
                                                   consistency='default')[1][0]
        return service["ServiceAddress"], service["ServicePort"]


class ConfigReader():
    def __init__(self, index=None, consistency='default'):
        load_dotenv()
        self.index = index
        self.consistency = consistency
        self.consul_conn = consul.Consul(host='consul_server', port='8500',
                                         scheme='http', token=os.getenv('KV_TOKEN'))

    def get(self, config_key):
        config = self.consul_conn.kv.get(config_key, index=self.index)
        return config[1]['Value'].decode('utf-8')


@app.errorhandler(404)
def service_not_found(e):
    return jsonify(error="404 Page not found")


def error(e):
    return {"error": str(e)}


@app.route('/api/<service_name>')
def service_proxy(service_name):
    config_manager = ServiceDiscoverer()
    try:
        ip, port = config_manager.get(service_name)
        r = requests.get('http://{0}:{1}'.format(ip, port))
    except IndexError:
        return error("Service {0} not found".format(service_name))
    return r.json()


@app.route('/dns/<service_name>')
def dns_proxy(service_name):
    try:
        port = 9001
        r = requests.get('http://{0}:{1}'.format(service_name, port))
    except Exception:
        return error("Service {0} not found".format(service_name))
    return r.json()


@app.route('/config/<key>')
def external_config(key):
    val = None
    try:
        backend = request.args.get('backend')
        if (backend == 'consul'):
            reader = ConfigReader()
            val = reader.get("python/" + key)
        elif (backend == 'redis'):
            val = RedisWrapper('custom_redis').get(key)
    except TypeError:
        val = error("Key {0} doesn't exist".format(key))
    return val


if __name__ == '__main__':
    app.run("0.0.0.0")

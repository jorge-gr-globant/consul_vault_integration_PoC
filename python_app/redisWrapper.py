import redis
import json

class RedisWrapper:
    def __init__(self, host, port=6379):
        self.redis_con = redis.Redis(host=host, port=port, db=0)
    

    def get(self, key):
        value = self.redis_con.execute_command('JSON.GET', key)
        if value:
            val = json.loads(value.decode('utf-8'))
        else:
            val = {}
        return val


if __name__ == '__main__':
    rw = RedisWrapper('localhost')
    val = rw.get('object')
    print(val)
        

import consul

class ServiceDiscoverer():
    def __init__(self, index=None, consistency='default'):
        self.index = index
        self.consistency = consistency
        self.consul_conn = consul.Consul(token='c15a6e82-e7b1-1f4d-dd89-bdbb9c16ee70')

    def get(self, service_name):
        service = self.consul_conn.catalog.service(service_name,
                                                   index=self.index,
                                                   consistency='default')[1][0]
        return service["ServiceAddress"], service["ServicePort"]

if __name__ == '__main__':
    sd = ServiceDiscoverer()
    ip, port = sd.get("counting")
    print(ip, port)

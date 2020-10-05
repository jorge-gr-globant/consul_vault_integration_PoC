import consul


class ConsulClient:
    """
    Generate connection to Consul
    """
    def __init__(self, host, port, scheme):
        self._host = host
        self._port = port
        self._scheme = scheme
        self._connection = consul.Consul(host=self._host,
                                         port=self._port,
                                         scheme=self._scheme)
        self.kv = self.KvStore(self)
        self.services = self.Services(self)

    @property
    def connection(self):
        """
         Return ongoing Consul connection.
        """
        return self._connection

    class KvStore:
        """
        KV endpoint exposes simple key/value store.
        Simply stores service configurations, or other metadata.
        """
        def __init__(self, consul_client):
            self._consul = consul_client

        def get(self, key):
            """
            Return specified key data.

            :param key: string
            :return object
            """
            return self._consul.connection.kv.get(key)[1]['Value'].decode('utf-8')

        def set(self, key, data):
            """
            Set specified key data.
            Return operation's boolean status.

            :param key: string
            :param data: string
            :return boolean
            """
            return self._consul.connection.kv.put(key=key, value=data)

        def delete(self, key, recurse=None):
            """
            Deletes single key, or all keys sharing prefix (if recurse is True).
            Return operation's boolean status.

            :param key: string
            :param recurse: boolean
            :return boolean
            """
            return self._consul.connection.kv.delete(key=key, recurse=recurse)

    class Services:
        """
        Services endpoint registers/deregisters new Consul services.
        """
        def __init__(self, consul_client):
            self._consul = consul_client

        def get(self, service_name):
            """
            Return specified service name data.

            :param service_name: string
            :return object
            """
            try:
                return self._consul.connection.catalog.service(service_name)[1][0]
            except IndexError as index_error:
                raise ServiceNotFound(service_name) from index_error

        def list(self):
            """
            Return registered Consul services list.

            :return object
            """
            return self._consul.connection.agent.services()

        def set(self, service_name, address, port, tags=None):
            """
            Set specified service name with proper configuration address, port or tags.
            Return operation's boolean status.

            :param service_name: string
            :param address: string
            :param port: int
            :param tags: array
            :return boolean
            """
            return self._consul.connection.agent.service.register(service_name,
                                                                  service_id=service_name,
                                                                  address=address,
                                                                  port=int(port),
                                                                  tags=tags)

        def delete(self, service_name):
            """
            Delete specified service name.
            Return operation's boolean status.

            :param service_name: string
            :return boolean
            """
            return self._consul.connection.agent.service.deregister(service_id=service_name)


class ServiceNotFound(Exception):
    """
    Exception raised for not finding the specified service.

    :param service_name: string
    :return object
    """
    def __init__(self, service_name):
        self.service_name = service_name
        super().__init__(service_name)

    def __str__(self):
        return f'Service "{self.service_name}" not found'

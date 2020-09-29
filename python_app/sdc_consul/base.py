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
        Returns the on going consul connection.
        """
        return self._connection

    class KvStore:
        """
        The KV endpoint is used to expose a simple key/value store.
        This can be used to store service configurations or other meta data in a simple way.
        """
        def __init__(self, consul_client):
            self._consul = consul_client

        def get(self, key):
            """
            Returns the data for the specified key.

            :param key: string
            :return object
            """
            return self._consul.connection.kv.get(key)[1]['Value'].decode('utf-8')

        def set(self, key, data):
            """
            Sets the data for the specified key.
            Returns a boolean status of the operation.

            :param key: string
            :param data: string
            :return boolean
            """
            return self._consul.connection.kv.put(key=key, value=data)

        def delete(self, key, recurse=None):
            """
            Deletes a single key or if recurse is True, all keys sharing a prefix.
            Returns a boolean status of the operation.

            :param key: string
            :param recurse: boolean
            :return boolean
            """
            return self._consul.connection.kv.delete(key=key, recurse=recurse)

    class Services:
        """
        The Services endpoint is used to register/deregister new services on consul.
        """
        def __init__(self, consul_client):
            self._consul = consul_client

        def get(self, service_name):
            """
            Returns the data for the specified service name.

            :param service_name: string
            :return object
            """
            try:
                return self._consul.connection.catalog.service(service_name)[1][0]
            except IndexError as index_error:
                raise ServiceNotFound(service_name) from index_error

        def list(self):
            """
            Returns a list of all services registered on Consul.

            :return object
            """
            return self._consul.connection.agent.services()

        def set(self, service_name, address, port, tags=None):
            """
            Sets the specified service name with its proper configuration address, port or tags.
            Returns a boolean status of the operation.

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
            Deletes the specified service name.
            Returns a boolean status of the operation.

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

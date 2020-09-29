## API Documentation

class ConsulClient (host='127.0.0.1', port=8500, scheme='http')
```
Generate connection to Consul
host   -> Consul address
port   -> Consul port
scheme -> Protocol to establish connection can be http or https 
```
   
- classmethod ConsulClient.**connection()**
    ```
    Returns the on going consul connection.
    ```


class ConsulClient.**kv**
```
The KV endpoint is used to expose a simple key/value store.
This can be used to store service configurations or other meta data in a simple way.
```

- classmethod **get**(key='')
    ```
    Returns the data for the specified key.
    ```

- classmethod **set**(key='', data='')
    ```
    Sets the data for the specified key.
    Returns a boolean status of the operation.
    ```
    
- classmethod **delete**(key='')
    ```
    Deletes a single key or if recurse is True, all keys sharing a prefix.
    Returns a boolean status of the operation.
    ```
    
class ConsulClient.**services**
```
The Services endpoint is used to register/deregister new services on consul.
```
- classmethod **get**(service_name='')
    ```
    Returns the data for the specified service name.
    ```
- classmethod **set**(service_name='', address='', port='', tags=None)
    ```
    Sets the specified service name with its proper configuration address, port or tags.
    Returns a boolean status of the operation.
    ```
- classmethod **list**()
    ```
    Returns a list of all services registered on Consul.
    
    ```
- classmethod **delete**(service_name='')
    ```
    Deletes the specified service name.
    Returns a boolean status of the operation.
    ```
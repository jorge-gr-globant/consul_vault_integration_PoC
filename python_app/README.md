## API Documentation

class ConsulClient (host='127.0.0.1', port=8500, scheme='http')
```
Generate Consul connection 
host   -> Consul address
port   -> Consul port
scheme -> Connection protocol can be http or https 
```
   
- classmethod ConsulClient.**connection()**
    ```
    Return ongoing Consul connection.
    ```


class ConsulClient.**kv**
```
KV endpoint exposes simple key/value store.
Simply stores service configurations, or other metadata.
```

- classmethod **get**(key='')
    ```
    Return specified key data.
    ```

- classmethod **set**(key='', data='')
    ```
    Set specified key data.
    Return operation's boolean status.
    ```
    
- classmethod **delete**(key='')
    ```
    Deletes single key, or all keys sharing prefix (if recurse is True).
    Return operation's boolean status.
    ```
    
class ConsulClient.**services**
```
Services endpoint registers/deregisters new Consul services.
```
- classmethod **get**(service_name='')
    ```
    Return specified service name data.
    ```
- classmethod **set**(service_name='', address='', port='', tags=None)
    ```
    Set specified service name with proper configuration address, port or tags.
    Return operation's boolean status.
    ```
- classmethod **list**()
    ```
    Return registered Consul services list.
    
    ```
- classmethod **delete**(service_name='')
    ```
    Delete specified service name.
    Return operation's boolean status.
    ```

# Smile Direct Club Consul, Vault & Jenkins Services PoC

# What is this?
This is a PoC of consul service discovery, Configuration management and Secrets Management integration with python and Jenkins.
This is meant to showcase the base functionality with consul ACL's enabled and Vault.


## Usage
Run `./up.sh`
## Endpoints
- Service Discovery
    - http://localhost:5000/api/<service> (i.e. /api/counting)
    - http://localhost:5000/dns/<DNS FQN> (i.e. /api/counting.service.consul)
- External Configuration
    - http://localhost:5000/config/<key>?backend<redis|consul> (i.e. /config/python_conf?backend=redis)
    - http://localhost:5000/config/<key>?backend<redis|consul> (i.e. /config/dotnet?backend=consul)
- Secrets Management (Jenkins Vault Plugin)
    - http://localhost:8500
## Requirements
- Docker (Tested with 19.03.6)
- Docker Compose (Tested with 1.21.2)

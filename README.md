# Smile Direct Club Services PoC

## What is this?
This is a PoC of consul service discovery and Configuration management with python.
This is meant to showcase the base functionality without consul ACL's enabled.

## Usage
Run `./up.sh`
## Endpoints
- Service Discovery
    - http://localhost:5000/api/<service> (i.e. /api/counting)
    - http://localhost:5000/dns/<DNS FQN> (i.e. /api/counting.service.consul)
- External Configuration
    - http://localhost:5000/config/<key>?backend<redis|consul> (i.e. /config/python_conf?backend=redis)
    - http://localhost:5000/config/<key>?backend<redis|consul> (i.e. /config/dotnet?backend=consul)

## Requirements
- Docker (Tested with 19.03.6)
- Docker Compose (Tested with 1.21.2)

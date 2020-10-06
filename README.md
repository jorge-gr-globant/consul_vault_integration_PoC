# Smile Direct Club Services PoC

## What is this?
This is a PoC of consul service discovery and Configuration management with python.
This is meant to showcase the base functionality without consul ACL's enabled.

## Usage
Run `./up.sh`

## Linter
Run `pylint --rcfile=python_app/.pylintrc python_app/*.py`

## Test cases
Run `python -m unittest discover -s python_app/`

## Requirements
- Docker (Tested with 19.03.6)
- Docker Compose (Tested with 1.21.2)

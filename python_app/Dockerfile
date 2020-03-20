FROM python:3.5
RUN pip install flask; pip install python-consul; pip install docker; pip install redis
ADD ./ /src
WORKDIR /src
EXPOSE 5000
ENTRYPOINT python app.py

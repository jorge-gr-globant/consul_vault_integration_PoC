FROM python:3.5
RUN pip install flask; pip install python-consul; pip install docker; pip install redis; pip install python-dotenv
WORKDIR /src
EXPOSE 5000
ENTRYPOINT python app.py

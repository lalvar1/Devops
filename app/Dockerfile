FROM python:3.7-alpine

RUN mkdir /app
WORKDIR /app
ADD . /app/
RUN pip install flask

EXPOSE 5000
CMD ["python", "/app/app.py"]
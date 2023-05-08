# pull official base image
FROM python:3.10.7-slim-buster

# set work directory
WORKDIR /usr/src/app

# set environment variables
ARG DEBIAN_FRONTEND=noninteractive


# install system dependencies
RUN apt-get update && apt-get install -y 

# install dependencies
RUN pip install --upgrade pip
RUN pip install gunicorn
COPY ./requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

# copy project
COPY . /usr/src/app/

CMD ["gunicorn", "-b", "0.0.0.0:3000", "wsgi"]
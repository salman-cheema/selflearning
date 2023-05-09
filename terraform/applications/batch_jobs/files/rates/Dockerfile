FROM ubuntu:focal 
WORKDIR /rates

# Install the prerequisites
RUN apt-get update && apt-get install -y \
    python3-psycopg2 \
    python3-pip

RUN python3 -m pip install --upgrade pip

RUN pip3 install -y \
    psycopg2 \
    boto3 \
    pandas \
    sqlalchemy

COPY . /rates

CMD ["python3", "rates/rates_insertion.py"]
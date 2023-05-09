FROM ubuntu:focal 
WORKDIR /rates

# Install the prerequisites
RUN apt-get update && apt-get install -y \
    python3-psycopg2

RUN python3 -m pip install --upgrade pip3

RUN pip3 install -y \
    psycopg2 \
    boto3 \
    pandas

COPY . /rates

CMD ["python3", "rates/rates_insertion.py"]
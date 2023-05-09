FROM ubuntu:focal 
WORKDIR /rates

# Install the prerequisites
RUN apt-get update && apt-get install -y \
    python3-psycopg2 \
    psycopg2 \
    boto3 \
    pandas 

COPY . /rates

CMD ["python3", "rates/rates_insertion.py"]
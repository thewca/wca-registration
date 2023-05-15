FROM locustio/locust
COPY requirements.txt /app/requirements.txt
COPY wca_id_list.csv /app/wca_id_list.csv
RUN pip install --no-cache-dir -r /app/requirements.txt
WORKDIR /app

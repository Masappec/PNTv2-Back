FROM python:3.12.0

WORKDIR /app
RUN pip install --upgrade pip



COPY . .


RUN pip install --upgrade pip

RUN pip install -r requirements.txt

RUN chmod +x entrypoint.sh


ENTRYPOINT [ "bash", "entrypoint.sh" ]
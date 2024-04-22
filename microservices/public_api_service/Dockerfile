ARG PYTHON_VERSION=3.12

# Utiliza la imagen base de Python
FROM python:${PYTHON_VERSION} as base

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Instala las dependencias de psycopg2 y otras herramientas
RUN apt-get update && apt-get install -y \
    && rm -rf /var/lib/apt/lists/* \
# Crea un directorio para tu aplicación
WORKDIR /code

# Copia los archivos de configuración de Nginx y certificados SSL a la imagen

# Descargar wait-for-it.sh
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /code/wait-for-it.sh

# Dar permisos de ejecución
RUN chmod +x /code/wait-for-it.sh

# Copia los archivos de requerimientos de Python
COPY requirements.txt /tmp/requirements.txt

COPY entrypoint.sh /code/entrypoint.sh

# Instala Gunicorn
RUN pip install gunicorn

# Actualiza pip e instala las dependencias de Python
RUN set -ex && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    rm -rf /root/.cache/

# Copia tu aplicación
COPY . /code

# Expone el puerto 8000
EXPOSE 8000

# Configura el punto de entrada para tu aplicación
ENTRYPOINT [ "sh", "/code/entrypoint.sh" ]

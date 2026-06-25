# Dockerfile (multi-stage, imagen ligera, usuario no root)

FROM python:3.12-slim AS builder 
#Instalamos las dependencias necesarias para construir la aplicación, como pip y build-essential

WORKDIR /app
#
COPY requirements.txt .
#Instalamos las dependencias de la aplicación en un directorio temporal (/install) para luego copiar solo lo necesario a la imagen final
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
#Partimos desde una imagen mas limpia
WORKDIR /app

RUN useradd -m -u 1000 appuser
#User no root
COPY --from=builder /install /usr/local
COPY app ./app

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8004

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8004"]

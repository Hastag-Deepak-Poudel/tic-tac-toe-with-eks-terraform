SETUP IN FRONTEND:

VITE_DJANGO_BASE_URL=/  ( .env )

Frontend runs on localhost:5173 ---> Nginx -----> localhost:80 ------> www.example.com/api/products

( use / so that when frontend makes api call to backend it goes as '/'api/products. or use custom domain like
www.example.com so it becomes www.example.com/api/products from frontend.)

const BASEURL = import.meta.env.VITE_DJANGO_BASE_URL || '/'; ( example )


-------DOCKERFILE------

FROM node:20-alpine AS build-stage

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=build-stage /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

------END DOCKERFILE-------

-----NGINX.CONF-------

server {

    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;
    location / {

        try_files $uri $uri/ /index.html;
    }
}

-----END NGINX.CONF------


build the docker file and push it to the dockerhub


SETUP IN BACKEND


create venv and run pip install -r requirements.txt


-----SETTING.py-----

import os
from dotenv import load_dotenv
from datetime import timedelta


# ONLY load the .env file if we are NOT running in Kubernetes
# (Kubernetes always injects variables natively into the OS environment)
if not os.environ.get('KUBERNETES_SERVICE_HOST'):
    load_dotenv(BASE_DIR / '.env')

SECRET_KEY = os.getenv('SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.getenv('DEBUG') == 'True'

ALLOWED_HOSTS = ['localhost','127.0.0.1','*'] 
# localhost and 127.0.0.1 for local development and * for kubernetes



we donot need to add corsheader in installed_apps [ ] because kubernetes uses its cluster as a mean of communication between frontend and backend. CORSHEADER IS NOT NEEDED.



DATABASE SETUP FOR POSTGRES

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('POSTGRES_DB'),
        'USER': os.environ.get('POSTGRES_USER'),
        'PASSWORD': os.environ.get('POSTGRES_PASSWORD'),
        'HOST': os.environ.get('POSTGRES_HOST'),
        "PORT": "5432",
    }
}



ADD THIS IN in 
MIDDLEWARE['whitenoise.middleware.WhiteNoiseMiddleware',]


______IN THIS LAST OF SETTING.PY_______

STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles') 
-------here we define where staticfiles are loaded

STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"

WHITENOISE_USE_FINDERS = True
		---- whitenoise is used for loading static files like css and js for admin and rest_framework-----


_____TO RUN LOCALLY______
create .env and add this:

POSTGRES_DB=ecommerce_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=yourpassword
POSTGRES_HOST=localhost
SECRET_KEY=django-insecure-w+hy1s*#&)2#hp_mvp=eb%r)4g%jv93e&k4k0h3n0u$(*n-_eb
DEBUG=TRUE

__________________________________




---------DOCKERFILE---------

FROM python:3.12-slim

WORKDIR /app

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Set up the startup script
COPY entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Default command to run via WSGI server
CMD ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000"]


---------END DOCKERFILE---------


-------entrypoint.sh--------

#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Gather all static assets into STATIC_ROOT without prompt
python manage.py collectstatic --noinput

# Run database migrations (optional but recommended here)
python manage.py migrate

# Execute the container's main command (e.g., Gunicorn or Uvicorn)
exec "$@"


-------END entrypoint.sh---------


build the docker file and push it to the dockerhub



KUBERNETES SETUP


DELETE ALL CLUSTER so that there is no conflict between clusters
START FRESH 

1. kind create cluster --config config.yaml

2. kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

this is a ingress controller that is installed in out cluster


3. kubectl logs -n ingress-nginx deploy/ingress-nginx-controller -f
check if the ingress-nginx is working and run http://localhost/ in different terminal


4. kubectl get ingress 

5. kubectl get pods -n ingress-nginx
check if ingress-nginx pod is working

6. Then run 

kubectl apply -f 
	pv.yaml
	pv-claim.yaml
	postgres-secret.yaml
	postgres.service.yaml
	postgres.deployment
	
	django-secrets.yaml
	configMap.yaml
	backend-deployment.yaml	( contains service also in the file )
	
	frontend-deployment.yaml ( contains service also in the file)

	ingress.yaml






when setting up the communication between frontend and backend,

we donot need .env file for frontend and in the code, we use direct link like,

examples:

	fetch('/api/products')	
	fetch('/api/carts')
	fetch('/login')
	fetch('register')  



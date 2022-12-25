#define name of the imae to be used (hub.docker.com)
FROM python:3.9-alpine3.13

#who maintains
LABEL maintainer="ISA"

# do not buffer output, display as is
ENV PYTHONUNBUFFERED 1

#copy requirements into docker image
COPY ./requirements.txt /tmp/requirements.txt

#!!!!!!!!!!!!!!!!!!!!for DEV!!!! only, wewill add the dev requirements
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

#copy the app itself and sert root folder
COPY ./app /app
WORKDIR /app

#port
EXPOSE 8000


#by default we say that this is NOT a dev server
#this ARG gets overridden when we have DEV arg in docker-compose file
ARG DEV=false

# generare venv
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip

#add dependencies for postgresql
RUN apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps build-base postgresql-dev musl-dev

# install requirements
RUN /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV="true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi

RUN rm -rf /tmp

#remove dependencies for postgresql
RUN apk del .tmp-build-deps

RUN adduser \
        --disabled-password \
        --no-create-home \
        django-user
#update env variable PATH, we limit it to the /app and make it automatically look into /app
ENV PATH="/py/bin:$PATH"

#switching into this user now,  ( all until this user - is root)
#containers runnign now will use django-user by default
USER django-user




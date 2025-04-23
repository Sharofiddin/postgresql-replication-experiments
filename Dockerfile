FROM postgres:16

RUN apt-get update
RUN apt-get install iputils-ping -y


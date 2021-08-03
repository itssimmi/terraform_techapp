#!/bin/bash -xe
sudo apt update  -y
sudo apt install docker -y
sudo apt install docker.io -y
sudo apt install docker-compose -y 
sudo docker network create techAppNetwork
sudo docker run -d -it --name postgres -h postgres --net techAppNetwork -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres postgres:9.6
sleep 20
sudo docker run -d -it --name tech_backend -h tech_backend --net techAppNetwork -v /home/ubuntu/conf.toml:/TechChallengeApp/conf.toml servian/techchallengeapp:latest updatedb
sudo docker run -it -d --name tech_frontend -h tech_frontend --net techAppNetwork -v /home/ubuntu/conf.toml:/TechChallengeApp/conf.toml -p 3000:3000 servian/techchallengeapp:latest serve
# Budget

A Flutter project for tracking budget including wise integration to sync transactions/spend and more.

Budget dark             |  Budget Light
:-------------------------:|:-------------------------:
![](README/screenshot_dark.png?raw=true "Dark Theme")  |  ![](README/screenshot_light.png?raw=true "Light Theme")

## Getting Started

### Requirement

- Docker & Docker Desktop (For Windows)
- [Hasura](https://hasura.io/docs/latest/graphql/core/hasura-cli/install-hasura-cli) 
- [Flutter](https://docs.flutter.dev/get-started/install)


## DB Structured

[Board UML](https://miro.com/app/board/uXjVOlCWOFU=/?share_link_id=604302253564)

### First Steps

First at all install dependencies and requirements of the project. After that if you are on windows open Docker Desktop.

1. To start up DB:
   - run: `docker-compose up -d`
   - this will emulate hasura locally in your machine. Then you can open the console of hasura with the command: 
   - `cd hasura && hasura console` this command will create a console UI on `http://localhost:9695/`.

2. 

### Steps for clear docker image

1. Stop the container(s) using the following command:
   
   `docker-compose down`

2. Delete all containers using the following command:
   
   `docker rm -f $(docker ps -a -q)`

3. Delete all volumes using the following command:
   
   `docker volume rm $(docker volume ls -q)`

4. Restart the containers using the following command:
   
   `docker-compose up -d`

5. Create a database with the name `default` and the url as docker-compose.yaml `postgres://postgres:postgrespassword@postgres:5432/postgres` after that delete files changes on hasura folder to prevent errors and then run:

   `hasura migrate apply`
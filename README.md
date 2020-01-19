
#### Translation for: **[English](https://github.com/alisonbuss/quickstart-traefik2/blob/master/README_LANG_EN.md)**.

# Quickstart de um serviço de proxy reverso usando Traefik(v2. *), com Docker Compose e Swarm.

#### Status do Projeto: *(Finalizado)*.


### Projeto foi Inspirado:

  - *Live(Descomplicando o Docker - Aula ao vivo sobre Traefik) com [Jeferson Noronha](https://www.linkedin.com/in/jefersonfernando/) do [Canal LINUXtips](https://www.youtube.com/user/linuxtipscanal/) no Youtube e com participação de [Rafael Gomes(Gomex)](https://gomex.me/).*
  - *Playlist([Modo swarm do Docker usando o Traefik como proxy reverso](https://www.youtube.com/playlist?list=PLCCxPxhBWBUOjG16IYXRQJZCWKkC-vVX8)) do Canal [Marcelo Franco](https://www.youtube.com/channel/UC7-HcNHVyIZ2nQ2FhAhOtPA) no Youtube.*


### Dependências:

* **[[Docker](https://docs.docker.com/engine/docker-overview/)]** 18.09.6 ou superior...
* **[[Docker Compose](https://docs.docker.com/compose/)]** 1.24.0 ou superior...
* **[[GNU Make](https://www.gnu.org/software/make/)]** 4.1 ou superior...

> **Nota:**
> - *É necessário ter instalado as dependências citadas acima, para que o projeto funcione.*
> - *A execução desse projeto foi feita através de um **Desktop Ubuntu 19.04 (Dingo)**.*


### Documentação de apoio:

* **[Docker Compose File](https://docs.docker.com/compose/compose-file/)**.
* **[Docker - Networking](https://docs.docker.com/network/)**.
* **[Docker - Volumes](https://docs.docker.com/storage/volumes/)**.
* **[Docker - Create a swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)**.
* **[Docker - Deploy a stack to a swarm](https://docs.docker.com/engine/swarm/stack-deploy/)**.
* **[Traefik & Docker](https://docs.traefik.io/providers/docker/)**.
* **[Traefik & Configuration Introduction](https://docs.traefik.io/getting-started/configuration-overview/)**.
* **[Traefik & File](https://docs.traefik.io/providers/file/)**.
* **[Traefik & Static configuration with files](https://docs.traefik.io/reference/static-configuration/file/)**.
* **[Traefik & Dynamic configuration with files](https://docs.traefik.io/reference/dynamic-configuration/file/)**.
* **[Traefik & HTTPS with Let's Encrypt](https://docs.traefik.io/user-guides/docker-compose/acme-http/)**.
* **[Traefik & The Dashboard](https://docs.traefik.io/operations/dashboard/)**.
* **[Traefik & Observability Logs](https://docs.traefik.io/observability/logs/)**.
* **[Traefik & Observability Access Logs](https://docs.traefik.io/observability/access-logs/)**.


### Objetivo:

Fornecer um projeto de exemplo de proxy reverso e balanceador de carga para aplicativos baseados em HTTP e TCP.

O projeto fornece os seguintes recursos:

* *Dashboard do Treafik*.
* *SSL automático com ACME (Let's Encrypt)*.
* *Entrypoints para porta 80/443(http/https)*.
* *Service para balanceador de carga*.
* *Router para websecure em https*.
* *Router para o dashboard do Treafik em http*.
* *Middleware para redirecionar https*.
* *Middleware para autenticação de usuário e senha*.
* *Logs do Traefik*.
* *Logs de acessos do Traefik*.


### Diagrama:

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/example-diagram.png"/>
</p>


## Arquivos:

```text
.
├── files..................................Arquivos do projeto.
│   ├── example-diagram.png
│   ├── print-docker-compose.png
│   ├── print-docker-swarm.png
│   └── traefik-conf.......................Pasta de configurações do Traefik.
│       ├── authorized-users
│       │   └── usersfile..................Arquivo contendo usuários de acesso ao Dashboard do Traefik.
│       ├── dynamic-conf...................Pasta contendo os arquivos de configuração dinâmica.
│       │   └── traefik_dynamic_conf.yml
│       ├── letsencrypt....................Pasta contendo certificados TLS, para configuração dinâmica ou através do Let's Encrypt (ACME).
│       │   └── acme.json
│       └── traefik.yml....................Arquivo de configuração estática do Traefik.
├── stack-compose..........................Pasta contendo arquivos(Compose do Swarm) para implantar os serviços.
│   ├── stack-compose.app.yml
│   └── stack-compose.traefik.yml
├── docker-compose.yml.....................Arquivo de exemplo de um serviço Traefik para o modo Docker Compose.
├── LICENSE................................Licença (MIT).
├── Makefile...............................Arquivo principal de start do projeto "$ make help".
├── README_LANG_EN.md......................Arquivo de tradução do README.md.
└── README.md..............................Documentação Geral do Projeto.
```


## Preparar e Instalar o Ambiente:

Instalar o Docker e Docker Compose no Desktop/Server Ubuntu.

```bash
# Definir Host.
hostname "node01";
echo "node01" > /etc/hostname;
echo "127.0.1.1       node01" >> /etc/hosts;

# Iniciar Atualização.
apt-get update;

# Instalar o Docker mais atual.
curl -fsSL https://get.docker.com | bash;

# Instalar o Docker Compose.
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;

# Verificar Versão Docker.
docker version;

# Verificar Versão Docker Compose.
docker-compose version;

# Dar permissão de execução ao usuário.
usermod -aG docker $USER;

```




## In Docker Swarm:

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/print-docker-swarm.png"/>
</p>

```bash
docker image ls && docker network ls && docker volume ls && docker container ls;

docker swarm init --advertise-addr 192.168.0.16;

docker node ls;

docker service ls;

docker network create --driver=overlay network_swarm_public;
docker network create --driver=overlay network_swarm_private;

mkdir -p ./volumes/shared;
docker volume create --name volume_swarm_shared \
    --driver local \
    --opt type=none \
    --opt device=./volumes/shared \
    --opt o=bind;

mkdir -p ./volumes/certificates;
docker volume create --name volume_swarm_certificates \
    --driver local \
    --opt type=none \
    --opt device=./volumes/certificates \
    --opt o=bind;

docker stack deploy --compose-file ./stack-compose/stack-compose.traefik.yml traefik;
docker stack deploy --compose-file ./stack-compose/stack-compose.app.yml app;

docker service ls;

docker service logs traefik_reverse_proxy;

docker ps;

docker exec 4be0ec8b77bc traefik version;

docker exec 4be0ec8b77bc cat /var/log/traefik/traefik.log;

curl -H Host:whoami.swarm.localhost https://127.0.0.1 --insecure;

echo "127.0.1.1       traefik.swarm.localhost" >> /etc/hosts;
echo "127.0.1.1       whoami.swarm.localhost" >> /etc/hosts;

# Browser Test:
# Open: http://traefik.swarm.localhost/dashboard/
# Open: https://whoami.swarm.localhost/

docker stack rm traefik;
docker stack rm app;

docker volume rm --force volume_swarm_shared;
docker volume rm --force volume_swarm_certificates;
rm -rf ./volumes;

docker system prune -a;

```




## In Docker Compose:

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/print-docker-compose.png"/>
</p>

```bash
docker image ls && docker network ls && docker volume ls && docker container ls;

docker-compose --file ./docker-compose.yml config;

docker-compose --file ./docker-compose.yml images;

docker-compose --file ./docker-compose.yml build;

docker-compose --file ./docker-compose.yml up -d;

docker-compose --file ./docker-compose.yml ps;

curl -H Host:whoami.docker.localhost https://127.0.0.1 --insecure;

# Browser Test:
# Open: http://traefik.docker.localhost/dashboard/
# Open: https://whoami.docker.localhost/

docker-compose --file ./docker-compose.yml stop;

docker-compose --file ./docker-compose.yml rm -f;

docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -q) && docker system prune -a;

```






### References:

https://creekorful.me/how-to-expose-traefik-2-dashboard-securely-docker-swarm/

https://semaphoreci.com/community/tutorials/running-applications-on-a-docker-swarm-mode-cluster

https://containo.us/blog/traefik-2-0-docker-101-fc2893944b9d/



Game HTML5
https://github.com/CreateJS/EaselJS
https://github.com/CreateJS/EaselJS/tree/master/examples/Game
https://www.codementor.io/@yomateo/matthewdavis.io


https://www.youtube.com/watch?v=bsGkIKP1OZ4&fbclid=IwAR3joJ6n6pFvpOHcJsy_KXUtginsZ43yDivP1tdzLebWqzJL_6lW3ByV1G0

https://containo.us/blog/traefik-2-tls-101-23b4fbee81f1/
https://docs.traefik.io/migration/v1-to-v2/
https://timonweb.com/tutorials/an-example-of-docker-compose-and-traefik-config-domain-name-ssl-certificate/



https://blog.codeship.com/using-docker-compose-for-python-development/

https://docs.docker.com/compose/gettingstarted/


https://runnable.com/docker/python/docker-compose-with-flask-apps

https://pyinstaller.readthedocs.io/en/stable/

https://github.com/python/cpython

https://www.youtube.com/watch?v=LMsLJBmh654&list=PLucm8g_ezqNrrtduPx7s4BM8phepMn9I2&index=6

https://www.youtube.com/watch?v=Gojqw9BQ5qY

https://www.youtube.com/playlist?list=PLHz_AreHm4dlKP6QQCekuIPky1CiwmdI6


https://realpython.com/flask-connexion-rest-api/

https://realpython.com/api-integration-in-python/

https://www.codementor.io/@sagaragarwal94/building-a-basic-restful-api-in-python-58k02xsiq

https://code.tutsplus.com/pt/tutorials/building-restful-apis-with-flask-diy--cms-26625



https://mundevops.wordpress.com/2017/03/29/removendo-containers-e-imagens-do-docker/

https://woliveiras.com.br/posts/comandos-mais-utilizados-no-docker/



https://jtreminio.com/blog/traefik-on-docker-for-web-developers/


### License

[<img width="190" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/logo-open-source-550x200px.png">](https://opensource.org/licenses)
[<img width="166" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/icon-license-mit-500px.png">](https://github.com/alisonbuss/quickstart-traefik2/blob/master/LICENSE)

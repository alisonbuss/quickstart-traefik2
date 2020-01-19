
# Quickstart of a reverse proxy service using Traefik(v2.*) with Docker Compose and Swarm.

#### Project Status: *(Finished)*.



### Dependencies:

* **[[Docker](https://docs.docker.com/engine/docker-overview/)]** 18.09.6 ou higher...
* **[[Docker Compose](https://docs.docker.com/compose/)]** 1.24.0 ou higher...
* **[[GNU Make](https://www.gnu.org/software/make/)]** 4.1 ou higher...



### Supporting Documentation:

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



#### Configuration in Traefik can refer to two different things:

* The fully dynamic routing configuration (*referred to as the dynamic configuration*)
* The startup configuration (*referred to as the static configuration*)

Elements in the static configuration set up connections to providers and define the entrypoints Traefik will listen to (these elements don't change often).

The dynamic configuration contains everything that defines how the requests are handled by your system. This configuration can change and is seamlessly hot-reloaded, without any request interruption or connection loss.


#### The Dynamic Configuration:

Traefik gets its dynamic configuration from providers: whether an orchestrator, a service registry, or a plain old configuration file.

In this example, the dynamic configuration comes from docker in the form of labels attached to your containers.

You can add, update, remove them without restarting your Traefik instance.

HTTPS Certificates also belong to the dynamic configuration.


#### The Static Configuration:

There are three different, mutually exclusive (e.g. you can use only one at the same time), ways to define static configuration options in Traefik:

1. In a configuration file (/etc/traefik/traefik.yml)

2. In the command-line arguments

3. As environment variables

These ways are evaluated in the order listed above.

If no value was provided for a given option, a default value applies. Moreover, if an option has sub-options, and any of these sub-options is not specified, a default value will apply as well.


#### Configuration File:

At startup, Traefik searches for a file named traefik.toml (or traefik.yml or traefik.yaml) in:

* /etc/traefik/

* $XDG_CONFIG_HOME/

* $HOME/.config/

* . (working directory).

You can override this using the configFile argument:

    traefik --configFile=/etc/traefik/custom_traefik.toml



### Diagram:

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/example-diagram.png"/>
</p>



### Files:

```text
.
├── files
│   ├── example-diagram.png
│   ├── print-docker-compose.png
│   ├── print-docker-swarm.png
│   └── traefik-conf
│       ├── authorized-users
│       │   └── usersfile
│       ├── dynamic-conf
│       │   └── traefik_dynamic_conf.yml
│       ├── letsencrypt
│       │   └── acme.json
│       └── traefik.yml
├── stack-compose
│   ├── stack-compose.app.yml
│   └── stack-compose.traefik.yml
├── docker-compose.yml
├── LICENSE
├── Makefile
├── README_LANG_EN.md
└── README.md
```



### Prepare and Install the Environment:

Istall Docker and Docker Compose on the Ubuntu Desktop/Server.

```bash
sudo su -;

hostname "node01";
echo "node01" > /etc/hostname;
echo "127.0.1.1       node01" >> /etc/hosts;

apt-get update;

curl -fsSL https://get.docker.com | bash;

curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;

docker version;

docker-compose version;

usermod -aG docker "YourUser";

```



## Deploy in Docker Swarm mode:

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


## Deploy in Docker Compose mode:

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

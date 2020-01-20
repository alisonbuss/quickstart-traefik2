
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

### Diagram:

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/example-diagram.png"/>
</p>

### Traefik Configuration:

Original text:
[Traefik Docs - Configuration Introduction](https://docs.traefik.io/getting-started/configuration-overview/)

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

### Files:

```text
.
├── files..................................Project files.
│   ├── example-diagram.png
│   ├── print-docker-compose.png
│   ├── print-docker-swarm.png
│   └── traefik-conf.......................Traefik settings folder.
│       ├── authorized-users
│       │   └── usersfile..................File containing users accessing the Traefik Dashboard.
│       ├── dynamic-conf...................Folder containing the dynamic configuration files.
│       │   └── traefik_dynamic_conf.yml
│       ├── letsencrypt....................Folder containing TLS certificates, for dynamic configuration or through Let's Encrypt (ACME).
│       │   └── acme.json
│       └── traefik.yml....................Traefik static configuration file.
├── stack-compose..........................Folder containing files (Swarm's Compose) to deploy services.
│   ├── stack-compose.app.yml
│   └── stack-compose.traefik.yml
├── docker-compose.yml.....................Sample file of a Traefik service for Docker Compose mode.
├── LICENSE................................License (MIT).
├── Makefile...............................Main start file of the "$ make help" project.
├── README_LANG_EN.md......................README.md translation file.
└── README.md..............................General Project Documentation.

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

Before proceeding with the Deploy of the services, we need to activate the Swarm mode on the Ubuntu Desktop / Server.

To activate the Swarm mode on the machine, follow the commands below:

```bash
# Enable Swarm mode on the machine.
# This machine will be your Manager (The master node).
# Add an argument (- advertise-addr) by passing the machine's IP.
docker swarm init --advertise-addr 192.168.0.16;

# List all hosts joined to Swarm.
docker node ls;

```

In the Swarm mode of this project, there are two ways to run the deployment of a Traefik service:

1. In manual form.
2. In automated form.

#### In manual form:

To run the deploy in Swarm mode, follow the commands below:

```bash
docker image ls && docker network ls && docker volume ls && docker container ls;

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

docker exec <"GET THE CONTAINER TRAEFIK ID"> traefik version;

docker exec <"GET THE CONTAINER TRAEFIK ID"> cat /var/log/traefik/traefik.log;

curl -H Host:whoami.swarm.localhost https://127.0.0.1 --insecure;

echo "127.0.1.1       traefik.swarm.localhost" >> /etc/hosts;
echo "127.0.1.1       whoami.swarm.localhost" >> /etc/hosts;

```

#### Test services via Bowser:

* To test the Traefik Dashboard, open the Web Browser and access the address [http://traefik.swarm.localhost/dashboard/](http://traefik.swarm.localhost/dashboard/) the page will ask for a ***USER*** and ***PASSWORD*** enter **test**
* To test the Application, open the Web Browser and access [https://whoami.swarm.localhost/](https://whoami.swarm.localhost/)

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/print-docker-swarm.png"/>
</p>

To destroy all services, networks, volumes and images:

```bash
docker stack rm traefik;
docker stack rm app;

docker volume rm --force volume_swarm_shared;
docker volume rm --force volume_swarm_certificates;
rm -rf ./volumes;

docker system prune -a;

```

#### In automated form:

The automated mode is executed from a **Makefile**:

     $ make help

To run the services:

     $ make network-create volume-create stack-deploy

For general information about Swarm:

     $ make info

To destroy the services:

     $ make stack-remove network-remove volume-remove


## Deploy in Docker Compose mode:

To run the deploy in Docker Compose mode, follow the commands below:

```bash
docker image ls && docker network ls && docker volume ls && docker container ls;

docker-compose --file ./docker-compose.yml config;

docker-compose --file ./docker-compose.yml build --parallel;

docker-compose --file ./docker-compose.yml up --detach;

docker-compose --file ./docker-compose.yml ps;

docker exec <"GET THE CONTAINER TRAEFIK ID"> traefik version;

docker exec <"GET THE CONTAINER TRAEFIK ID"> cat /var/log/traefik/traefik.log;

# Testar se a aplicação está funcionando.
curl -H Host:whoami.docker.localhost https://127.0.0.1 --insecure;

```

#### Test services via Bowser:

* To test the Traefik Dashboard, open the Web Browser and access the address [http://traefik.docker.localhost/dashboard/](http://traefik.docker.localhost/dashboard/) the page will ask for a ***USER*** and ***PASSWORD*** enter **test**
* To test the Application, open the Web Browser and access [https://whoami.docker.localhost/](https://whoami.docker.localhost/)

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/print-docker-compose.png"/>
</p>

To destroy all services, networks, volumes and images:

```bash
docker-compose --file ./docker-compose.yml down;
docker-compose --file ./docker-compose.yml rm -f;

docker system prune -a;

## OR...
docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -q);

```

### References:

* Docker - Official Site, Docker Documentation. ***Docker overview*** <br/>
  Accessed: *December de 2020* <br/>
  Available: *[https://docs.docker.com/engine/docker-overview/](https://docs.docker.com/engine/docker-overview/)*

* Docker Compose - Official Site, Docker Compose Documentation. ***Docker Compose File*** <br/>
  Accessed: *December de 2020* <br/>
  Available: *[https://docs.docker.com/compose/compose-file/](https://docs.docker.com/compose/compose-file/)*

* Traefik - Official Site, Traefik Documentation. ***Configuration Introduction - How the Magic Happens*** <br/>
  Accessed: *December de 2020* <br/>
  Available: *[https://docs.traefik.io/getting-started/configuration-overview/](https://docs.traefik.io/getting-started/configuration-overview/)*

* Marcelo Franco, YouTube, Playlist. ***Modo swarm do Docker usando o Traefik como proxy reverso*** <br/>
  Accessed: *December de 2020*. <br/>
  Available: *[https://www.youtube.com/channel/UC7-HcNHVyIZ2nQ2FhAhOtPA/](https://www.youtube.com/channel/UC7-HcNHVyIZ2nQ2FhAhOtPA/)*.

* Aloïs Micard, Tech blog. ***How to expose Traefik 2.x dashboard securely on Docker Swarm*** <br/>
  Accessed: *January de 2020*. <br/>
  Available: *[https://creekorful.me/how-to-expose-traefik-2-dashboard-securely-docker-swarm/](https://creekorful.me/how-to-expose-traefik-2-dashboard-securely-docker-swarm/)*.

* Nigel Brown, Semaphore blog. ***Running Applications on a Docker Swarm Mode Cluster*** <br/>
  Accessed: *January de 2020*. <br/>
  Available: *[https://semaphoreci.com/community/tutorials/running-applications-on-a-docker-swarm-mode-cluster/](https://semaphoreci.com/community/tutorials/running-applications-on-a-docker-swarm-mode-cluster/)*.

* Gerald Croes e Ludovic Fernandez, Containo blog. ***Traefik 2.0 & Docker 101*** <br/>
  Accessed: *January de 2020*. <br/>
  Available: *[https://containo.us/blog/traefik-2-0-docker-101-fc2893944b9d/](https://containo.us/blog/traefik-2-0-docker-101-fc2893944b9d/)*.

* Gerald Croes, Containo blog. ***Traefik 2 & TLS 101*** <br/>
  Accessed: *January de 2020*. <br/>
  Available: *[https://containo.us/blog/traefik-2-tls-101-23b4fbee81f1/](https://containo.us/blog/traefik-2-tls-101-23b4fbee81f1/)*.

* Tim Kamanin, Blog. ***Docker compose and Traefik example configuration (domain name + SSL certificate)*** <br/>
  Accessed: *December de 2020*. <br/>
  Available: *[https://timonweb.com/tutorials/an-example-of-docker-compose-and-traefik-config-domain-name-ssl-certificate/](https://timonweb.com/tutorials/an-example-of-docker-compose-and-traefik-config-domain-name-ssl-certificate/)*.

* Juan Treminio, Blog. ***Traefik on Docker for Web Developers With bonus Let's Encrypt SSL!*** <br/>
  Accessed: *December de 2020*. <br/>
  Available: *[https://jtreminio.com/blog/traefik-on-docker-for-web-developers/](https://jtreminio.com/blog/traefik-on-docker-for-web-developers/)*.

* William Oliveira, Blog. ***COMANDOS MAIS UTILIZADOS NO DOCKER*** <br/>
  Accessed: *December de 2020*. <br/>
  Available: *[https://woliveiras.com.br/posts/comandos-mais-utilizados-no-docker/](https://woliveiras.com.br/posts/comandos-mais-utilizados-no-docker/)*.

### License

[<img width="190" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/logo-open-source-550x200px.png">](https://opensource.org/licenses)
[<img width="166" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/icon-license-mit-500px.png">](https://github.com/alisonbuss/quickstart-traefik2/blob/master/LICENSE)

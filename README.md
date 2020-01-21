
#### Translation for: **[English](https://github.com/alisonbuss/quickstart-traefik2/blob/master/README_LANG_EN.md)**.

# Quickstart de um serviço de proxy reverso usando Traefik(v2.*), com Docker Compose e Swarm.

#### Status do Projeto: *(Finalizado)*.

### Projeto foi Inspirado:

  - *Live(Descomplicando o Docker - Aula ao vivo sobre Traefik) com [Jeferson Noronha](https://www.linkedin.com/in/jefersonfernando/) do [Canal LINUXtips](https://www.youtube.com/user/linuxtipscanal/) no Youtube e com participação de [Rafael Gomes(Gomex)](https://gomex.me/).*
  - *Playlist([Modo swarm do Docker usando o Traefik como proxy reverso](https://www.youtube.com/playlist?list=PLCCxPxhBWBUOjG16IYXRQJZCWKkC-vVX8)) do Canal [Marcelo Franco](https://www.youtube.com/channel/UC7-HcNHVyIZ2nQ2FhAhOtPA) no Youtube.*

### Dependências:

* **[[Docker](https://docs.docker.com/engine/docker-overview/)]** 18.09.6 ou superior...
* **[[Docker Compose](https://docs.docker.com/compose/)]** 1.24.0 ou superior...
* **[[GNU Make](https://www.gnu.org/software/make/)]** 4.1 ou superior...

> **Nota:**
> - *É necessário ter instalado as dependências citadas a cima, para que o projeto funcione.*
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

* *Dashboard do Traefik*.
* *SSL automático com ACME (Let's Encrypt)*.
* *Entrypoints para porta 80/443(http/https)*.
* *Service para balanceador de carga*.
* *Router para websecure em https*.
* *Router para o dashboard do Traefik em http*.
* *Middleware para redirecionar https*.
* *Middleware para autenticação de usuário e senha*.
* *Logs do Traefik*.
* *Logs de acessos do Traefik*.

### Diagrama:

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/example-diagram.png"/>
</p>

### Configurações do Traefik:

Texto original:
[Traefik Docs - Configuration Introduction](https://docs.traefik.io/getting-started/configuration-overview/)

#### A configuração no Traefik pode se referir de duas formas diferentes:

* A configuração de roteamento totalmente dinâmica (*referida como configuração dinâmica*).
* A configuração de inicialização (*referida como configuração estática*).

Os elementos na configuração estática estabelecem conexões com os providers e definem os entrypoints que o Traefik escutará (esses elementos não mudam frequentemente).

A configuração dinâmica contém tudo o que define como os requests são tratadas pelo seu sistema. Essa configuração pode mudar e é recarregada sem problemas, sem qualquer interrupção do request ou perda de conexão.

#### A configuração dinâmica:

O Traefik obtém sua configuração dinâmica dos providers: seja um orquestrador, um registro de serviço ou um arquivo de configuração.

Nesse exemplo, a configuração dinâmica vem do Docker na forma de labels anexadas aos seus containers.

Você pode adicionar, atualizar, removê-los as configuração dinâmica sem reiniciar sua instância do Traefik.

Os certificados HTTPS também pertencem à configuração dinâmica.

#### A configuração estática:

Existem três maneiras de configuração estática no Traefik:

1. Em um arquivo de configuração. (/etc/traefik/traefik.yml)

2. Nos argumentos do command-line.

3. Como variáveis de ambiente.

Essas formas são avaliadas na ordem listada acima.

Se nenhum valor foi fornecido para uma determinada opção, será aplicado um valor padrão. Além disso, se uma opção tiver subopções e nenhuma dessas subopções for especificada, um valor padrão também será aplicado.

#### Arquivo de configuração:

Na inicialização, o Traefik procura um arquivo chamado traefik.toml (ou traefik.yml ou traefik.yaml) em:

* /etc/traefik/

* $XDG_CONFIG_HOME/

* $HOME/.config/

* . diretório de trabalho(working directory).

Você pode substituir o arquivo de configuração passando o argumento configFile:

    traefik --configFile=/etc/traefik/custom_traefik.toml

> **Nota:**
> - No arquivo(**./docker-compose.yml**) a configuração do Traefik está no modo **ARQUIVO** apontando para a pasta(**./files/traefik-conf**).
> - No arquivo(**./stack-compose/stack-compose.traefik.yml**) a configuração do Traefik está no modo **LABELS** e **COMMAND**.

### Arquivos:

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
├── stack-compose..........................Pasta contendo arquivos(Compose do Swarm) para implantar serviços.
│   ├── stack-compose.app.yml
│   └── stack-compose.traefik.yml
├── docker-compose.yml.....................Arquivo de exemplo de um serviço Traefik para o modo Docker Compose.
├── LICENSE................................Licença (MIT).
├── Makefile...............................Arquivo principal de start do projeto "$ make help".
├── README_LANG_EN.md......................Arquivo de tradução do README.md.
└── README.md..............................Documentação Geral do Projeto.
```

### Preparar e Instalar o Ambiente:

Instalar o Docker e Docker Compose no Desktop/Server Ubuntu.

```bash
# Entrar como super usuário:
sudo su -;

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
usermod -aG docker "YourUser";

```

### Deploy no modo Docker Swarm:

Antes de prosseguir com o Deploy dos serviços, precisamos ativar o modo Swarm no Desktop/Server Ubuntu.

Para ativar o modo Swarm na maquina, siga com os comandos abaixo:

```bash
# Habilitar modo Swarm na maquina.
# Essa maquina vai ser seu Manager(O nó mestre).
# Adicione argumento(--advertise-addr) passando IP da maquina. 
docker swarm init --advertise-addr 192.168.0.16;

# Listar todos os hosts ingressados ao Swarm.
docker node ls;

```

No modo Swarm desse projeto, há duas formas de rodar o deploy de um serviço Traefik:

1. Na forma manual.
2. Na forma automatizada.

#### Na forma manual:

Para rodar o deploy no mode Swarm, siga com os comandos abaixo:

```bash
# Exibir informações gerais do ambiente Docker.
docker image ls && docker network ls && docker volume ls && docker container ls;

# Listar todos os serviços do Swarm.
docker service ls;

# Criar redes do tipo overlay para ser usando no Swarm.
docker network create --driver=overlay network_swarm_public;
docker network create --driver=overlay network_swarm_private;

# Criar volume(shared) para salvar dados compartilhados.
mkdir -p ./volumes/shared;
docker volume create --name volume_swarm_shared \
    --driver local \
    --opt type=none \
    --opt device=./volumes/shared \
    --opt o=bind;

# Criar volume(certificates) para salvar dados dos certificados.
mkdir -p ./volumes/certificates;
docker volume create --name volume_swarm_certificates \
    --driver local \
    --opt type=none \
    --opt device=./volumes/certificates \
    --opt o=bind;

# Rodar uma stack do serviço Traefik:
docker stack deploy --compose-file ./stack-compose/stack-compose.traefik.yml traefik;

# Rodar uma stack de uma aplicação de teste:
docker stack deploy --compose-file ./stack-compose/stack-compose.app.yml app;

# Listar todos os serviços do Swarm.
docker service ls;

# Exibir logs de um serviço(Traefik) do Swarm.
docker service logs traefik_reverse_proxy;

# Listar todos os contêiner.
docker ps;

# Imprimir a versão do Traefik em atividade.
docker exec <"OBTENHA O ID DO CONTÊINER TRAEFIK"> traefik version;

# Exibir o log do Traefik em atividade.
docker exec <"OBTENHA O ID DO CONTÊINER TRAEFIK"> cat /var/log/traefik/traefik.log;

# Testar se a aplicação está funcionando.
curl -H Host:whoami.swarm.localhost https://127.0.0.1 --insecure;

# Adicionar endereço local dos serviços.  
echo "127.0.1.1       traefik.swarm.localhost" >> /etc/hosts;
echo "127.0.1.1       whoami.swarm.localhost" >> /etc/hosts;

```

#### Testar os serviços via Bowser:

* Para testar o Dashboard do Traefik, abra o Navegador Web e acesse o endereço [http://traefik.swarm.localhost/dashboard/](http://traefik.swarm.localhost/dashboard/) a pagina vai pedir um ***USUÁRIO*** e ***SENHA*** digite **test**
* Para testar o Aplicação, abra o Navegador Web e acesse o endereço [https://whoami.swarm.localhost/](https://whoami.swarm.localhost/)

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/print-docker-swarm.png"/>
</p>

Para destruir todos os serviços, network, volumes e imagens:

```bash
# Remove stack do Swarm.
docker stack rm traefik;
docker stack rm app;

# Remove volume do Docker.
docker volume rm --force volume_swarm_shared;
docker volume rm --force volume_swarm_certificates;
rm -rf ./volumes;

# DANDO UMA LIMPADA NO AMBIENTE:
# Esse comando remove todos os contêineres parados, redes não utilizadas, imagens pendentes e caches de compilação...
# É o satanais!!!
docker system prune -a;

```

#### Na forma automatizada:

O modo automatizado é executado a partir de um **Makefile**:

    $ make help

Para rodar os serviços:

    $ make network-create volume-create stack-deploy

Para obter informações gerais do Swarm:

    $ make info

Para destruir os serviços:

    $ make stack-remove network-remove volume-remove


## Deploy no modo Docker Compose:

Para rodar o deploy no mode Docker Compose, siga com os comandos abaixo:

```bash
# Exibir informações gerais do ambiente Docker.
docker image ls && docker network ls && docker volume ls && docker container ls;

# Valide e visualize o arquivo de composição.
docker-compose --file ./docker-compose.yml config;

# Criar ou reconstruir serviços e construa imagens em paralelo.
docker-compose --file ./docker-compose.yml build --parallel;

# Criar ou reconstruir serviços no modo desanexado.
docker-compose --file ./docker-compose.yml up --detach;

# Lista todos os containers do Compose.
docker-compose --file ./docker-compose.yml ps;

# Imprimir a versão do Traefik em atividade.
docker exec <"OBTENHA O ID DO COMANDO ANTERIOR"> traefik version;

# Imprimir o log do Traefik em atividade.
docker exec <"ID DE UM DETERMINADO CONTÊINER"> cat /var/log/traefik/traefik.log;

# Testar se a aplicação está funcionando.
curl -H Host:whoami.docker.localhost https://127.0.0.1 --insecure;

```

#### Testar os serviços via Bowser:

* Para testar o Dashboard do Traefik, abra o Navegador Web e acesse o endereço [http://traefik.docker.localhost/dashboard/](http://traefik.docker.localhost/dashboard/) a pagina vai pedir um ***USUÁRIO*** e ***SENHA*** digite **test**
* Para testar o Aplicação, abra o Navegador Web e acesse o endereço [https://whoami.docker.localhost/](https://whoami.docker.localhost/)

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/print-docker-compose.png"/>
</p>

Para destruir todos os serviços, network, volumes e imagens:

```bash
# Parar e remover contêineres, redes, imagens e volumes.
docker-compose --file ./docker-compose.yml down;
docker-compose --file ./docker-compose.yml rm -f;

# DANDO UMA LIMPADA NO AMBIENTE:
# Esse comando remove todos os contêineres parados, redes não utilizadas, imagens pendentes e caches de compilação...
# É o satanais!!!
docker system prune -a;

## OU...
docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -q);

```

### Referências:

* Docker - Official Site, Docker Documentation. ***Docker overview*** <br/>
  Acessado: *Dezembro de 2019* <br/>
  Disponível: *[https://docs.docker.com/engine/docker-overview/](https://docs.docker.com/engine/docker-overview/)*

* Docker Compose - Official Site, Docker Compose Documentation. ***Docker Compose File*** <br/>
  Acessado: *Dezembro de 2019* <br/>
  Disponível: *[https://docs.docker.com/compose/compose-file/](https://docs.docker.com/compose/compose-file/)*

* Traefik - Official Site, Traefik Documentation. ***Configuration Introduction - How the Magic Happens*** <br/>
  Acessado: *Dezembro de 2019* <br/>
  Disponível: *[https://docs.traefik.io/getting-started/configuration-overview/](https://docs.traefik.io/getting-started/configuration-overview/)*

* Marcelo Franco, YouTube, Playlist. ***Modo swarm do Docker usando o Traefik como proxy reverso*** <br/>
  Acessado: *Dezembro de 2019*. <br/>
  Disponível: *[https://www.youtube.com/channel/UC7-HcNHVyIZ2nQ2FhAhOtPA/](https://www.youtube.com/channel/UC7-HcNHVyIZ2nQ2FhAhOtPA/)*.

* Aloïs Micard, Tech blog. ***How to expose Traefik 2.x dashboard securely on Docker Swarm*** <br/>
  Acessado: *Janeiro de 2020*. <br/>
  Disponível: *[https://creekorful.me/how-to-expose-traefik-2-dashboard-securely-docker-swarm/](https://creekorful.me/how-to-expose-traefik-2-dashboard-securely-docker-swarm/)*.

* Nigel Brown, Semaphore blog. ***Running Applications on a Docker Swarm Mode Cluster*** <br/>
  Acessado: *Janeiro de 2020*. <br/>
  Disponível: *[https://semaphoreci.com/community/tutorials/running-applications-on-a-docker-swarm-mode-cluster/](https://semaphoreci.com/community/tutorials/running-applications-on-a-docker-swarm-mode-cluster/)*.

* Gerald Croes e Ludovic Fernandez, Containo blog. ***Traefik 2.0 & Docker 101*** <br/>
  Acessado: *Janeiro de 2020*. <br/>
  Disponível: *[https://containo.us/blog/traefik-2-0-docker-101-fc2893944b9d/](https://containo.us/blog/traefik-2-0-docker-101-fc2893944b9d/)*.

* Gerald Croes, Containo blog. ***Traefik 2 & TLS 101*** <br/>
  Acessado: *Janeiro de 2020*. <br/>
  Disponível: *[https://containo.us/blog/traefik-2-tls-101-23b4fbee81f1/](https://containo.us/blog/traefik-2-tls-101-23b4fbee81f1/)*.

* Tim Kamanin, Blog. ***Docker compose and Traefik example configuration (domain name + SSL certificate)*** <br/>
  Acessado: *Dezembro de 2019*. <br/>
  Disponível: *[https://timonweb.com/tutorials/an-example-of-docker-compose-and-traefik-config-domain-name-ssl-certificate/](https://timonweb.com/tutorials/an-example-of-docker-compose-and-traefik-config-domain-name-ssl-certificate/)*.

* Juan Treminio, Blog. ***Traefik on Docker for Web Developers With bonus Let's Encrypt SSL!*** <br/>
  Acessado: *Dezembro de 2019*. <br/>
  Disponível: *[https://jtreminio.com/blog/traefik-on-docker-for-web-developers/](https://jtreminio.com/blog/traefik-on-docker-for-web-developers/)*.

* William Oliveira, Blog. ***COMANDOS MAIS UTILIZADOS NO DOCKER*** <br/>
  Acessado: *Dezembro de 2019*. <br/>
  Disponível: *[https://woliveiras.com.br/posts/comandos-mais-utilizados-no-docker/](https://woliveiras.com.br/posts/comandos-mais-utilizados-no-docker/)*.

### Licença

[<img width="190" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/logo-open-source-550x200px.png">](https://opensource.org/licenses)
[<img width="166" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/icon-license-mit-500px.png">](https://github.com/alisonbuss/quickstart-traefik2/blob/master/LICENSE)

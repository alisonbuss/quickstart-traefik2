
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

### Configurações do Traefik:

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
> - No arquivo(**./docker-compose.yml**) a configuração do Traefik está no mode **ARQUIVO** apontando para a pasta(**./files/traefik-conf**).
> - No arquivo(**./stack-compose/stack-compose.traefik.yml**) a configuração do Traefik está no mode **LABELS** e **COMMAND**.

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

No mode Swarm desse projeto, há duas formas de rodar o deploy de um serviço Traefik:

1. Modo manual e tediosa.
2. Modo automatizado e simples.

#### No modo automatizado:

O mode automatizado é executado a partir de um **Makefile**:

    $ make help

Para rodar os serviços:

    $ make network-create volume-create stack-deploy

Para obter informações gerais do Swarm:

    $ make info

Testar os serviços:

* Para testar o Dashboard do Traefik, abra o Navegador Web e acesse o endereço [http://traefik.swarm.localhost/dashboard/](http://traefik.swarm.localhost/dashboard/) a pagina vai pedir um ***USUÁRIO*** e ***SENHA*** digite **test**
* Para testar o Aplicação, abra o Navegador Web e acesse o endereço [https://whoami.swarm.localhost/](https://whoami.swarm.localhost/)

<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/print-docker-swarm.png"/>
</p>

Para destruir os serviços:

    $ make stack-remove network-remove volume-remove

#### No modo manual:

Executando os seguintes comandos:

```bash
# Imprimir informações gerais do ambiente Docker.
docker image ls && docker network ls && docker volume ls && docker container ls;

# Habilitar mode Swarm na maquina.
docker swarm init --advertise-addr 192.168.0.16;

# Imprimir todos os nodes do modo Swarm.
docker node ls;

# Imprimir todos os serviços do modo Swarm.
docker service ls;

# Criar redes do tipo overlay para o modo Swarm.
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

# Imprimir todos os serviços do modo Swarm.
docker service ls;

# Exibir logs de um contêiner ou serviço.
docker service logs traefik_reverse_proxy;

# Imprimir todos os contêiner.
docker ps;

# Imprimir a versão do Traefik em atividade.
docker exec <"OBTENHA O ID DO COMANDO ANTERIOR"> traefik version;

# Imprimir o log do Traefik em atividade.
docker exec <"ID DE UM DETERMINADO CONTÊINER"> cat /var/log/traefik/traefik.log;

# Testar se a aplicação está funcionando.
curl -H Host:whoami.swarm.localhost https://127.0.0.1 --insecure;

# Adicionar endereço local dos serviços.  
echo "127.0.1.1       traefik.swarm.localhost" >> /etc/hosts;
echo "127.0.1.1       whoami.swarm.localhost" >> /etc/hosts;

```

Destruir todos os serviços, network, volumes e imagens:

```bash
# Remove stack do Swarm.
docker stack rm traefik;
docker stack rm app;

# Remove volume do Docker.
docker volume rm --force volume_swarm_shared;
docker volume rm --force volume_swarm_certificates;
rm -rf ./volumes;

# Remove todos os contêineres parados, redes não utilizadas, imagens pendentes e caches de compilação...
# É o satanais!!!
docker system prune -a;

```

## Deploy no modo Docker Compose:


```bash
# Imprimir informações gerais do ambiente Docker.
docker image ls && docker network ls && docker volume ls && docker container ls;

# Valide e visualize o arquivo de composição.
docker-compose --file ./docker-compose.yml config;

# Criar ou reconstruir serviços.
docker-compose --file ./docker-compose.yml build;

# Criar e start os containers.
docker-compose --file ./docker-compose.yml up --build --detach;

# Lista todos os containers do Compose.
docker-compose --file ./docker-compose.yml ps;

# Imprimir a versão do Traefik em atividade.
docker exec <"OBTENHA O ID DO COMANDO ANTERIOR"> traefik version;

# Imprimir o log do Traefik em atividade.
docker exec <"ID DE UM DETERMINADO CONTÊINER"> cat /var/log/traefik/traefik.log;

# Testar se a aplicação está funcionando.
curl -H Host:whoami.docker.localhost https://127.0.0.1 --insecure;

```

Testar os serviços:

* Para testar o Dashboard do Traefik, abra o Navegador Web e acesse o endereço [http://traefik.docker.localhost/dashboard/](http://traefik.docker.localhost/dashboard/) a pagina vai pedir um ***USUÁRIO*** e ***SENHA*** digite **test**
* Para testar o Aplicação, abra o Navegador Web e acesse o endereço [https://whoami.docker.localhost/](https://whoami.docker.localhost/)


<p align="center">
    <img src="https://github.com/alisonbuss/quickstart-traefik2/raw/master/files/print-docker-compose.png"/>
</p>

Destruir todos os serviços, network, volumes e imagens:


```bash
# Parar e remover contêineres, redes, imagens e volumes.
docker-compose --file ./docker-compose.yml down;
docker-compose --file ./docker-compose.yml rm -f;

# Remove todos os contêineres parados, redes não utilizadas, imagens pendentes e caches de compilação...
# É o satanais!!!
docker system prune -a;

# Remove tudo!!!
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

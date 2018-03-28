#!/bin/bash
W_TEXT=`echo -e "\033[33m"`
NORMAL=`echo -e "\033[m"`
RED_TEXT=`echo -e "\033[31m"`

export DEBEZIUM_VERSION='0.7'

docker-clear(){
    echo "${YELLOW_TEXT} >>> REMOVE CONTAINERS AND IMAGES ${NORMAL}" && \
    # Delete all containers
    docker rm $(docker ps -a -q)
    # Delete all images
    docker rmi $(docker images -q)
}

demo-clear(){
    rm -rf /tmp/postinstall
}

docker-get-images(){
    echo "${YELLOW_TEXT} >>> PULL IMAGES ${NORMAL}" && \
    docker pull debezium/zookeeper:${DEBEZIUM_VERSION} && \
    docker pull debezium/kafka:${DEBEZIUM_VERSION} && \
    docker pull debezium/example-postgres:${DEBEZIUM_VERSION} && \
    docker pull confluentinc/cp-schema-registry && \
    docker pull rzrbld/jdbc-debezium
}

docker-run(){
  echo "${YELLOW_TEXT} >>> RUN CONTAINERS ${NORMAL}" && \
  rm -rf /tmp/postinstall
  curl -fSL -o /tmp/postinstall.zip \
             https://github.com/rzrbld/jdbc-debezium-postinstall/archive/master.zip &&\
  mkdir -p /tmp/postinstall && \
  mkdir -p /opt/debezium && \
  unzip /tmp/postinstall.zip -d /tmp/postinstall/ &&\
  rm -rf /tmp/postinstall.zip &&\
  chmod +x /tmp/postinstall/jdbc-debezium-postinstall-master/register-connectors.sh && \
  byobu start-server && \
  byobu new-session -d -s debeziumdemo -n docker &&\
  byobu new-window -t debeziumdemo:1 -n kafka &&\
  byobu new-window -t debeziumdemo:2 -n postgres &&\
  byobu new-window -t debeziumdemo:3 -n sqlite &&\
  byobu new-window -t debeziumdemo:4 -n post &&\
  if [[ "$1" = "avro" ]]; then
      echo "${YELLOW_TEXT} >>> RUN AVRO COMPOSE ${NORMAL}" && \
      tmux send-keys -t debeziumdemo:0 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-avro-demo.yaml up " C-m
  else
      echo "${YELLOW_TEXT} >>> RUN JSON COMPOSE ${NORMAL}" && \
      tmux send-keys -t debeziumdemo:0 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-demo.yaml up " C-m
  fi
  sleep 80 &&
  tmux send-keys -t debeziumdemo:4 "sleep 10 && /tmp/postinstall/jdbc-debezium-postinstall-master/register-connectors.sh" C-m &&
  tmux send-keys -t debeziumdemo:1 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-demo.yaml exec kafka /kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --from-beginning --property print.key=true --topic customers " C-m &&
  tmux send-keys -t debeziumdemo:2 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-demo.yaml exec postgres env PGOPTIONS=\"--search_path=inventory\" bash -c 'psql -U $POSTGRES_USER postgres -c \"SELECT * FROM inventory.customers;\" ' " C-m &&
  tmux send-keys -t debeziumdemo:3 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-demo.yaml exec connect sqlite3 /kafka/consumers.db \"SELECT * FROM customers;\"" C-m &&
  byobu attach-session -t debeziumdemo
}

check-type(){
    echo "${YELLOW_TEXT} >>> CHECK TYPE ${NORMAL}"
    if [[ "$1" =~ ^(avro|json)$ ]]; then
        echo "${YELLOW_TEXT} >>> TYPE RECONIZED AS: $1 ${NORMAL}"
        return 0
    else
        echo "${RED_TEXT} >>> ONLY json,avro SUPPORTED AS TYPES ${NORMAL}"
        echo "${RED_TEXT} >>> OPERATION WILL BE TERMINATED ${NORMAL}";
        return 1
    fi
}




echo ${RED_TEXT} '

██████╗ ███████╗██████╗ ███████╗███████╗██╗██╗   ██╗███╗   ███╗
██╔══██╗██╔════╝██╔══██╗██╔════╝╚══███╔╝██║██║   ██║████╗ ████║
██║  ██║█████╗  ██████╔╝█████╗    ███╔╝ ██║██║   ██║██╔████╔██║
██║  ██║██╔══╝  ██╔══██╗██╔══╝   ███╔╝  ██║██║   ██║██║╚██╔╝██║
██████╔╝███████╗██████╔╝███████╗███████╗██║╚██████╔╝██║ ╚═╝ ██║
╚═════╝ ╚══════╝╚═════╝ ╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝     ╚═╝

Demo debezium sink v.0.0.2
use -h key for more information

'${NORMAL};


for i in "$@"
do
case $i in
    -r=*|--run=*)
    READ_TYPE="${i#*=}"
    if check-type ${READ_TYPE}; then docker-get-images && docker-run ${READ_TYPE}; else echo "${RED_TEXT} >>> OPERATION TERMINATED ${NORMAL}"; fi
    ;;
    -d|--delete)
    docker-clear && demo-clear
    ;;
    -h|--usage)
    echo "${YELLOW_TEXT} usage:
    -r=* or --run=*       : run demo (*- is avro or json)
    -d   or --delete      : remove docker image and containers
    -h   or --usage       : this manual

    questions and suggestions: @a.petrukhin
    s7 2018

    ${NORMAL}"
    ;;
    *)
    echo "unknown option use -h key for more information";
    ;;
esac
done

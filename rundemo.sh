#!/bin/bash
mkdir -p /opt/debezium && \
curl -fSL -o /tmp/postinstall.zip \
             https://github.com/rzrbld/jdbc-debezium-postinstall/archive/master.zip &&\
rm -rf /tmp/postinstall
mkdir -p /tmp/postinstall && \
unzip /tmp/postinstall.zip -d /tmp/postinstall/ &&\
rm -rf /tmp/postinstall.zip &&\
chmod +x /tmp/postinstall/jdbc-debezium-postinstall-master/register-connectors.sh && \
echo "run demo" && \
byobu start-server && \
byobu new-session -d -s debeziumdemo -n docker &&\
byobu new-window -t debeziumdemo:1 -n kafka &&\
byobu new-window -t debeziumdemo:2 -n postgres &&\
byobu new-window -t debeziumdemo:3 -n sqlite &&\
byobu new-window -t debeziumdemo:4 -n post &&\
tmux send-keys -t debeziumdemo:0 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-demo.yaml up " C-m
sleep 70 &&
tmux send-keys -t debeziumdemo:4 "/tmp/postinstall/jdbc-debezium-postinstall-master/register-connectors.sh" C-m
tmux send-keys -t debeziumdemo:1 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-demo.yaml exec kafka /kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --from-beginning --property print.key=true --topic customers " C-m
tmux send-keys -t debeziumdemo:2 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-demo.yaml exec postgres env PGOPTIONS=\"--search_path=inventory\" bash -c 'psql -U $POSTGRES_USER postgres' -c \"SELECT * FROM inventory.customers;\" " C-m
tmux send-keys -t debeziumdemo:3 "export DEBEZIUM_VERSION=0.7 && cd /opt/debezium; docker-compose -f docker-compose-debezium-demo.yaml exec connect sqlite3 /kafka/consumers.db \"SELECT * FROM customers;\"" C-m
byobu attach-session -t debeziumdemo

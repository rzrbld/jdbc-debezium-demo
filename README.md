# jdbc-debezium-demo
simple demo pg to sqlite over debezium

### requirements
docker, docker-compose, byobu, unzip, curl, wget,

use avro:
```
rm -rf /opt/debezium ; rm /opt/master.zip ; cd /opt/ && wget https://github.com/rzrbld/jdbc-debezium-demo/archive/master.zip && unzip master.zip && mv jdbc-debezium-demo-master debezium && chmod +x debezium/rundemo.sh && cd /opt/debezium/ && ./rundemo.sh -r=avro
```

use json:
```
rm -rf /opt/debezium ; rm /opt/master.zip ; cd /opt/ && wget https://github.com/rzrbld/jdbc-debezium-demo/archive/master.zip && unzip master.zip && mv jdbc-debezium-demo-master debezium && chmod +x debezium/rundemo.sh && cd /opt/debezium/ && ./rundemo.sh -r=json
```

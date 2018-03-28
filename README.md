# jdbc-debezium-demo
simple demo pg to sqlite over debezium
```
rm -rf /opt/debezium ; rm /opt/master.zip ; cd /opt/ && wget https://github.com/rzrbld/jdbc-debezium-demo/archive/master.zip && unzip master.zip && mv jdbc-debezium-demo-master debezium && chmod +x debezium/rundemo.sh && chmod +x debezium/cleandemo.sh && cd /opt/debezium/ && ./rundemo.sh
```

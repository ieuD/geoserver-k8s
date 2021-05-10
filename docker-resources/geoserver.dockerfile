FROM  openjdk:8



ENV GEOSERVER_HOME /geoserver
ENV GEOMESA_CASSANDRA_HOME /tmp/geomesa/geomesa-cassandra_2.11-3.2.0
RUN apt-get update && apt-get install uuid-runtime vim -y

RUN wget https://build.geoserver.org/geoserver/2.17.x/geoserver-2.17.x-2021-03-01-bin.zip -P  /tmp/geoserver && \ 
    wget https://build.geoserver.org/geoserver/2.17.x/community-2021-03-01/geoserver-2.17-SNAPSHOT-activeMQ-broker-plugin.zip -P /tmp/activemq && \
    wget https://build.geoserver.org/geoserver/2.17.x/community-2021-03-01/geoserver-2.17-SNAPSHOT-jms-cluster-plugin.zip -P /tmp/jmsCluster && \ 
    wget https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.0/commons-pool2-2.0.jar -P /tmp/commons && \ 
    wget https://github.com/locationtech/geomesa/releases/download/geomesa-3.2.0/geomesa-cassandra_2.11-3.2.0-bin.tar.gz -P /tmp/geomesa

RUN unzip /tmp/geoserver/*.zip -d /geoserver && \ 
    unzip /tmp/activemq/*.zip -d /tmp/unpacked && \ 
    unzip /tmp/jmsCluster/*.zip -d /tmp/unpacked && \
    tar xvf /tmp/geomesa/geomesa-cassandra_2.11-3.2.0-bin.tar.gz --directory /tmp/geomesa/ 


RUN cp ${GEOMESA_CASSANDRA_HOME}/dist/gs-plugins/*.jar ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \ 
      tar -xzvf ${GEOMESA_CASSANDRA_HOME}/dist/gs-plugins/geomesa-cassandra-gs-plugin_2.11-3.2.0-install.tar.gz -C ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
      mv /tmp/commons/*.jar ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \ 
      mv /tmp/unpacked/*.jar ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
      mkdir -p ${GEOSERVER_HOME}/data_dir/cluster 

RUN ["bash","-c","${GEOMESA_CASSANDRA_HOME}/bin/install-dependencies.sh ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ --no-prompt"]
ADD ./gs-jms-commons-2.17-SNAPSHOT.jar ./gs-jms-geoserver-2.17-SNAPSHOT.jar  ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/
ADD ./cluster.properties ${GEOSERVER_HOME}/data_dir/cluster/

FROM openjdk:8-jre-slim
ARG JMETER_VERSION

ENV JMETER_VERSION ${JMETER_VERSION:-5.2.1}
ENV JMETER_HOME /jmeter/apache-jmeter-$JMETER_VERSION/
ENV PATH $JMETER_HOME/bin:$PATH

RUN echo $JMETER_VERSION

# INSTALL PRE-REQ

RUN apt-get update && \
    apt-get -y install \
    wget \
    unzip

# INSTALL JMETER BASE
RUN mkdir /jmeter
WORKDIR /jmeter

RUN echo $JMETER_VERSION


RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz && \
    tar -xzf apache-jmeter-$JMETER_VERSION.tgz && \
    rm apache-jmeter-$JMETER_VERSION.tgz && \
    mkdir /jmeter-plugins && \
    cd /jmeter-plugins/ && \
    wget https://jmeter-plugins.org/downloads/file/JMeterPlugins-ExtrasLibs-1.4.0.zip && \
    unzip -o JMeterPlugins-ExtrasLibs-1.4.0.zip -d /jmeter/apache-jmeter-$JMETER_VERSION

RUN wget -P ${JMETER_HOME}lib/ext https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.3/jmeter-plugins-manager-1.3.jar && \
    wget -P ${JMETER_HOME}lib https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar && \
    java -cp ${JMETER_HOME}lib/ext/jmeter-plugins-manager-1.3.jar org.jmeterplugins.repository.PluginManagerCMDInstaller

RUN ${JMETER_HOME}bin/PluginsManagerCMD.sh install jpgc-casutg,jpgc-graphs-basic,jpgc-graphs-composite,jpgc-graphs-vs,jpgc-graphs-additional,jpgc-ggl,jpgc-cmd,jpgc-synthesis,jpgc-graphs-dist,jmeter.backendlistener.azure=0.2.0,jmeter.backendlistener.elasticsearch=2.6.10,jmeter.backendlistener.kafka=1.0.0

RUN wget -P ${JMETER_HOME}lib/ext https://repo1.maven.org/maven2/com/github/johrstrom/jmeter-prometheus-plugin/0.6.0/jmeter-prometheus-plugin-0.6.0.jar

RUN echo $JMETER_VERSION

WORKDIR $JMETER_HOME

COPY config/user.properties bin/user.properties
COPY config/setenv.sh bin/setenv.sh
COPY scripts/install_plugin-manager.sh .
COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x install_plugin-manager.sh /docker-entrypoint.sh
RUN ./install_plugin-manager.sh

EXPOSE 60000 1099 50000
ENV SSL_DISABLED true
ENTRYPOINT ["/docker-entrypoint.sh"]


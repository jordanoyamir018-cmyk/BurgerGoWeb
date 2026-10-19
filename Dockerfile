FROM eclipse-temurin:25-jdk

# Instalar Tomcat 9 limpiamente
RUN apt-get update && apt-get install -y wget && \
    wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz && \
    tar -xzvf apache-tomcat-9.0.80.tar.gz -C /opt/ && \
    mv /opt/apache-tomcat-9.0.80 /opt/tomcat && \
    rm apache-tomcat-9.0.80.tar.gz && \
    rm -rf /opt/tomcat/webapps/*

COPY dist/BurgerGoWeb.war /opt/tomcat/webapps/ROOT.war

# Modificar server.xml al iniciar el contenedor para que Tomcat escuche en el puerto que le asigna Render ($PORT)
CMD sh -c "sed -i 's/port=\"8080\"/port=\"'\"${PORT:-8080}\"'\"/g' /opt/tomcat/conf/server.xml && /opt/tomcat/bin/catalina.sh run"
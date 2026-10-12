FROM tomcat:9.0-jdk11-openjdk-slim
RUN sed -i 's/port="8005"/port="-1"/' /usr/local/tomcat/conf/server.xml
COPY dist/BurgerGoWeb.war /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh", "run"]
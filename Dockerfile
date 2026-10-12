FROM tomcat:9.0-jdk11-openjdk-slim
COPY server.xml /usr/local/tomcat/conf/server.xml
COPY dist/BurgerGoWeb.war /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh", "run"]
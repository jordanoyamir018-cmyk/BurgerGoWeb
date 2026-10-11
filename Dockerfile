FROM tomcat:9.0-jdk11-openjdk-slim
COPY dist/BurgerGoWeb.war /usr/local/tomcat/webapps/ROOT.war
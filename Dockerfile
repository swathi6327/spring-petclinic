FROM openjdk:17-jdk-alpine
COPY petclinic.jar /app/petclinic.jar
WORKDIR /app
ENTRYPOINT ["java", "-jar", "petclinic.jar"]

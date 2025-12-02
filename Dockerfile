FROM eclipse-temurin:21-jdk-jammy

WORKDIR /app
COPY build/libs/*.jar app.jar

ENV PORT=8080
EXPOSE $PORT

ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT} -jar /app/app.jar"]

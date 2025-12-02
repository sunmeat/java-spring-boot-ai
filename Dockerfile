# офіційний образ з Java 21
FROM openjdk:21-jdk-slim

# копіюємо JAR з Gradle-білду
COPY build/libs/java-spring-boot-ai-0.0.1-SNAPSHOT.jar app.jar

# вказуємо, що додаток слухатиме порт, який дасть Render
ENV PORT 8080
EXPOSE $PORT

# запускаємо JAR з правильним портом
ENTRYPOINT ["java", "-Dserver.port=${PORT}", "-jar", "/app.jar"]

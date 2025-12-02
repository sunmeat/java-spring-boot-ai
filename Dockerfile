# Етап 1 — збірка на Java 21
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /app

# Копіюємо Gradle-файли
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Копіюємо код
COPY src src

# Примусово вимикаємо toolchain і збираємо на Java 21
RUN chmod +x gradlew
RUN ./gradlew build -x test --no-daemon -PuseToolchain=false

# Етап 2 — фінальний образ (легкий, тільки JRE 21)
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Копіюємо готовий JAR
COPY --from=builder /app/build/libs/java-spring-boot-ai-0.0.1-SNAPSHOT.jar app.jar

# Порт від Render
EXPOSE $PORT

# Запуск
ENTRYPOINT ["java", "-Dserver.port=${PORT}", "-jar", "app.jar"]

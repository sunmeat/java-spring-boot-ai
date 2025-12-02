# Етап 1 — збираємо JAR через Gradle
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /build

# Копіюємо тільки те, що потрібно для Gradle (швидше кеш)
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
COPY src src

# Даємо права і збираємо JAR (без тестів)
RUN chmod +x gradlew
RUN ./gradlew bootJar -x test

# Етап 2 — фінальний легкий образ
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Копіюємо готовий JAR з попереднього етапу
COPY --from=builder /build/build/libs/java-spring-boot-ai-0.0.1-SNAPSHOT.jar app.jar

# Порт, який дає Render
EXPOSE $PORT

# Запуск
ENTRYPOINT ["java", "-Dserver.port=${PORT}", "-jar", "app.jar"]

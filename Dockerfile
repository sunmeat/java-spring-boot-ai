# Етап 1 — збірка
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /app

# Копіюємо все потрібне для Gradle
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
COPY src src

# Даємо права і збираємо звичайний JAR (не bootJar!)
RUN chmod +x gradlew
RUN ./gradlew build -x test

# Етап 2 — фінальний образ
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Копіюємо готовий JAR (звичайний, не bootJar)
COPY --from=builder /app/build/libs/java-spring-boot-ai-0.0.1-SNAPSHOT.jar app.jar

# Порт від Render
EXPOSE $PORT

# Запуск
ENTRYPOINT ["java", "-Dserver.port=${PORT}", "-jar", "app.jar"]

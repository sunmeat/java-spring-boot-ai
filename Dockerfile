# Етап 1 — збірка на Java 25
FROM eclipse-temurin:25-jdk AS builder
WORKDIR /app

# Копіюємо Gradle-файли
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Копіюємо код
COPY src src

# Даємо права на виконання та збираємо
RUN chmod +x gradlew
RUN ./gradlew build -x test --no-daemon

# Етап 2 — фінальний образ (JRE 25)
FROM eclipse-temurin:25-jre AS runtime
WORKDIR /app

# Копіюємо готовий JAR
COPY --from=builder /app/build/libs/*.jar app.jar

# Порт від Render (за замовчуванням 8080)
ENV PORT=8080
EXPOSE ${PORT}

# Запуск з динамічним портом
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT} -jar app.jar"]

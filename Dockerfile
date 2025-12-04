# ---------------------
# Build stage
# ---------------------
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml first to leverage Docker cache
COPY pom.xml ./

# Copy source code
COPY src ./src

# Build the JAR without running tests
RUN mvn clean package -DskipTests

# ---------------------
# Runtime stage
# ---------------------
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Set Spring Boot profile
ENV SPRING_PROFILES_ACTIVE=docker

# Expose port
EXPOSE 8080

# Run the application
# Run
ENTRYPOINT ["java", "-jar", "app.jar"]

# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copy pom.xml first (better cache)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Production
FROM eclipse-temurin:17-jre-alpine AS production

WORKDIR /app

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only the jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Set correct permissions
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
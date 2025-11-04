
### Multi-stage Dockerfile: build jar with Maven, then produce a small runtime image

# Stage 1: Build with Maven
## Use a published Maven image tag with Eclipse Temurin JDK
FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /build
# Copy parent pom.xml first (required for Maven multi-module builds)
COPY pom.xml ./
# Copy module sources
COPY product-service/ ./product-service/
# Install parent POM first, then build the module
RUN mvn -N install && mvn -f product-service/pom.xml -B -DskipTests package

# Stage 2: Runtime
FROM eclipse-temurin:11-jre-alpine
RUN mkdir -p /home/app
WORKDIR /home/app
ENV SPRING_PROFILES_ACTIVE=dev
# Copy the fat jar built in the previous stage (use wildcard to be robust)
COPY --from=build /build/product-service/target/*.jar product-service.jar
EXPOSE 8500
ENTRYPOINT ["java", "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}", "-jar", "product-service.jar"]



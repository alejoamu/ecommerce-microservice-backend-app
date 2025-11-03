
### Multi-stage Dockerfile: build jar with Maven, then produce a small runtime image

# Stage 1: Build with Maven
## Use a published Maven image tag (slim) that is available on Docker Hub
FROM maven:3-openjdk-11 AS build
WORKDIR /build
# copy parent POM first (needed for child modules)
COPY pom.xml ./
# copy module sources and pom
COPY product-service/ ./product-service/
# Install parent POM and build the module
RUN mvn -N install && mvn -f product-service/pom.xml -B -DskipTests package

# Stage 2: Runtime
FROM openjdk:11-jre-slim
RUN mkdir -p /home/app
WORKDIR /home/app
ENV SPRING_PROFILES_ACTIVE=dev
# Copy the fat jar built in the previous stage (use wildcard to be robust)
COPY --from=build /build/product-service/target/*.jar product-service.jar
EXPOSE 8500
ENTRYPOINT ["java", "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}", "-jar", "product-service.jar"]



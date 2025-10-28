
FROM openjdk:11
ARG PROJECT_VERSION=0.1.0
RUN mkdir -p /home/app
WORKDIR /home/app
ENV SPRING_PROFILES_ACTIVE=dev
# copy the built jar (make CI build the jar before docker build)
# use a wildcard so the exact version in the filename doesn't break the build
COPY product-service/target/*.jar product-service.jar
EXPOSE 8500
ENTRYPOINT ["java", "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}", "-jar", "product-service.jar"]



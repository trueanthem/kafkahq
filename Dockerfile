FROM openjdk:11-jdk AS build
# Install additional build requirements.
RUN apt-get update
RUN apt-get install -y build-essential
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs
# Copy src into build image.
WORKDIR /opt/akhq
COPY . .
# Build JAR using gradle.
RUN ./gradlew -x generateGitProperties --console=plain shadowJar
# Copy build output into an absolute path for next stage.
RUN cp ./build/libs/akhq-*.jar ./docker/app/akhq.jar

FROM openjdk:11-jre-slim
COPY --from=build /opt/akhq/docker /
ENV MICRONAUT_CONFIG_FILES=/app/application.yml
WORKDIR /app
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["./akhq"]

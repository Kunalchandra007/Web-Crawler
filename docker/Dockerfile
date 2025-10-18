# Dockerfile for crawler4j with compatible environment
FROM openjdk:8-jdk-alpine

# Set working directory
WORKDIR /app

# Install necessary tools
RUN apk add --no-cache \
    bash \
    curl \
    git \
    wget

# Copy project files
COPY . .

# Make gradlew executable
RUN chmod +x gradlew

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Create local.properties for Gradle
RUN echo "org.gradle.daemon=true" > local.properties && \
    echo "org.gradle.parallel=true" >> local.properties && \
    echo "org.gradle.caching=true" >> local.properties

# Build the project
RUN ./gradlew build

# Default command
CMD ["./gradlew", "test"]

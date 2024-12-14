FROM alpine:3.14
LABEL maintainer="you@example.com"

# Install JMeter
RUN apk add --no-cache openjdk11 && \
    wget https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.5.tgz && \
    tar -xzf apache-jmeter-5.5.tgz && \
    mv apache-jmeter-5.5 /jmeter

ENV JMETER_HOME=/jmeter
ENV PATH=$JMETER_HOME/bin:$PATH

WORKDIR /jmeter
ENTRYPOINT ["jmeter"]
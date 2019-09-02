FROM cptactionhank/atlassian-jira-software:8.1.0@sha256:d22a123d5b9e45fb7338db171ffbb318efb593cef9ad72c359f7e0f028797bff

FROM adoptopenjdk/openjdk8@sha256:1d003a892e52fdbc69ec6d813ae4db681439663317f098d5c1b514f1ff5480ef
LABEL \
    maintainer="Michael Kriese <michael.kriese@visualon.de>" \
    org.opencontainers.image.title="JIRA Software" \
    org.opencontainers.image.authors="Michael Kriese <michael.kriese@visualon.de>" \
    org.opencontainers.image.source="https://github.com/VisualOn/jira" \
    org.opencontainers.image.url="https://www.atlassian.com/software/jira"

# Configuration variables.
ENV JIRA_HOME     /var/atlassian/jira
ENV JIRA_INSTALL  /opt/atlassian/jira
ENV JIRA_VERSION  8.3.3
ENV MYSQL_VERSION 8.0.17
ENV POSTGRES_VERSION 42.2.6

# add java to path
ENV PATH "/opt/java/openjdk/bin:$PATH"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Install Atlassian JIRA and helper tools and setup initial home
# directory structure.
RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        xmlstarlet \
        bash \
        fontconfig \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R daemon:daemon  "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL}/conf/Catalina" \
    && curl -Ls                "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}.jar" \
    && find                    "${JIRA_INSTALL}/lib" -name "postgresql-9*" -delete \
    && curl -Ls                "https://jdbc.postgresql.org/download/postgresql-${POSTGRES_VERSION}.jar" -o "${JIRA_INSTALL}/lib/postgresql-${POSTGRES_VERSION}.jar" \
    && chmod -R 700            "${JIRA_INSTALL}/conf" \
    && chmod -R 700            "${JIRA_INSTALL}/logs" \
    && chmod -R 700            "${JIRA_INSTALL}/temp" \
    && chmod -R 700            "${JIRA_INSTALL}/work" \
    && chown -R daemon:daemon  "${JIRA_INSTALL}/conf" \
    && chown -R daemon:daemon  "${JIRA_INSTALL}/logs" \
    && chown -R daemon:daemon  "${JIRA_INSTALL}/temp" \
    && chown -R daemon:daemon  "${JIRA_INSTALL}/work" \
    && sed --in-place          "s/java version/openjdk version/g" "${JIRA_INSTALL}/bin/check-java.sh" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && touch -d "@0"           "${JIRA_INSTALL}/conf/server.xml" \
    && rm -rf                   /var/lib/apt/lists/*

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8080

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/jira", "/opt/atlassian/jira/logs"]

# Set the default working directory as the installation directory.
WORKDIR /var/atlassian/jira

COPY "docker-entrypoint.sh" "/"
ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]

ARG DOCKER_TAG
ARG SOURCE_COMMIT

LABEL \
    org.opencontainers.image.version="$DOCKER_TAG" \
    org.opencontainers.image.revision="$SOURCE_COMMIT"

FROM cptactionhank/atlassian-jira-software:8.0.1@sha256:3c54eb71308803d01f6941ad0a1a7b4a6c11710b18e6892f1be91530df1130c6

RUN set -x \
    && rm -f  ${JIRA_INSTALL}/lib/postgresql-9* \
    && rm -f  ${JIRA_INSTALL}/lib/mssql-jdbc* \
    && curl -Ls https://jira.atlassian.com/secure/attachment/342244/342244_mssql-jdbc-6.2.1.jre8.jar -o ${JIRA_INSTALL}/lib/mssql-jdbc-6.2.1.jre8.jar

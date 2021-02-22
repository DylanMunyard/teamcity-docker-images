# The list of required arguments
# ARG ubuntuImage
# ARG gitLinuxComponentVersion

# Id teamcity-server
# Tag ${versionTag}-linux${linuxVersion}-openjdk
# Tag ${latestTag}
# Tag ${versionTag}
# Platform ${linuxPlatform}
# Repo ${repo}
# Weight 1

## ${serverCommentHeader}
## This replaces Amazon Corretto JRE with OpenJDK. This is to support running on architectures that Corretto doesn't support yet, such as *ARM* architectures.

# Based on ${ubuntuImage} 0
FROM ${ubuntuImage}

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates fontconfig locales unzip openjdk-8-jre && \
    # https://github.com/goodwithtech/dockle/blob/master/CHECKPOINT.md#dkl-di-0005
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV TEAMCITY_DATA_PATH=/data/teamcity_server/datadir \
    TEAMCITY_DIST=/opt/teamcity \
    TEAMCITY_LOGS=/opt/teamcity/logs \
    CATALINA_TMPDIR=/opt/teamcity/temp \
    TEAMCITY_SERVER_MEM_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=350m" \
    LANG=C.UTF-8

EXPOSE 8111

# Install ${gitLinuxComponentName}
ARG gitLinuxComponentVersion

RUN apt-get update && \
    apt-get install -y git=${gitLinuxComponentVersion} mercurial && \
    # https://github.com/goodwithtech/dockle/blob/master/CHECKPOINT.md#dkl-di-0005
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY welcome.sh /welcome.sh
COPY run-server.sh /run-server.sh
COPY check-server-volumes.sh /services/check-server-volumes.sh
COPY run-server-services.sh /run-services.sh

RUN chmod +x /welcome.sh /run-server.sh /run-services.sh && sync && \
    groupadd -g 1000 tcuser && \
    useradd -r -u 1000 -g tcuser tcuser && \
    echo '[ ! -z "$TERM" -a -x /welcome.sh -a -x /welcome.sh ] && /welcome.sh' >> /etc/bash.bashrc && \
    sed -i -e 's/\r$//' /welcome.sh && \
    sed -i -e 's/\r$//' /run-server.sh && \
    sed -i -e 's/\r$//' /run-services.sh && \
    sed -i -e 's/\r$//' /services/check-server-volumes.sh && \
    mkdir -p $TEAMCITY_DATA_PATH $TEAMCITY_LOGS $CATALINA_TMPDIR && \
    chown -R tcuser:tcuser /services $TEAMCITY_DIST $TEAMCITY_DATA_PATH $TEAMCITY_LOGS $CATALINA_TMPDIR

COPY --chown=tcuser:tcuser TeamCity $TEAMCITY_DIST
RUN echo "docker-ubuntu" > $TEAMCITY_DIST/webapps/ROOT/WEB-INF/DistributionType.txt

USER tcuser:tcuser

VOLUME $TEAMCITY_DATA_PATH \
       $TEAMCITY_LOGS \
       $CATALINA_TMPDIR

CMD ["/run-services.sh"]
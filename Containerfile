FROM docker.io/eclipse-temurin:25-jre-alpine

ARG Serviio_Version

ENV USER=serviio
ENV UID=1001
ENV GID=1001
ENV DIR=/opt
ENV LC_ALL=fr_FR.UTF-8
ENV LANG=fr_FR.UTF-8

WORKDIR ${DIR}

RUN addgroup --gid "$GID" "$USER" && \
    adduser \
    --disabled-password \
    --gecos "" \
    --home "/opt/serviio" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

RUN apk update && apk add curl ffmpeg && \
    mkdir -v serviio \
    && curl --no-progress-meter -o serviio.tar.gz https://download.serviio.org/releases/serviio-${Serviio_Version}-linux.tar.gz \
    && tar -xzvf serviio.tar.gz -C serviio --strip-components=1 \
    && rm serviio.tar.gz \
    && chown -Rv "$USER":"$USER" serviio

EXPOSE 1900 8895 23423 23424

USER $USER
ENTRYPOINT ["/opt/serviio/bin/serviio.sh"]
ARG PARENT_CONTAINER_IMAGE_NAME="postgres:15"

FROM $PARENT_CONTAINER_IMAGE_NAME

ADD self-init-pg-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

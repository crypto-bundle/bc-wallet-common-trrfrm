ARG PARENT_CONTAINER_IMAGE_NAME="hashicorp/terraform:latest"

FROM $PARENT_CONTAINER_IMAGE_NAME

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT /usr/local/bin/entrypoint.sh

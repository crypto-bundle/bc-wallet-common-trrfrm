ARG PARENT_CONTAINER_IMAGE_NAME="hashicorp/terraform:latest"

FROM $PARENT_CONTAINER_IMAGE_NAME

COPY deploy/trrfrm/init /opt/trrfrm

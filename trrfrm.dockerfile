ARG PARENT_CONTAINER_IMAGE_NAME="hashicorp/terraform:latest"

FROM $PARENT_CONTAINER_IMAGE_NAME

ARG TRFRM_SOURCE_DIR="/opt/trrfrm/source"
ARG TF_DATA_DIR="/opt/trrfrm/work/.terraform"

ENV TRFRM_DATA_DIR=$TF_DATA_DIR
ENV TF_DATA_DIR=$TF_DATA_DIR

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

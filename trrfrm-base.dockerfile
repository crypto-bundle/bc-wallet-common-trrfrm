ARG PARENT_CONTAINER_IMAGE_NAME="hashicorp/terraform:latest"

FROM $PARENT_CONTAINER_IMAGE_NAME

ARG TRFRM_SOURCE_DIR="/opt/trrfrm/source"
ARG TRFRM_WORK_DIR="/opt/trrfrm/work"
#ARG TF_DATA_DIR="$TRFRM_WORK_DIR/.terraform"

ENV TRFRM_DATA_DIR=$TF_DATA_DIR
ENV TRFRM_WORK_DIR=$TRFRM_WORK_DIR
ENV TF_DATA_DIR="$TRFRM_WORK_DIR/.terraform"

ADD self-init-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

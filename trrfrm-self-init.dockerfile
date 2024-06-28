# PARENT_CONTAINER_IMAGE_NAME - base trrfrm container
ARG PARENT_CONTAINER_IMAGE_NAME

FROM $PARENT_CONTAINER_IMAGE_NAME

ARG TRFRM_SOURCE_DIR="/opt/trrfrm/source"
ARG TRFRM_PROJECT_NAME="bc-wallet-common-trrfrm"
ENV TRFRM_PROJECT_NAME=$TRFRM_PROJECT_NAME

COPY deploy/trrfrm/init $TRFRM_SOURCE_DIR

RUN apk --update add postgresql-client && \
    mkdir -p $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME && \
    touch $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform.lock.hcl && \
    ln -sf $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform.lock.hcl $TRFRM_SOURCE_DIR/.terraform.lock.hcl

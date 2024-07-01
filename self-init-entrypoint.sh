#!/bin/ash

#
# MIT License
#
# Copyright (c) 2024 Aleksei Kotelnikov
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of the software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions.
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# In addition, the following restrictions apply:
#
# 1. The Software and any modifications made to it may not be used for the purpose of training or improving machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the Software in an AI-training dataset is considered a breach of this License.
#
# 2. The Software may not be included in any dataset used for training or improving machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining.
#
# 3. Any person or organization found to be in violation of these restrictions will be subject to legal action and may be held liable
# for any damages resulting from such use.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

set -e

if [[ -z "${TRFRM_PROJECT_NAME}" ]]; then
  echo "missing TRFRM_PROJECT_NAME value. exit(1)"
  exit 255
fi

if [ ! -d "$TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME" ]; then
  mkdir -p "$TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME"
fi

if [[ -z "${VAULT_AUTH_TOKEN_FILE_PATH}" ]]; then
  TOKEN_FILE_PATH="/vault/secrets/token" # default value
else
  TOKEN_FILE_PATH="${VAULT_AUTH_TOKEN_FILE_PATH}"
fi

if [[ -z "${APP_LOCAL_ENV_FILE_PATH}" ]]; then
  ENV_FILE_PATH="/vault/secrets/env" # default value
else
  ENV_FILE_PATH="${APP_LOCAL_ENV_FILE_PATH}"
fi

if test -f $TOKEN_FILE_PATH; then
  export VAULT_TOKEN=$(cat $TOKEN_FILE_PATH)
fi

if test -f $ENV_FILE_PATH; then
  set -o allexport
  source $ENV_FILE_PATH
  set +o allexport
fi


if [ "$( psql -XtAc "SELECT 1 FROM pg_database WHERE datname='$PGDATABASE'" )" = '1' ]
then
    echo "Database already exists. It's OK"
else
    echo "Database does not exist..I have no permissions for create it. Please execute SQL-code"
    echo "CREATE DATABASE $PGDATABASE"
    echo "CREATE ROLE $PGUSER PASSWORD '$PGPASSWORD' NOSUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;"
    echo "ALTER DATABASE $PGDATABASE OWNER TO $PGUSER"
fi

if [[ -z "${TRFRM_WORK_DIR}" ]]; then
  export TRFRM_WORK_DIR="/opt/trrfrm/work/" # default value
fi

if [[ -z "${TRFRM_DATA_DIR}" ]]; then
  export TRFRM_DATA_DIR="$TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform" # default value
fi

export TF_DATA_DIR=$TRFRM_DATA_DIR # set same value value

if [ ! -d "$TRFRM_DATA_DIR" ]; then
  mkdir -p "$TRFRM_DATA_DIR"
fi

if [[ -z "${TRFRM_SOURCE_DIR}" ]]; then
  export TRFRM_SOURCE_DIR="/opt/trrfrm/source" # default value
fi

if [[ -z "${TRFRM_PLUGIN_CACHE_DIR}" ]]; then
  export TRFRM_PLUGIN_CACHE_DIR="$TRFRM_WORK_DIR/.terraform.d/plugin-cache" # default value
fi

if [[ -z "${TF_PLUGIN_CACHE_DIR}" ]]; then
  export TF_PLUGIN_CACHE_DIR=$TRFRM_PLUGIN_CACHE_DIR # default value
fi

if [ ! -d ${TF_PLUGIN_CACHE_DIR} ]; then
  mkdir -p "$TF_PLUGIN_CACHE_DIR"
fi


echo "/bin/terraform -chdir=$TRFRM_SOURCE_DIR" $*

echo "$TRFRM_SOURCE_DIR"
ls -la $TRFRM_SOURCE_DIR
echo "$TRFRM_WORK_DIR"
ls -la $TRFRM_WORK_DIR
echo "$TRFRM_DATA_DIR"
echo "$TF_DATA_DIR"
ls -la $TRFRM_DATA_DIR

#cp -R $TRFRM_SOURCE_DIR/. $TRFRM_WORK_DIR/

cat $ENV_FILE_PATH

echo "ENV SECRET VARS"
echo $PGPASSWORD
echo $PGUSER

mkdir -p $TRRFRM_TMP_EXECUTION_DIR
cp -R $TRFRM_SOURCE_DIR/* $TRRFRM_TMP_EXECUTION_DIR
#touch $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform.lock.hcl

if test -f $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform.lock.hcl; then
  cp $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform.lock.hcl $TRRFRM_TMP_EXECUTION_DIR/.terraform.lock.hcl
fi

#ln -sf $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform.lock.hcl $TRRFRM_TMP_EXECUTION_DIR/.terraform.lock.hcl

cat $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform.lock.hcl

echo "tree -d $TRFRM_WORK_DIR"
tree -d $TRFRM_WORK_DIR

echo "ls -la $TRRFRM_TMP_EXECUTION_DIR"
ls -la $TRRFRM_TMP_EXECUTION_DIR

/bin/terraform -chdir=$TRRFRM_TMP_EXECUTION_DIR "$@"

cp $TRRFRM_TMP_EXECUTION_DIR/.terraform.lock.hcl $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform.lock.hcl
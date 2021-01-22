#!/bin/sh
echo "Activating gcloud service account"

if [ -z "$INPUT_SERVICE_ACCOUNT_NAME" ]; then
  echo "Failed. Missing INPUT_SERVICE_ACCOUNT_NAME"
  exit 1
fi

if [ -z "$INPUT_GCLOUD_SERVICE_KEY" ]; then
  echo "Failed. Missing INPUT_GCLOUD_SERVICE_KEY"
  exit 1
fi

if ! echo $INPUT_GCLOUD_SERVICE_KEY | base64 -d > /tmp/key.json 2>/dev/null; then
  echo "Failed base64 decoding INPUT_GCLOUD_SERVICE_KEY"
  exit 1
fi

gcloud auth activate-service-account $INPUT_SERVICE_ACCOUNT_NAME --key-file=/tmp/key.json
echo "Successfully activated service account"

echo "Configuring docker to use eu.gcr.io"
gcloud auth configure-docker eu.gcr.io --quiet
echo "Successfully configured docker"

echo "Building image"
if [ -z "$INPUT_DOCKERFILE"]; then
  echo "Failed. Missing dockerfile"
  exit 1
fi

if [ -z "$INPUT_IMAGE_NAME"]; then
  echo "Failed. Missing image name"
  exit 1
fi

if [ -z "$INPUT_REGISTRY"]; then
  echo "Failed. Missing registry"
  exit 1
fi

if [ -z "$INPUT_PROJECT_ID"]; then
  echo "Failed. Missing project id"
  exit 1
fi

if [ -z "$INPUT_CONTEXT"]; then
  echo "Failed. Missing context"
  exit 1
fi

if [ -z "$INPUT_IMAGE_TAGS"]; then
  echo "Failed. Missing image tags"
  exit 1
fi

TEMP_IMAGE_NAME="$INPUT_IMAGE_NAME:temp"

if ! docker build --file $INPUT_DOCKERFILE -t $TEMP_IMAGE_NAME $INPUT_CONTEXT; then
  echo "Failed to build image"
  exit 1
fi

while IFS=',' read -ra ALL_IMAGE_TAGS; do
    for i in "${ALL_IMAGE_TAGS[@]}"; do
          IMAGE_NAME = "$INPUT_REGISTRY/$INPUT_PROJECT_ID/$INPUT_IMAGE_NAME:$IMAGE_TAG"
          echo "Pushing image $IMAGE_NAME"
          docker tag $TEMP_IMAGE_NAME $IMAGE_NAME
          if ! docker push $IMAGE_NAME; then
            echo "Failed to push image"
            exit 1
          else
            echo "Pushed image $IMAGE_NAME"
          fi
    done
done <<< "$INPUT_IMAGE_TAGS"

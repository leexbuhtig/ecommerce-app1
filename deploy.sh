#!/bin/bash

ssh -p "${SERVER_PORT}" "${SERVER_USERNAME}"@"${SERVER_HOST}" -i key.txt -t -o StrictHostKeyChecking=no << 'ENDSSH'
cd ~/ecommerce

# Load environment variables correctly
set -a
source .env
set +a

# Debugging output
echo "DOCKERHUB_USERNAME: $DOCKERHUB_USERNAME"
echo "DOCKERHUB_TOKEN: ${#DOCKERHUB_TOKEN} characters"
echo "CONTAINER_REPOSITORY: $CONTAINER_REPOSITORY"
echo "IMAGE_TAG: $IMAGE_TAG"
echo "CONTAINER_NAME: $CONTAINER_NAME"
echo "APP_PORT: $APP_PORT"

start=$(date +"%s")

# Login to Docker Hub
echo "$DOCKERHUB_TOKEN" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin

# Pull the latest image
docker pull "$CONTAINER_REPOSITORY:$IMAGE_TAG"

# Stop and remove existing container if running
if [ "$(docker ps -qa -f name=$CONTAINER_NAME)" ]; then
    echo "Container exists -> stopping and removing..."
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
    docker system prune -af
fi

# Run the new container
docker run -d --restart unless-stopped \
  -p "$APP_PORT:$APP_PORT" \
  --env-file .env \
  --name "$CONTAINER_NAME" \
  "$CONTAINER_REPOSITORY:$IMAGE_TAG"

docker ps

end=$(date +"%s")
diff=$((end - start))
echo "Deployed in: ${diff}s"

exit
ENDSSH

if [ $? -eq 0 ]; then
  echo "✅ Deployment successful."
  exit 0
else
  echo "❌ Deployment failed."
  exit 1
fi

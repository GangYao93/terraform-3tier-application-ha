#!/bin/bash
set -e

exec > >(tee -a /var/log/user-data.log) 2>&1

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting frontend setup..."

export DEBIAN_FRONTEND=noninteractive

log "Installing packages..."
apt-get update -y
apt-get install -y docker.io curl unzip ca-certificates

log "Configuring Docker..."
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

systemctl enable docker
systemctl restart docker

log "Installing AWS CLI v2..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

REGION="${region}"
DOCKER_IMAGE="${docker_image}"
BACKEND_URL="${backend_internal_url}"
CLOUDWATCH_CONFIG_NAME="${cloudwatch_config_name}"
ECR_REGISTRY=$(echo "$DOCKER_IMAGE" | cut -d/ -f1)

log "Installing CloudWatch Agent..."
curl -fsSL \
  "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb" \
  -o "/tmp/amazon-cloudwatch-agent.deb"

dpkg -i -E /tmp/amazon-cloudwatch-agent.deb
rm -f /tmp/amazon-cloudwatch-agent.deb

log "Configuring CloudWatch Agent..."
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c "ssm:$CLOUDWATCH_CONFIG_NAME"

log "Logging in to ECR..."
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

log "Pulling frontend image..."
docker pull "$DOCKER_IMAGE"

log "Starting frontend container..."
docker rm -f goal-tracker-frontend >/dev/null 2>&1 || true

docker run -d \
  --name goal-tracker-frontend \
  --restart unless-stopped \
  -p 3000:3000 \
  -e PORT=3000 \
  -e BACKEND_URL="$BACKEND_URL" \
  -e NODE_ENV=production \
  "$DOCKER_IMAGE"

sleep 10

if docker ps --format '{{.Names}}' | grep -q '^goal-tracker-frontend$'; then
  log "Frontend container is running"
else
  log "ERROR: Frontend container failed to start"
  docker logs goal-tracker-frontend || true
  exit 1
fi

log "Frontend setup completed successfully"
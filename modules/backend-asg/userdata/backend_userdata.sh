#!/bin/bash
set -e

exec > >(tee -a /var/log/user-data.log) 2>&1

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting backend setup..."

export DEBIAN_FRONTEND=noninteractive

log "Installing packages..."
apt-get update -y
apt-get install -y docker.io jq curl unzip ca-certificates

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
DB_SECRET_ARN="${db_secret_arn}"
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

log "Reading database secret..."
SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" \
  --region "$REGION" \
  --query SecretString \
  --output text)

DB_USERNAME=$(echo "$SECRET" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET" | jq -r '.password')
DB_HOST=$(echo "$SECRET" | jq -r '.host')
DB_PORT=$(echo "$SECRET" | jq -r '.port')
DB_NAME=$(echo "$SECRET" | jq -r '.dbname')

log "Pulling backend image..."
docker pull "$DOCKER_IMAGE"

log "Starting backend container..."
docker rm -f goal-tracker-backend >/dev/null 2>&1 || true

docker run -d \
  --name goal-tracker-backend \
  --restart unless-stopped \
  -p 8080:8080 \
  -e DB_USERNAME="$DB_USERNAME" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e DB_HOST="$DB_HOST" \
  -e DB_PORT="$DB_PORT" \
  -e DB_NAME="$DB_NAME" \
  -e SSL=require \
  -e PORT=8080 \
  "$DOCKER_IMAGE"

sleep 10

if docker ps --format '{{.Names}}' | grep -q '^goal-tracker-backend$'; then
  log "Backend container is running"
else
  log "ERROR: Backend container failed to start"
  docker logs goal-tracker-backend || true
  exit 1
fi

log "Backend setup completed successfully"
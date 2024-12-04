#!/bin/sh

APP_NAME=argo-local-sh
INFRA_NAME=infrastructure

print_usage() {
  echo "Usage: $0 [up|down|shutdown]"
  echo "   up          deploy application (automatically starts deployment infrastructure if needed)"
  echo "   down        tear down application"
  echo "   shutdown    tear down deployment infrastructure"
}

startup() {
  echo "Checking for deployment infrastructure..."
  helm status $INFRA_NAME > /dev/null
  if [ $? -ne 0 ]; then
    echo "Infrastructure not healthy -- redeploying..."
    helm upgrade --install $INFRA_NAME argo-local-sh-infrastructure \
      --values argo-local-sh-infrastructure/values.yaml \
      --values argo-local-sh-infrastructure/values-dev.yaml
    if ! kubectl wait -A --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server; then
      exit $?
    fi
  fi
}

is_app_running() {
  argocd app get $APP_NAME --server localhost:30080 --plaintext > /dev/null 2>&1
}

deploy() {
  startup

  if is_app_running; then
    echo "argo-local-sh is deployed"
  else
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Deploying argo-local-sh from $branch..."
    argocd app create $APP_NAME \
      --server localhost:30080 --plaintext \
      --dest-namespace argo-local-sh \
      --dest-server https://kubernetes.default.svc \
      --repo https://github.com/ewilkins-csi/argo-local-sh \
      --path argo-local-sh-deploy/src/main/resources \
      --revision $branch \
      --helm-set spec.targetRevision=$branch \
      --values values.yaml \
      --values values-dev.yaml \
      --sync-policy automated \
      --insecure
  fi
}

down() {
  if is_app_running; then
    echo "Tearing down app..."
    argocd app delete $APP_NAME --server localhost:30080 --plaintext --yes
  else
    echo "argo-local-sh is not deployed"
  fi
}

shutdown() {
  if is_app_running; then
    down
  fi

  helm status $INFRA_NAME > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Infrastructure already shutdown"
  else
    echo "Shutting down infrastructure..."
    helm uninstall $INFRA_NAME
  fi
}


if [ "$1" = "up" ]; then
  deploy
elif [ "$1" = "down" ]; then
  down
elif [ "$1" = "shutdown" ]; then
  shutdown
else
  print_usage
fi


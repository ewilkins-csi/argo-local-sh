allow_k8s_contexts('local')
docker_prune_settings(num_builds=1, keep_recent=1)

aissemble_version = '1.10.0'

build_args = { 'DOCKER_BASELINE_REPO_ID': 'ghcr.io/',
               'VERSION_AISSEMBLE': aissemble_version}

# Kafka
yaml = helm(
    'argo-local-sh-deploy/src/main/resources/apps/kafka-cluster',
    values=['argo-local-sh-deploy/src/main/resources/apps/kafka-cluster/values.yaml',
        'argo-local-sh-deploy/src/main/resources/apps/kafka-cluster/values-dev.yaml']
)
k8s_yaml(yaml)

# Add deployment resources here
k8s_kind('SparkApplication', image_json_path='{.spec.image}')

# policy-decision-point
docker_build(  
    ref='argo-local-sh-policy-decision-point-docker',
    context='argo-local-sh-docker/argo-local-sh-policy-decision-point-docker',
    build_args=build_args,
    dockerfile='argo-local-sh-docker/argo-local-sh-policy-decision-point-docker/src/main/resources/docker/Dockerfile'
)


# spark-worker-image
docker_build(  
    ref='argo-local-sh-spark-worker-docker',
    context='argo-local-sh-docker/argo-local-sh-spark-worker-docker',
    build_args=build_args,
    extra_tag='argo-local-sh-spark-worker-docker:latest',
    dockerfile='argo-local-sh-docker/argo-local-sh-spark-worker-docker/src/main/resources/docker/Dockerfile'
)

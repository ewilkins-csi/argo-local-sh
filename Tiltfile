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
yaml = helm(
   'argo-local-sh-deploy/src/main/resources/apps/spark-infrastructure',
   name='spark-infrastructure',
   values=['argo-local-sh-deploy/src/main/resources/apps/spark-infrastructure/values.yaml',
       'argo-local-sh-deploy/src/main/resources/apps/spark-infrastructure/values-dev.yaml']
)
k8s_yaml(yaml)

yaml = local('helm template oci://ghcr.io/boozallen/aissemble-spark-application-chart --version %s --values argo-local-sh-pipelines/spark-pipeline/src/main/resources/apps/spark-pipeline-base-values.yaml,argo-local-sh-pipelines/spark-pipeline/src/main/resources/apps/spark-pipeline-dev-values.yaml' % aissemble_version)
k8s_yaml(yaml)
k8s_resource('spark-pipeline', port_forwards=[port_forward(4747, 4747, 'debug')], auto_init=False, trigger_mode=TRIGGER_MODE_MANUAL)
yaml = helm(
   'argo-local-sh-deploy/src/main/resources/apps/policy-decision-point',
   name='policy-decision-point',
   values=['argo-local-sh-deploy/src/main/resources/apps/policy-decision-point/values.yaml',
       'argo-local-sh-deploy/src/main/resources/apps/policy-decision-point/values-dev.yaml']
)
k8s_yaml(yaml)
k8s_yaml('argo-local-sh-deploy/src/main/resources/apps/spark-worker-image/spark-worker-image.yaml')


yaml = helm(
   'argo-local-sh-deploy/src/main/resources/apps/spark-operator',
   name='spark-operator',
   values=['argo-local-sh-deploy/src/main/resources/apps/spark-operator/values.yaml',
       'argo-local-sh-deploy/src/main/resources/apps/spark-operator/values-dev.yaml']
)
k8s_yaml(yaml)

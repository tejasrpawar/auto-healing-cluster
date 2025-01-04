from kubernetes import config
from kubernetes.client import CoreV1Api

# Load kubeconfig from default location
config.load_kube_config()

v1 = CoreV1Api()

pods = v1.list_pod_for_all_namespaces(watch = False)
for pod in pods.items:
    print(f"Pod Name: {pod.metadata.name}, Status: {pod.status.phase}")

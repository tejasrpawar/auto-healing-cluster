from kubernetes.client.rest import ApiException

def restart_failed_pods():
    pods = v1.list_pod_for_all_namespaces(watch=False)
    for pod in pods.items:
        if pod.status.phase == "Failed":
            try:
                print(f"Pod {pod.metadata.name} is in Failed state. Restarting...")
                v1.delete_namespaced_pod(name = pod.metadata.name, namespace = pod.metadata.namespace)
            except ApiException as e:
                print(f"Exception when restarting pod: {e}")

restart_failed_pods()

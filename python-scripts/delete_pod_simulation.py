from kubernetes import client, config
import time

def delete_pod_simulation(namespace="default", app_label="nginx-deployment"):
    """
    Simulates Kubernetes auto-healing by deleting a pod with a given label.
    """
    # Load Kubernetes configuration
    config.load_kube_config()
    v1 = client.CoreV1Api()

    try:
        # Get all pods with the specified label in the namespace
        pods = v1.list_namespaced_pod(
            namespace=namespace,
            label_selector=f"app={app_label}"
        )
        if not pods.items:
            print("No pods found to delete.")
            return
        
        # Pick the first pod in the list
        pod_name = pods.items[0].metadata.name
        print(f"Deleting pod: {pod_name}")
        
        # Delete the selected pod
        v1.delete_namespaced_pod(name=pod_name, namespace=namespace)
        print(f"Pod {pod_name} deleted successfully.")
    
    except client.exceptions.ApiException as e:
        print(f"Error while deleting pod: {e}")
        return

if __name__ == "__main__":
    print("Waiting for Nginx deployment to stabilize...")
    time.sleep(60)  # Wait for pods to stabilize
    delete_pod_simulation()
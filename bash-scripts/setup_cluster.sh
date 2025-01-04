#!/bin/bash

# Start Minikube
echo "Starting Minikube..."
minikube start --driver=docker
echo "✅ Minikube started successfully."

# Deploy Prometheus
echo "Deploying Prometheus..."
helm install prometheus prometheus-community/prometheus
kubectl wait --for=condition=available --timeout=180s deployment/prometheus-server
echo "✅ Prometheus deployed."

# Deploy Grafana
echo "Deploying Grafana..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana
kubectl wait --for=condition=available --timeout=180s deployment/grafana
echo "✅ Grafana deployed."

# Get Grafana admin password
echo "Fetching Grafana admin password..."
GRAFANA_PASSWORD=$(kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
echo "Grafana admin password: $GRAFANA_PASSWORD"

# Deploy Nginx
echo "Deploying Nginx..."
kubectl apply -f k8s/nginx-deployment.yaml
kubectl expose deployment nginx-deployment --type=NodePort --port=80
kubectl wait --for=condition=available --timeout=180s deployment/nginx-deployment
echo "✅ Nginx deployed."

# Manual Pod Deletion Simulation
echo "Simulating pod deletion..."
NGINX_POD=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl delete pod $NGINX_POD
echo "✅ Pod deleted manually."

# Wait for pod to recreate
echo "Waiting for new pod to be ready..."
kubectl wait --for=condition=ready --timeout=180s pod -l app=nginx
echo "✅ New pod is ready."

# Port Forward Prometheus
echo "Port forwarding Prometheus (http://localhost:9090)..."
kubectl port-forward service/prometheus-server 9090:80 &
PROMETHEUS_PID=$!
sleep 5  # Allow time for forwarding to initialize

# Configure Grafana Data Source
echo "Configuring Grafana data source (Prometheus)..."
GRAFANA_PORT=$(kubectl get svc grafana -o jsonpath="{.spec.ports[0].nodePort}")
minikube service grafana --url &
GRAFANA_URL=http://localhost:$GRAFANA_PORT
echo "Grafana is running at $GRAFANA_URL"

# Port Forward Nginx
echo "Port forwarding Nginx (http://localhost:8080)..."
kubectl port-forward service/nginx-deployment 8080:80 &
NGINX_PID=$!
sleep 5  # Allow time for forwarding to initialize

# Display Final Info
echo "✅ All services are up and running!"
echo "Grafana URL: $GRAFANA_URL"
echo "Grafana Admin Password: $GRAFANA_PASSWORD"
echo "Nginx URL: http://localhost:8080"

# Wait for user to terminate
echo "Press Ctrl+C to terminate port forwarding."
wait $PROMETHEUS_PID $NGINX_PID
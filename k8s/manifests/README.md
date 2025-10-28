## Minikube local deployment

1. Start minikube and enable registry access:
   ```bash
   minikube start
   kubectl create namespace ecommerce || true
   ```
2. Apply core and edge components:
   ```bash
   kubectl apply -f k8s/manifests/namespace.yaml
   kubectl apply -f k8s/manifests/core/
   kubectl apply -f k8s/manifests/edge/
   ```
3. Apply services:
   ```bash
   kubectl apply -f k8s/manifests/services/
   ```
4. Access API Gateway:
   ```bash
   minikube service -n ecommerce api-gateway --url
   ```
5. Troubleshooting:
   - Check pods: `kubectl get pods -n ecommerce`
   - View logs: `kubectl logs -n ecommerce deploy/api-gateway`
   - Ensure services can reach `service-discovery` and `cloud-config` by DNS.


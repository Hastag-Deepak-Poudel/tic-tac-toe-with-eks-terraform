KUBERNETES SETUP


DELETE ALL CLUSTER so that there is no conflict between clusters
START FRESH 

1. kind create cluster --config config.yaml

2. kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

this is a ingress controller that is installed in out cluster


3. kubectl logs -n ingress-nginx deploy/ingress-nginx-controller -f
check if the ingress-nginx is working and run http://localhost/ in different terminal


4. kubectl get ingress 

5. kubectl get pods -n ingress-nginx
check if ingress-nginx pod is working



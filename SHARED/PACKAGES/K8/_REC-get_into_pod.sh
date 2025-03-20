test "$1" = '' && ID=0 || ID=$1

NS=$(kubectl get rec -o jsonpath='{.items[].metadata.namespace}')
POD=$(kubectl get pods -n $NS -o jsonpath="{.items[$ID].metadata.name}")
echo "kubectl exec --stdin --tty $POD -- /bin/bash"
kubectl exec --stdin --tty $POD -- /bin/bash
test "$1" = '' && echo "Execution is: ./_REC-install <NAMESPACE> <VERSION-BUNDLE-FOLDER>";
test "$1" = '' && exit 1;
test "$2" = '' && echo "Execution is: ./_REC-install <NAMESPACE> <VERSION-BUNDLE-FOLDER>";
test "$2" = '' && exit 1;

#echo " . . . create ./REC-$1-delete.sh"
#cat <<EOF | tee ./REC-$1-delete.sh
#kubectl delete namespace $1 &&\
#while [ \$(kubectl get namespaces|grep "^$1 *Terminating"|wc -l) -lt 1 ] ; do kubectl get namespaces; sleep 20; done
#EOF

echo " [+] create ./$1-REC.yaml"
cat <<EOF | tee ./$1-REC.yaml
apiVersion: "app.redislabs.com/v1"
kind: "RedisEnterpriseCluster"
metadata:
  name: $1-rec
spec:
  nodes: 3
  redisEnterpriseNodeResources:
    limits:
        cpu: 2000m
        memory: 3Gi
    requests:
        cpu: 2000m
        memory: 3Gi
  persistentSpec:
    enabled: false
    #storageClassName: "standard"
    #volumeSize: "23Gi” #optional
EOF
echo " . . . "

echo " [+] Running: kubectl create namespace $1 || exit" && \
kubectl create namespace $1 || exit && \

echo " [+] Running: kubectl config set-context --current --namespace=$1" && \
kubectl config set-context --current --namespace=$1 && \

echo " [+] Running: kubectl label namespaces $1 namespace-name=$1 --overwrite=true" && \
kubectl label namespaces $1 namespace-name=$1 --overwrite=true && \

echo " [+] Running: kubectl apply -f ./$2/bundle.yaml" && \
kubectl apply -f ./$2/bundle.yaml && \
echo " [+] Waiting for redis-enterprise-operator to get ready ..." && \
while [ $(kubectl get deployment|grep "^redis-enterprise-operator *1/1 *1 *1"|wc -l) -lt 1 ] ; do kubectl get deployment; sleep 5; done; kubectl get deployment && \

echo " [+] Running: kubectl apply -f ./$1-REC.yaml" && \
kubectl apply -f ./$1-REC.yaml && \
echo " [+] Waiting for a first REC pod to get ready ..." && \
while [ $(kubectl get pods|grep "rec-0 *2/2 *Running"|wc -l) -lt 1 ] ; do kubectl get pods -o wide; sleep 20; done; kubectl get pods -o wide && \
echo " [+] First pod $1-rec0 is ready. Switching to kubectl rollout status sts/$1-rec ..." && \
echo " [+] Waiting for $1-rec cluster to get ready ..." && \
kubectl rollout status sts/$1-rec && kubectl get pods -o wide && \

echo " [+] Waiting for admission-tls secret to get ready ..." && \
while [ $(kubectl get secret admission-tls|grep "^admission-tls *Opaque *2"|wc -l) -lt 1 ] ; do kubectl get secret admission-tls; sleep 5; done && \

# save cert
CERT=$(kubectl get secret admission-tls -o jsonpath='{.data.cert}') && \
echo " [+] Applying admission/webhook.yaml" && \
sed "s/namespace:.*/namespace: $1/g"           ./$2/admission/webhook.yaml | kubectl create -f - && \
echo " [+] 10 seconds sleep for admission/webhook.yaml being ready..." && \
sleep 10 && \

# create patch file
cat <<EOF | tee ./$1-REC-modified-webhook.yaml
webhooks:
- name: redisenterprise.admission.redislabs
  clientConfig:
    caBundle: $CERT
  admissionReviewVersions: ["v1beta1"]
  namespaceSelector:
    matchLabels:
      namespace-name: $1
EOF
# patch webhook with caBundle
echo " [+] Patch webhook with certificate $CERT and $1" && \
kubectl patch ValidatingWebhookConfiguration redis-enterprise-admission --patch "$(cat $1-REC-modified-webhook.yaml)" && \
echo " [+] 30 seconds sleep for all configs being settled ..." && \
sleep 30

ReJSON_version=$(kubectl describe rec -n $1 $1-rec|grep -A 2 ReJSON|tail -1|tr -d ' ')
search_version=$(kubectl describe rec -n $1 $1-rec|grep -A 2 search|tail -1|tr -d ' ')

cat <<EOF | tee ./$1-enterprise-database.yaml
apiVersion: app.redislabs.com/v1alpha1
kind: RedisEnterpriseDatabase
metadata:
  name: $1-enterprise-database
spec:
  memorySize: 100MB
  tlsMode: enabled
  redisEnterpriseCluster:
    name: $1-rec
  databasePort: 10001
  replication: true
  memorySize: 250MB
  modulesList:
    - name: search
      version: $search_version
      #config:
    - name: ReJSON
      version: $ReJSON_version
EOF

echo " [+] Running: kubectl apply -f ./$1-enterprise-database.yaml" && \
kubectl apply -f ./$1-enterprise-database.yaml

cat <<EOF | tee ./$1-ingress-ui.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $1-rec-ui-ingress
  namespace: $1
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: $1-rec-ui.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: $1-rec-ui
                port:
                  number: 8443
EOF

echo " [+] Running: kubectl apply -f ./$1-ingress-ui.yaml" && \
kubectl apply -f ./$1-ingress-ui.yaml

cat <<EOF | tee ./$1-ingress-rest.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $1-rec-rest-ingress
  namespace: $1
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: $1-rec-rest.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: $1-rec
                port:
                  number: 9443
EOF

echo " [+] Running: kubectl apply -f ./$1-ingress-rest.yaml" && \
kubectl apply -f ./$1-ingress-rest.yaml

cat <<EOF | tee ./$1-ingress_$1-enterprise-database.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $1-rec-$1-enterprise-database-ingress
  namespace: $1
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: $1-rec-$1-enterprise-database.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: $1-enterprise-database
                port:
                  number: 10001
EOF

echo " [+] Running: kubectl apply -f ./$1-ingress_$1-enterprise-database.yaml" && \
kubectl apply -f ./$1-ingress_$1-enterprise-database.yaml

echo "Done"




REC_USERNAME_SECRET=$(kubectl get secret $1-rec -o jsonpath='{.data.username}')
REC_PASSWORD_SECRET=$(kubectl get secret $1-rec -o jsonpath='{.data.password}')

REC_USERNAME_TEXT=$(echo $REC_USERNAME_SECRET | base64 --decode)
REC_PASSWORD_TEXT=$(echo $REC_PASSWORD_SECRET | base64 --decode)

echo "User name: $REC_USERNAME_TEXT"
echo "User password: $REC_PASSWORD_TEXT"

echo "User name: $REC_USERNAME_TEXT" > $1-CREDS_TEXT.txt
echo "User password: $REC_PASSWORD_TEXT" >> $1-CREDS_TEXT.txt

DB_SECRET=$(kubectl get redb $1-enterprise-database -o jsonpath="{.spec.databaseSecretName}")
DB_PASSWORD_TEXT=$(kubectl get secret $DB_SECRET -o jsonpath="{.data.password}" | base64 --decode)

echo "DB password: $DB_PASSWORD_TEXT"

echo "DB password: $DB_PASSWORD_TEXT" >> $1-CREDS_TEXT.txt


kubectl exec -it $1-rec-0 -c redis-enterprise-node -- cat /etc/opt/redislabs/proxy_cert.pem > ./$1-proxy_cert.pem
echo "openssl s_client -connect $1-rec-$1-enterprise-database.example.com:443 -crlf -CAfile ./$1-proxy_cert.pem  -servername $1-rec-$1-enterprise-database.example.com" > $1-DB-access.sh
#echo -en 'AUTH xxx xxx\r\ndbsize\r\n' | timeout 3 openssl s_client -connect http://wfnrgcomm01p.wfn-rec-prod1-osp-crdb.us.caas.oneadp.com:443 -servername wfnrgcomm01p.wfn-rec-prod1-osp-crdb.us.caas.oneadp.com -quiet 2>/dev/null | sed -n 's/^:[0-9]*/HEALTH-OK/p'
echo "#AUTH $DB_PASSWORD_TEXT" >> $1-DB-access.sh
cat $1-DB-access.sh

echo $(kubectl get secret $DB_SECRET -o jsonpath="{.data.port}" | base64 --decode)


#[root@rc1-rh8-cp K8]# kubectl apply -f redis-enterprise-k8s-docs-7.4.2-12/crds/reaadb_crd.yaml
#customresourcedefinition.apiextensions.k8s.io/redisenterpriseactiveactivedatabases.app.redislabs.com configured
#[root@rc1-rh8-cp K8]# kubectl apply -f redis-enterprise-k8s-docs-7.4.2-12/crds/rerc_crd.yaml
#customresourcedefinition.apiextensions.k8s.io/redisenterpriseremoteclusters.app.redislabs.com unchanged
#[root@rc1-rh8-cp K8]#



cat <<EOF | tee ./$1-rec-AA-secret.yaml
apiVersion: v1
data:
  password: $REC_PASSWORD_SECRET
  username: $REC_USERNAME_SECRET
kind: Secret
metadata:
  name: rec-$1-aa-secret
type: Opaque
EOF

cat <<EOF | tee ./$1-rec-AA-rerc.yaml
apiVersion: app.redislabs.com/v1alpha1
kind: RedisEnterpriseRemoteCluster
metadata:
  name: rerc-k8-80
spec:
  recName: rec-k8-80
  recNamespace: k8-90
  apiFqdnUrl: k8-80-rec-rest.example.com
  dbFqdnSuffix: -db-k8-80-rec.example.com
  secretName: rec-$1-aa-secret
EOF
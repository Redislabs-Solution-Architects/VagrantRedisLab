test "$1" = '' && echo "Execution is: ./_REC-uninstall <NAMESPACE> <VERSION-BUNDLE-FOLDER>";
test "$1" = '' && exit 1;
test "$2" = '' && echo "Execution is: ./_REC-uninstall <NAMESPACE> <VERSION-BUNDLE-FOLDER>";
test "$2" = '' && exit 1;

echo " [+] Delete REDBs if any..." && \
for i in $(kubectl get redb -n $1 -o=jsonpath='{range .items[*]}{.metadata.name}{" "}{end}' 2>/dev/null); do kubectl delete redb -n $1 $i; done && \

echo " [+] Delete ValidatingWebhookConfiguration if any..." && \
for i in $(kubectl get ValidatingWebhookConfiguration redis-enterprise-admission -o jsonpath="{.metadata.name}" 2>/dev/null); do kubectl delete ValidatingWebhookConfiguration $i; done && \

echo " [+] Delete REC if any..." && \
for i in $(kubectl get rec -n $1 -o=jsonpath='{range .items[*]}{.metadata.name}' 2>/dev/null); do kubectl delete rec -n $1 $i; done && \

echo " [+] Delete cm operator-environment-config if any..." && \
for i in $(kubectl get cm operator-environment-config -o jsonpath="{.metadata.name}" 2>/dev/null); do kubectl delete cm $i; done && \

echo " [+] Delete BUNDLE" && \
kubectl delete -f ./$2/bundle.yaml || echo " [-] Looks like already deleted..."

echo " [+] Delete namespace if any..." && \
for i in $(kubectl get namespace $1 -o jsonpath="{.metadata.name}" 2>/dev/null); do kubectl delete namespace $i; done
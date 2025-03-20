test "$1" = '' && echo "Execution is: $0 <NAMESPACE>"
test "$1" = '' && exit 1;


kubectl get namespace $1 -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/$1/finalize -f -

# gogs-openshift

```
$ oc login

$ oc new-project gogs

$ oc create -f gogs-sa.yml

$ oc create -f pv.yml

$ oc create -f pvc.yml

$ oc adm policy add-scc-to-user privileged system:serviceaccount:gogs:gogs

$ oc create -f gogs-mysql-template.yml 

$ oc new-app --template=gogs-mysql-template -p APPLICATION_DOMAIN=2886795278-80-simba07.environments.katacoda.com

```

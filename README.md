# rancher-k8s

## init docker node (Ubuntu)

```
curl -Lso - https://github.com/kesslerdev/rancher-k8s/archive/master.tar.gz | tar xvzf - \
    && rancher-k8s-master/scripts/docker.sh
```

## init rancher master (Ubuntu)

```
curl -Lso - https://github.com/kesslerdev/rancher-k8s/archive/master.tar.gz | tar xvzf - \
    && rancher-k8s-master/scripts/docker.sh \
    && rancher-k8s-master/scripts/rancher-ssl.sh
```

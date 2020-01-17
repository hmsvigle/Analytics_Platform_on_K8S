## Documentation

Below is a brief overview of operating the elasticsearch Helm Chart and some specific implementation details. For additional information, please see
 https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html

## Requirements

* [Helm](https://helm.sh/) >= 2.8.0 (see parent [README](../README.md) for more details)
* Kubernetes >= 1.8
* Minimum cluster requirements include the following to run this chart with default settings. All of these settings are configurable.
  * Three Kubernetes nodes to respect the default "hard" affinity settings
  * 1GB of RAM for the JVM heap

## Usage notes and getting started

# Installing

* Install it
  ```
  helm install --name ccp-elastic ./ --namespace=default
  ```

## Current Version of ElasticSearch

Elasticsearch-Version | 7.4.1

While only the latest releases are tested, it is possible to easily install old or new releases by overriding the `imageTag`. To install version `7.
4.1` of Elasticsearch it would look like this:

## Deploy Elasticsearch

```
helm install --name ccp-elastic ./ --namespace=default
```

```shell
himansu@cloudshell:~/$ kubectl get sts,deploy,po,svc
```

```
NAME                                    READY   AGE
statefulset.apps/elasticsearch-master   1/1     1h

NAME                                            READY   STATUS      RESTARTS   AGE
pod/elasticsearch-master-0                      1/1     Running     0          1h

NAME                                    TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)              AGE
service/elasticsearch-master            ClusterIP      10.116.0.47     <none>          9200/TCP,9300/TCP    1h
service/elasticsearch-master-headless   ClusterIP      None            <none>          9200/TCP,9300/TCP    1h
service/elasticsearch-master-lb         LoadBalancer   10.116.3.194    35.242.197.11   9200:30428/TCP       1h
```

## Test-Cases

* Create Index & Load Data

```
curl -X PUT "<elastic_endpoint>/test-index?pretty"
```

* create Index & Load json file to elasticsearch

```
wget -O accounts.json https://raw.githubusercontent.com/elastic/elasticsearch/master/docs/src/test/resources/accounts.json
curl -s -H "Content-Type: application/json" -XPOST <elastic_endpoint>/accounts/docs/_bulk --data-binary "@accounts.json"
```

* extract all the indeces

```
curl -X GET "<elastic_endpoint>/_all?pretty"
```

* extract any specific index

```
curl -X GET "<elastic_endpoint>/accounts?pretty"
```

* Bulk Operations

```
cat input01
{ "index" : { "_index" : "kv01", "_id" : "011" } }
{ "Key011" : "value011" }
{ "create" : { "_index" : "test", "_id" : "013" } }
{ "field1" : "value3" }
{ "update" : {"_id" : "011", "_index" : "kv01"} }
{ "doc" : {"field2" : "value2"} }
```

```
curl -s -H "Content-Type: application/x-ndjson" -XPOST <elastic_endpoint>/_bulk --data-binary "@input01";
```

```
curl -X GET "35.242.197.11:9200/kv01?pretty"

```


## Configuration

| Parameter                     | Description                                                                                                                                                                                                                                                                                                                | Default                                                                                                                   |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `clusterName`                 | This will be used as the Elasticsearch [cluster.name](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.name.html) and should be unique per cluster in the namespace                                                                                                                                 | `elasticsearch`                                                                                                           |
| `nodeGroup`                   | This is the name that will be used for each group of nodes in the cluster. The name will be `clusterName-nodeGroup-X`                                                                                                                                                                                                      | `master`                                                                                                                  |
| `masterService`               | Optional. The service name used to connect to the masters. You only need to set this if your master `nodeGroup` is set to something other than `master`. See [Clustering and Node Discovery](#clustering-and-node-discovery) for more information.                                                                         | ``                                                                                                                        |
| `roles`                       | A hash map with the [specific roles](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html) for the node group                                                                                                                                                                                 | `master: true`<br>`data: true`<br>`ingest: true`                                                                          |
| `replicas`                    | Kubernetes replica count for the statefulset (i.e. how many pods)                                                                                                                                                                                                                                                          | `3`                                                                                                                       |
| `minimumMasterNodes`          | The value for [discovery.zen.minimum_master_nodes](https://www.elastic.co/guide/en/elasticsearch/reference/6.7/discovery-settings.html#minimum_master_nodes). Should be set to `(master_eligible_nodes / 2) + 1`. Ignored in Elasticsearch versions >= 7.                                                                  | `2`                                                                                                                       |
| `esMajorVersion`              | Used to set major version specific configuration. If you are using a custom image and not running the default Elasticsearch version you will need to set this to the version you are running (e.g. `esMajorVersion: 6`)                                                                                                    | `""`                                                                                                                      |
| `esConfig`                    | Allows you to add any config files in `/usr/share/elasticsearch/config/` such as `elasticsearch.yml` and `log4j2.properties`. See [values.yaml](./values.yaml) for an example of the formatting.                                                                                                                           | `{}`                                                                                                                      |
| `extraEnvs`                   | Extra [environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/#using-environment-variables-inside-of-your-config) which will be appended to the `env:` definition for the container                                                                         | `[]`                                                                                                                      |
| `extraVolumes`                | Templatable string of additional volumes to be passed to the `tpl` function                                                                                                                                                                                                                                                | `""`                                                                                                                      |
| `extraVolumeMounts`           | Templatable string of additional volumeMounts to be passed to the `tpl` function                                                                                                                                                                                                                                           | `""`                                                                                                                      |
| `extraInitContainers`         | Templatable string of additional init containers to be passed to the `tpl` function                                                                                                                                                                                                                                        | `""`                                                                                                                      |
| `secretMounts`                | Allows you easily mount a secret as a file inside the statefulset. Useful for mounting certificates and other secrets. See [values.yaml](./values.yaml) for an example                                                                                                                                                     | `[]`                                                                                                                      |
| `image`                       | The Elasticsearch docker image                                                                                                                                                                                                                                                                                             | `docker.elastic.co/elasticsearch/elasticsearch`                                                                           |
| `imageTag`                    | The Elasticsearch docker image tag                                                                                                                                                                                                                                                                                         | `7.4.1`                                                                                                                   |
| `imagePullPolicy`             | The Kubernetes [imagePullPolicy](https://kubernetes.io/docs/concepts/containers/images/#updating-images) value                                                                                                                                                                                                             | `IfNotPresent`                                                                                                            |
| `podAnnotations`              | Configurable [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) applied to all Elasticsearch pods                                                                                                                                                                               | `{}`                                                                                                                      |
| `labels`                      | Configurable [label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) applied to all Elasticsearch pods                                                                                                                                                                                          | `{}`                                                                                                                      |
| `esJavaOpts`                  | [Java options](https://www.elastic.co/guide/en/elasticsearch/reference/current/jvm-options.html) for Elasticsearch. This is where you should configure the [jvm heap size](https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html)                                                                 | `-Xmx1g -Xms1g`                                                                                                           |
| `resources`                   | Allows you to set the [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for the statefulset                                                                                                                                                                               | `requests.cpu: 100m`<br>`requests.memory: 2Gi`<br>`limits.cpu: 1000m`<br>`limits.memory: 2Gi`                             |
| `initResources`               | Allows you to set the [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for the initContainer in the statefulset                                                                                                                                                          | {}                                                                                                                        |
| `sidecarResources`            | Allows you to set the [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for the sidecar containers in the statefulset                                                                                                                                                     | {}                                                                                                                        |
| `networkHost`                 | Value for the [network.host Elasticsearch setting](https://www.elastic.co/guide/en/elasticsearch/reference/current/network.host.html)                                                                                                                                                                                      | `0.0.0.0`                                                                                                                 |
| `volumeClaimTemplate`         | Configuration for the [volumeClaimTemplate for statefulsets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-storage). You will want to adjust the storage (default `30Gi`) and the `storageClassName` if you are using a different storage class                                            | `accessModes: [ "ReadWriteOnce" ]`<br>`resources.requests.storage: 30Gi`                                                  |
| `persistence.annotations`     | Additional persistence annotations for the `volumeClaimTemplate`                                                                                                                                                                                                                                                           | `{}`                                                                                                                      |
| `persistence.enabled`         | Enables a persistent volume for Elasticsearch data. Can be disabled for nodes that only have [roles](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html) which don't require persistent data.                                                                                               | `true`                                                                                                                    |
| `priorityClassName`           | The [name of the PriorityClass](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass). No default is supplied as the PriorityClass must be created first.                                                                                                                              | `""`                                                                                                                      |
| `antiAffinityTopologyKey`     | The [anti-affinity topology key](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity). By default this will prevent multiple Elasticsearch nodes from running on the same Kubernetes node                                                                                        | `kubernetes.io/hostname`                                                                                                  |
| `antiAffinity`                | Setting this to hard enforces the [anti-affinity rules](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity). If it is set to soft it will be done "best effort". Other values will be ignored.                                                                                  | `hard`                                                                                                                    |
| `nodeAffinity`                | Value for the [node affinity settings](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#node-affinity-beta-feature)                                                                                                                                                                                      | `{}`                                                                                                                      |
| `podManagementPolicy`         | By default Kubernetes [deploys statefulsets serially](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies). This deploys them in parallel so that they can discover eachother                                                                                                   | `Parallel`                                                                                                                |
| `protocol`                    | The protocol that will be used for the readinessProbe. Change this to `https` if you have `xpack.security.http.ssl.enabled` set                                                                                                                                                                                            | `http`                                                                                                                    |
| `httpPort`                    | The http port that Kubernetes will use for the healthchecks and the service. If you change this you will also need to set [http.port](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-http.html#_settings) in `extraEnvs`                                                                          | `9200`                                                                                                                    |
| `transportPort`               | The transport port that Kubernetes will use for the service. If you change this you will also need to set [transport port configuration](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-transport.html#_transport_settings) in `extraEnvs`                                                        | `9300`                                                                                                                    |                     
| `service.labels`              | Labels to be added to non-headless service                                                                                                                                                                                                                                                                                 | `{}`                                                                                                                      |
| `service.labelsHeadless`      | Labels to be added to headless service                                                                                                                                                                                                                                                                                     | `{}`                                                                                                                      |
| `service.type`                | Type of elasticsearch service. [Service Types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)                                                                                                                                                                         | `ClusterIP`                                                                                                               |
| `service.nodePort`            | Custom [nodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) port that can be set if you are using `service.type: nodePort`.                                                                                                                                                               | ``                                                                                                                        |
| `service.annotations`         | Annotations that Kubernetes will use for the service. This will configure load balancer if `service.type` is `LoadBalancer` [Annotations](https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws)                                                                                             | `{}`                                                                                                                      |
| `service.httpPortName`        | The name of the http port within the service                                                                                                                                                                                                                                                                               | `http`                                                                                                                    |
| `service.transportPortName`   | The name of the transport port within the service                                                                                                                                                                                                                                                                          | `transport`                                                                                                               |
| `updateStrategy`              | The [updateStrategy](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets) for the statefulset. By default Kubernetes will wait for the cluster to be green after upgrading each pod. Setting this to `OnDelete` will allow you to manually delete each pod during upgrades | `RollingUpdate`                                                                                                           |
| `maxUnavailable`              | The [maxUnavailable](https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget) value for the pod disruption budget. By default this will prevent Kubernetes from having more than 1 unhealthy pod in the node group                                                                | `1`                                                                                                                       |
| `fsGroup (DEPRECATED)`        | The Group ID (GID) for [securityContext.fsGroup](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) so that the Elasticsearch user can read from the persistent volume                                                                                                                            | ``                                                                                                                        |
| `podSecurityContext`          | Allows you to set the [securityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) for the pod                                                                                                                                                         | `fsGroup: 1000`<br>`runAsUser: 1000`                                                                                      |
| `securityContext`             | Allows you to set the [securityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) for the container                                                                                                                                             | `capabilities.drop:[ALL]`<br>`runAsNonRoot: true`<br>`runAsUser: 1000`                                                    |
| `terminationGracePeriod`      | The [terminationGracePeriod](https://kubernetes.io/docs/concepts/workloads/pods/pod/#termination-of-pods) in seconds used when trying to stop the pod                                                                                                                                                                      | `120`                                                                                                                     |
| `sysctlInitContainer.enabled` | Allows you to disable the sysctlInitContainer if you are setting vm.max_map_count with another method                                                                                                                                                                                                                      | `true`                                                                                                                    |
| `sysctlVmMaxMapCount`         | Sets the [sysctl vm.max_map_count](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html#vm-max-map-count) needed for Elasticsearch                                                                                                                                                        | `262144`                                                                                                                  |
| `readinessProbe`              | Configuration fields for the [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                                                                                                                                                                               | `failureThreshold: 3`<br>`initialDelaySeconds: 10`<br>`periodSeconds: 10`<br>`successThreshold: 3`<br>`timeoutSeconds: 5` |
| `clusterHealthCheckParams`    | The [Elasticsearch cluster health status params](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html#request-params) that will be used by readinessProbe command                                                                                                                           | `wait_for_status=green&timeout=1s`                                                                                        |
| `imagePullSecrets`            | Configuration for [imagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-pod-that-uses-your-secret) so that you can use a private registry for your image                                                                                                       | `[]`                                                                                                                      |
| `nodeSelector`                | Configurable [nodeSelector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) so that you can target specific nodes for your Elasticsearch cluster                                                                                                                                          | `{}`                                                                                                                      |
| `tolerations`                 | Configurable [tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)                                                                                                                                                                                                                        | `[]`                                                                                                                      |
| `ingress`                     | Configurable [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to expose the Elasticsearch service. See [`values.yaml`](./values.yaml) for an example                                                                                                                                            | `enabled: false`                                                                                                          |
| `schedulerName`               | Name of the [alternate scheduler](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/#specify-schedulers-for-pods)                                                                                                                                                                          | `nil`                                                                                                                     |
| `masterTerminationFix`        | A workaround needed for Elasticsearch < 7.2 to prevent master status being lost during restarts [#63](https://github.com/elastic/helm-charts/issues/63)                                                                                                                                                                    | `false`                                                                                                                   |
| `lifecycle`                   | Allows you to add lifecycle configuration. See [values.yaml](./values.yaml) for an example of the formatting.                                                                                                                                                                                                              | `{}`                                                                                                                      |
| `keystore`                    | Allows you map Kubernetes secrets into the keystore. See the [config example](/elasticsearch/examples/config/values.yaml) and [how to use the keystore](#how-to-use-the-keystore)                                                                                                                                          | `[]`                                                                                                                      |
| `rbac`                    | Configuration for creating a role, role binding and service account as part of this helm chart with `create: true`. Also can be used to reference an external service account with `serviceAccountName: "externalServiceAccountName"`.                                                                                             | `create: false`<br>`serviceAccountName: ""`                       |
| `podSecurityPolicy`       | Configuration for create a pod security policy with minimal permissions to run this Helm chart with `create: true`. Also can be used to reference an external pod security policy with `name: "externalPodSecurityPolicy"`                                                                                                         | `create: false`<br>`name: ""`                                     |

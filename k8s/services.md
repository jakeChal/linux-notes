# Services

Services provide an abstract way to expose an application running on a set of pods as a network service.

As old pods are removed or new ones are created, their IP addresses change. So how can a consumer know how to connect to our service? If we have hundreds of services communicating with each other, it is not feasible to manually update their configuration every time something happens to a pod.

Enter Services: Services provide a stable endpoint for accessing the service, as well as a method to load-balance requests across the replicas.

```
                    Service
              ┌─────────────────┐
              │ stable address  │
              │ stable DNS name │
              └────────┬────────┘
                       │
              selector: app=microbot
                       │
             ┌─────────┼─────────┐
             ▼         ▼         ▼
           Pod A     Pod B     Pod C
```

## Service Types
```
ClusterIP
    │
    └── inside cluster


NodePort
    │
    └── outside → Node IP:port → Service


LoadBalancer
    │
    └── outside → Load Balancer → Service
```

### ClusterIP vs NodePort
- `NodePort`  
    Scenario: you are on a machine that is NOT in the cluster and you want to reach 
    a service of the cluster. You can reach it by `ANY_CLUSTER_NODE_IP:NODE_PORT`
    - To get cluster node IPs: 
        ```
        k get nodes -o wide
        ```
    - To set a node port (that forward to e.g. port 80), you need a NodePort service:
        ```
        k expose deploy microbot --type NodePort --port 80 --name microbot-nodeport
        ```
    - To get the node ports:
        ```
        k get service -o wide
        ```

- `ClusterIP`  
    Scenario: You want the pods within a cluster to automagically reach each other (either by IP - e.g. `POD_IP:FORWARDED_PORT` or by domain - e.g. `SERVICE_WITH_CLUSTER_IP:FORWARDED_PORT`)
    - To set a ClusterIP (that forward to e.g. port 80), you need a ClusterIP service:
        ```
        k expose deploy microbot --type ClusterIP --port 80 --name microbot-service
        ```
    - To test this is working fine, you can either:
        - Check the pod IPs with `k get pods -o wide` and then `curl http://POD_IP:FORWARDED_PORT`
        - Create a one-off pod with `k run curl --rm -it --image=curlimages/curl -- sh` and from within that pod: `curl http://microbot-service`


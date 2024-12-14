# jmeter-load-testing

This repo used for auto scaling JMeter Agents with Kubernetes

### **1. Framework Requirements**

* **Core Features**:
  * Automate the setup and teardown of JMeter agents.
  * Distribute load across multiple JMeter instances.
  * Monitor test progress and aggregate results.
  * Scalability using Kubernetes (K8s) for orchestration.
* **Key Components**:
  * JMeter Master: Coordinates test execution.
  * JMeter Agents: Run test scripts.
  * Result Aggregator: Collects and analyzes results.

### **2. Prerequisites**

* Install [Docker](https://www.docker.com).
* Set up a Kubernetes cluster ([Minikube]() for local testing or a cloud provider like GKE, AKS, or EKS).
* Install [kubectl]() and [Helm](https://helm.sh/).
* Install JMeter locally for testing scripts.

### **3. Create JMeter Docker Images**

```
docker build -t your-repo/jmeter:latest .
docker push your-repo/jmeter:latest
```

### **4. Deploy Resources to Kubernetes**

**Apply Configurations**:

```
kubectl apply -f jmeter-master-deployment.yaml
kubectl apply -f jmeter-agent-deployment.yaml

```

**Verify Deployments**:

```
kubectl get pods
kubectl get services
```

### **5. Collect and Aggregate Results**

* Use Kubernetes logs to fetch results:

  ```kubectl
  kubectl logs <master-pod-name>

  ```

### **6. Monitor and Scale**

* Use Kubernetes Horizontal Pod Autoscaler (HPA) to scale agents based on CPU usage:

```
kubectl autoscale deployment jmeter-agent --cpu-percent=50 --min=1 --max=10

```

### **7. Framework Structure**

Organize the project:

```
jmeter-load-testing/
├── Dockerfile
├── kubernetes/
│   ├── jmeter-master-deployment.yaml
│   ├── jmeter-agent-deployment.yaml
│   └── configmap.yaml
├── helm-chart/
└── tests/
    ├── test.jmx
    ├── test-data.csv

```

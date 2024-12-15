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
* Set up a Kubernetes cluster ([Minikube](https://k8s-docs.netlify.app/en/docs/tasks/tools/install-minikube/)) for local testing or a cloud provider like GKE, AKS, or EKS).
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/) and [Helm](https://helm.sh/docs/intro/install/).
* Install JMeter locally for testing scripts.

### **3. Create JMeter Docker Images**

```
docker build -t your-repo/jmeter:latest .
docker push your-repo/jmeter:latest
```

### **4. Run Kubectl Context**

copy your `./kubernetes/.kube/config` to `~/.kube/config` file

Run the context

```
 kubectl config use-context prod-cluster
```

Verify the ccurrent context

<pre class="!overflow-visible"><div class="contain-inline-size rounded-md border-[0.5px] border-token-border-medium relative bg-token-sidebar-surface-primary dark:bg-gray-950"><div class="overflow-y-auto p-4" dir="ltr"><code class="!whitespace-pre hljs language-bash">kubectl config current-context
</code></div></div></pre>

List All contexts

```
kubectl config get-contexts

```

Restart your `kubectl` proxy (if applicable):

```
kubectl proxy --port=8080

```

Run before any other step

```
in powershell run as a administrator
 minikube start --driver=hyperv
```

### **5. Deploy Resources to Kubernetes**

Validate yaml manually

```
kubectl apply --dry-run=client --validate=true -f jmeter-agent-deployment.yaml

```

**Apply Configurations**:

```
kubectl create namespace jmeter-ns

kubectl apply -f jmeter-agent-deployment.yaml
kubectl apply -f jmeter-master-deployment.yaml

kubectl apply -f jmeter-agent-service.yaml

```

**Verify Deployments**:

kubectl get pods

```
NAME                             READY   STATUS              RESTARTS   AGE
jmeter-agent-84bcbcb4f-7zzqf     0/1     ContainerCreating   0          4s
jmeter-agent-84bcbcb4f-cj6tp     0/1     ContainerCreating   0          4s
jmeter-agent-84bcbcb4f-ptlbd     0/1     ContainerCreating   0          4s
jmeter-master-57b5c764d9-hn4wc   0/1     ContainerCreating   0          52s
```

kubectl get services

```
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   15m
```

### **6. Run the test**

Configure test parameters

```
kubectl exec -it jmeter-master -n jmeter-ns -- jmeter -n -t /tests/HTTPSignInSignOffPlan.jmx -Jusers=50 -Jduration=300 -R jmeter-agent-0, jmeter-agent-1, jmeter-agent-2
```

Run the test

```
kubectl logs -f deployment/jmeter-master -n jmeter

```

### **7. Collect and Aggregate Results**

* Use Kubernetes logs to fetch results:

  ```kubectl
  kubectl cp jmeter/jmeter-master:/test/test-results.jtl ./test-results.jtl

  ```

Cleanup

```
kubectl delete namespace jmeter-ns

```

### **8. Monitor and Scale**

* Use Kubernetes Horizontal Pod Autoscaler (HPA) to scale agents based on CPU usage:

```
kubectl autoscale deployment jmeter-agent --cpu-percent=50 --min=1 --max=10

```

### **9. Framework Structure**

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

# **More trouble shooting techniques **

## **couldn’t get current server API group list: Get “http://localhost:8080/api?timeout=32s”: dial tcp 127.0.0.1:8080: connect: connection refused **

###### ChatGPT said:

The error message indicates that a client application, likely `kubectl`, is trying to access the Kubernetes API server at `http://localhost:8080`, but the connection is being refused. This is typically caused by the API server not running, being configured incorrectly, or the client not being able to reach it. Here’s how to troubleshoot and resolve the issue:

---

### 1. **Check Kubernetes Context and Configuration**

* Run the following to inspect the current configuration:
* Ensure the `current-context` points to the correct cluster.
* To change the context, use:

---

### 2. **Verify Kubernetes API Server is Running**

* If you are running Kubernetes locally (e.g., via `minikube` or `kind`), ensure the cluster is started:
  * **Minikube:**

    If it’s not running, start it:
  * **Kind:**

    If no clusters are listed, create one:

---

### 3. **Inspect API Server Endpoint**

* The default API server address is unlikely to be `http://localhost:8080` unless you're running a local proxy (e.g., `kubectl proxy`).
* Check the correct endpoint in the kubeconfig:

  Look for the `server` entry under the current context, which should point to the correct API server URL.

---

### 4. **Start `kubectl proxy` if Needed**

* If you need to connect through `http://localhost:8080`, you might need to run `kubectl proxy`:
* This will forward requests from `localhost:8080` to the API server.

---

### 5. **Check Network Connectivity**

* Ensure the client can reach the API server's actual endpoint.
* Test the connection using:
* Replace `<API_SERVER_ENDPOINT>` with the actual API server URL (e.g., `https://<your-cluster-endpoint>`).

---

### 6. **Restart Kubernetes Components**

* If running Kubernetes locally, restarting components may help:
* If running on a managed cluster, verify the API server status with your cloud provider.

---

### 7. **Check for Firewall/Proxy Issues**

* If you’re on a corporate network, ensure there are no firewalls or proxies blocking access to the API server.

### 8. **Troubleshoot for Minikube**

```
$minikube start
* minikube v1.34.0 on Microsoft Windows 11 Home 10.0.22631.4602 Build 22631.4602
* Unable to pick a default driver. Here is what was considered, in preference order:
  - docker: Not healthy: "docker version --format {{.Server.Os}}-{{.Server.Version}}:{{.Server.Platform.Name}}" exit status 1: error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.47/version": open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
  - docker: Suggestion:  <https://minikube.sigs.k8s.io/docs/drivers/docker/>
  - hyperv: Not healthy: Hyper-V requires Administrator privileges
  - hyperv: Suggestion: Right-click the PowerShell icon and select Run as Administrator to open PowerShell in elevated mode. <>
* Alternatively you could install one of these drivers:
  - virtualbox: Not installed: unable to find VBoxManage in $PATH
  - qemu2: Not installed: exec: "qemu-system-x86_64": executable file not found in %PATH%
  - podman: Not installed: exec: "podman": executable file not found in %PATH%

https://www.virtualbox.org/wiki/Downloads

https://www.qemu.org/download/

https://www.msys2.org/

https://podman.io/docs/installation

$kubectl get nodes
E1215 09:39:19.938225   20516 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp [::1]:8080: connectex: No connection could be made because the target machine actively refused it.
https://discuss.kubernetes.io/t/couldnt-get-current-server-api-group-list-get-http-localhost-8080-api-timeout-32s-dial-tcp-127-0-0-1-connect-connection-refused/25471

Resolve by
KUBECONFIG=$HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

if this still doesnt resolve. then,
All you need is to remove containerd service and reinstall it again


Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows

. : File C:\Users\srinivas\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 cannot be loaded
because running scripts is disabled on this system. For more information, see about_Execution_Policies at
https:/go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:3
+ . 'C:\Users\srinivas\OneDrive\Documents\WindowsPowerShell\Microsoft.P ...
+   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4#msi


powershell run as a administrator
 minikube start --driver=hyperv
```

## **E1215 10:18:45.156194   14160 status.go:263] The "minikube" host does not exist!**

ChatGPT said:

The error indicates that Minikube is not able to find a cluster named `minikube`. This usually happens when no Minikube cluster has been created or the configuration is corrupted.

Here’s how to troubleshoot and resolve the issue:

---

### 1. **Verify Existing Minikube Clusters**

* Check if there are any existing Minikube clusters:
* If the list is empty or the `minikube` profile is missing, you need to create a new cluster.

---

### 2. **Create a New Minikube Cluster**

* Start a new Minikube cluster:
* Specify a profile name if needed:

---

### 3. **Delete and Recreate the Cluster**

* If there was an incomplete or corrupted setup, delete the existing configuration:
* Then, create a new cluster:

---

### 4. **Check Virtualization**

* Ensure your system supports virtualization, as Minikube often uses virtual machines.
* Verify virtualization is enabled:
  * **Linux:**
  * **Windows (PowerShell):**
  * **macOS:** Virtualization is enabled by default on modern Macs.
* If virtualization is not supported, you can use the `--driver` flag with alternatives like Docker:

---

### 5. **Check the Minikube Driver**

* Confirm the driver being used is properly installed and configured:
* Supported drivers include:
  * `docker`
  * `virtualbox`
  * `hyperkit`
  * `none` (bare metal)
* If needed, explicitly specify a driver:

---

### 6. **Inspect Logs**

* If issues persist, check Minikube logs for details:

---

### 7. **Reset Minikube**

* If your Minikube setup is corrupted, reset Minikube entirely:
* After resetting, recreate the cluster:

---

Let me know if you encounter any issues during these steps!

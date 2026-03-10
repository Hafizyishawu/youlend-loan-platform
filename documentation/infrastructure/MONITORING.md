# Observability & Monitoring

Complete monitoring stack for YouLend Loan Management Platform using Prometheus, Grafana, and Loki.

## Stack Overview

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Loki**: Centralized logging
- **Promtail**: Log collection agent
- **AlertManager**: Alert routing and management

## Installation

### Prerequisites

- EKS cluster running
- Helm 3.x installed
- kubectl configured

### 1. Create Monitoring Namespace

```bash
kubectl create namespace monitoring
```

### 2. Install Prometheus Stack

```bash
# Add Prometheus community Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack (includes Prometheus + Grafana)
helm install prometheus prometheus-community/kube-prometheus-stack \
  -f prometheus-values.yaml \
  -n monitoring \
  --create-namespace
```

### 3. Install Loki Stack

```bash
# Add Grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Loki stack (includes Loki + Promtail)
helm install loki grafana/loki-stack \
  -f loki-values.yaml \
  -n monitoring
```

### 4. Deploy ServiceMonitors

```bash
kubectl apply -f servicemonitor-backend.yaml
kubectl apply -f servicemonitor-frontend.yaml
```

## Accessing Dashboards

### Grafana

**Port-forward (local access):**
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Then access: http://localhost:3000

**Default credentials:**
- Username: `admin`
- Password: `CHANGE_ME_SECURE_PASSWORD` (change this!)

**Via Ingress:**
```bash
# Get Grafana URL
kubectl get ingress -n monitoring
```

Access: http://grafana.youlend.example.com

### Prometheus

**Port-forward:**
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Access: http://localhost:9090

### AlertManager

**Port-forward:**
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

Access: http://localhost:9093

## Pre-configured Dashboards

Grafana comes with 3 pre-configured dashboards:

### 1. Backend API Dashboard (ID: 12231)
- Request rate
- Error rate (5xx)
- Latency (p50, p95, p99)
- Active connections
- Memory usage
- CPU usage

### 2. Kubernetes Cluster Dashboard (ID: 7249)
- Node status
- Pod status by namespace
- CPU usage by namespace
- Memory usage by namespace
- Network I/O
- Disk I/O

### 3. Node Exporter Dashboard (ID: 1860)
- CPU utilization
- Memory utilization
- Disk I/O
- Network traffic
- System load

## Metrics Available

### Backend API Metrics

The backend exposes Prometheus metrics at `/metrics`:

**HTTP Metrics:**
- `http_requests_total` - Total HTTP requests
- `http_request_duration_seconds` - Request latency histogram
- `http_requests_in_progress` - Current in-flight requests

**Process Metrics:**
- `process_cpu_seconds_total` - CPU time
- `process_working_set_bytes` - Memory usage
- `process_open_fds` - Open file descriptors

**Custom Metrics:**
- `loans_created_total` - Total loans created
- `loans_deleted_total` - Total loans deleted
- `active_loans` - Current active loans

### Kubernetes Metrics

Automatically collected by kube-state-metrics:

- Pod status and restarts
- Deployment status
- Node metrics
- Resource requests and limits
- PersistentVolume usage

## Alerts

### Critical Alerts

**BackendDown:**
- **Condition**: Backend service unavailable for > 1 minute
- **Action**: Immediate investigation required

**BackendHighErrorRate:**
- **Condition**: 5xx error rate > 5% for 5 minutes
- **Action**: Check logs, investigate issues

**FrontendDown:**
- **Condition**: Frontend service unavailable for > 1 minute
- **Action**: Immediate investigation required

### Warning Alerts

**BackendHighLatency:**
- **Condition**: p95 latency > 1 second for 5 minutes
- **Action**: Investigate performance, check resources

**HighMemoryUsage:**
- **Condition**: Memory usage > 80% for 10 minutes
- **Action**: Consider scaling or investigating memory leaks

**PodCrashLooping:**
- **Condition**: Pod restarting frequently
- **Action**: Check logs, fix application issues

## Querying Metrics

### Prometheus Queries

**Backend request rate:**
```promql
rate(http_requests_total{job="backend"}[5m])
```

**Backend error rate:**
```promql
rate(http_requests_total{job="backend",status=~"5.."}[5m])
```

**Backend p95 latency:**
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job="backend"}[5m]))
```

**Pod CPU usage:**
```promql
sum(rate(container_cpu_usage_seconds_total{namespace="youlend"}[5m])) by (pod)
```

**Pod memory usage:**
```promql
sum(container_memory_usage_bytes{namespace="youlend"}) by (pod)
```

## Querying Logs

### LogQL Queries (Loki)

**All backend logs:**
```logql
{namespace="youlend", app="backend"}
```

**Error logs only:**
```logql
{namespace="youlend", app="backend"} |= "error" or "Error" or "ERROR"
```

**Logs with specific message:**
```logql
{namespace="youlend"} |= "LoanController"
```

**Rate of errors:**
```logql
rate({namespace="youlend"} |= "error" [5m])
```

## Alert Configuration

### Slack Integration

Edit `prometheus-values.yaml`:

```yaml
alertmanager:
  config:
    receivers:
      - name: 'slack'
        slack_configs:
          - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
            channel: '#alerts'
            title: '{{ .GroupLabels.alertname }}'
            text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

### Email Integration

```yaml
alertmanager:
  config:
    receivers:
      - name: 'email'
        email_configs:
          - to: 'alerts@youlend.com'
            from: 'prometheus@youlend.com'
            smarthost: 'smtp.gmail.com:587'
            auth_username: 'prometheus@youlend.com'
            auth_password: 'your-password'
```

## Retention Policies

### Prometheus
- **Retention**: 7 days
- **Storage**: 10Gi PersistentVolume
- **Compaction**: Automatic

### Loki
- **Retention**: 7 days (168h)
- **Storage**: 10Gi PersistentVolume
- **Cleanup**: Automatic

### Grafana
- **Dashboard history**: Enabled
- **Storage**: 5Gi PersistentVolume

## Performance Tuning

### Prometheus

**For high-volume metrics:**
```yaml
prometheus:
  prometheusSpec:
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 1000m
        memory: 2Gi
    retention: 15d
    storageSpec:
      volumeClaimTemplate:
        spec:
          resources:
            requests:
              storage: 50Gi
```

### Loki

**For high log volume:**
```yaml
loki:
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
  persistence:
    size: 50Gi
```

## Troubleshooting

### Prometheus not scraping targets

**Check ServiceMonitor:**
```bash
kubectl get servicemonitor -n youlend
kubectl describe servicemonitor backend -n youlend
```

**Check Prometheus targets:**
1. Port-forward to Prometheus
2. Go to Status → Targets
3. Check if targets are UP

**Common issues:**
- Service selector doesn't match pods
- Metrics endpoint not exposed
- Network policies blocking scraping

### Grafana shows no data

**Check data source:**
1. Configuration → Data Sources
2. Test Prometheus connection
3. Verify URL is correct

**Check queries:**
1. Open dashboard
2. Edit panel
3. Test query in Explore

### Logs not appearing in Loki

**Check Promtail:**
```bash
kubectl logs -n monitoring -l app=promtail
```

**Check Loki:**
```bash
kubectl logs -n monitoring -l app=loki
```

**Common issues:**
- Promtail can't reach Loki
- Log path incorrect
- Permissions issue

## Maintenance

### Update Prometheus Stack

```bash
helm repo update
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  -f prometheus-values.yaml \
  -n monitoring
```

### Update Loki Stack

```bash
helm repo update
helm upgrade loki grafana/loki-stack \
  -f loki-values.yaml \
  -n monitoring
```

### Backup Grafana Dashboards

```bash
# Export all dashboards
kubectl exec -n monitoring prometheus-grafana-xxx -- \
  grafana-cli admin export-dashboards /tmp/dashboards

# Copy to local
kubectl cp monitoring/prometheus-grafana-xxx:/tmp/dashboards ./dashboards-backup
```

### Clean Up Old Metrics

Prometheus automatically removes old data based on retention policy. To manually compact:

```bash
kubectl exec -n monitoring prometheus-kube-prometheus-prometheus-0 -- \
  promtool tsdb analyze /prometheus
```

## Cost Optimization

**Development:**
```yaml
# Reduce replicas
prometheus:
  prometheusSpec:
    replicas: 1

# Reduce storage
storageSpec:
  volumeClaimTemplate:
    spec:
      resources:
        requests:
          storage: 5Gi

# Shorter retention
retention: 3d
```

**Production:**
```yaml
# High availability
prometheus:
  prometheusSpec:
    replicas: 2

# More storage
storageSpec:
  volumeClaimTemplate:
    spec:
      resources:
        requests:
          storage: 50Gi

# Longer retention
retention: 30d
```

## Next Steps

1. Configure alert receivers (Slack, email)
2. Create custom dashboards for business metrics
3. Set up log aggregation for application logs
4. Configure recording rules for expensive queries
5. Implement distributed tracing (Tempo/Jaeger)

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- [LogQL Cheat Sheet](https://grafana.com/docs/loki/latest/logql/)

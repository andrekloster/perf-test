# docker-prometheus-grafana

- Edit Prometheus node-exporter target IPs in `prometheus/prometheus.yaml`

```shell
docker compose up -d
```

Optional: Change Grafana admin password in `grafana/env`

Open Grafana in browser via <http://localhost:3000>

## Grafana dashboards

- <https://grafana.com/grafana/dashboards/1860-node-exporter-full/>
- <https://grafana.com/grafana/dashboards/12693-haproxy-2-full/>
- <https://grafana.com/grafana/dashboards/14621-mysql-mariadb-workload/>

## HAProxy Prometheus metrics

- <https://www.haproxy.com/documentation/haproxy-configuration-tutorials/alerts-and-monitoring/prometheus/>

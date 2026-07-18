# Cloud-Native Pipeline

A small but complete example of taking a Spring Boot service from local development all the way to a Kubernetes deployment on AWS. I built this to work through the pieces that usually get hand-waved in tutorials — real container builds, Terraform for the infrastructure, health probes, autoscaling, and a monitoring stack you can actually look at.

The application itself is deliberately boring: a CRUD API for users backed by Postgres, with Redis in front for caching. The interesting part is everything around it.

## What's in here

- **`api/`** — Spring Boot 3 / Java 17 REST API. Exposes `/api/users` and a set of Actuator endpoints (health, Prometheus metrics).
- **`docker-compose.yml`** — the whole stack for local dev: API, Postgres, Redis, Prometheus, and Grafana.
- **`k8s/`** — Kubernetes manifests, split by component (api, postgres, redis, monitoring). Includes an HPA and an ingress.
- **`terraform/`** — the AWS side: VPC, EKS cluster, and an ECR repository.
- **`.github/workflows/ci-cd.yml`** — the pipeline. Runs tests on every push, then builds and deploys when it has credentials to do so (more on that below).

## Running it locally

You don't need any of the cloud stuff to try it out. With Docker installed:

```bash
docker compose up --build
```

That gets you:

- API on http://localhost:8080 (`/actuator/health` to check it's up)
- Prometheus on http://localhost:9090
- Grafana on http://localhost:3000 (login `admin` / `admin123`)

A quick smoke test once it's running:

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Ada","email":"ada@example.com"}'

curl http://localhost:8080/api/users
```

## The CI/CD pipeline

The GitHub Actions workflow has three stages: **test**, **build & push**, and **deploy**.

Tests run on every push and pull request — that part needs nothing but the repo. The build and deploy stages only kick in when AWS credentials are present. The workflow checks for those secrets first and, if they're missing, it skips the cloud stages instead of failing them. So the pipeline stays green whether or not there's a live AWS account behind it.

To turn the deploy path on, set these repository secrets:

| Secret | What it's for |
| --- | --- |
| `AWS_ROLE_ARN` | IAM role the workflow assumes via OIDC |
| `ECR_REGISTRY` | your ECR registry URL |
| `EKS_CLUSTER_NAME` | the cluster to deploy into |

The region is set directly in the workflow (`us-east-1`) — change it there if your infrastructure lives elsewhere.

## Provisioning the AWS infrastructure

The Terraform in `terraform/` stands up the VPC, EKS cluster, and ECR repo:

```bash
cd terraform
terraform init
terraform apply
```

Heads up: EKS is not free. The control plane alone runs around $73/month and starts billing the moment the cluster exists, so if you're just poking at this, tear it down when you're done:

```bash
terraform destroy
```

## Notes

- The Kubernetes deployments use readiness and liveness probes wired to the Actuator health endpoint, so rollouts wait for pods to actually be healthy.
- The HPA scales the API on CPU. Nothing exotic, but it's there and working.
- Prometheus scrapes the API's metrics endpoint; Grafana is pre-pointed at Prometheus as a datasource.
- Database schema is managed by Hibernate (`ddl-auto: update`) to keep the example simple — I'd swap that for Flyway or Liquibase in anything real.

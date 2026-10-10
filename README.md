# Ejercicio Semana 09 — Orquestador multinube con Terraform

Orquestador de infraestructura que replica la **misma estructura** en distintas nubes:

- **32 máquinas virtuales** (por defecto 8 `web` + 8 `api` + 8 `worker` + 8 `data`)
- **Kubernetes** gestionado (EKS en AWS, GKE en GCP)
- **Contenedores**: cada VM y cada pod corre la misma imagen Docker

Además hay un entorno `local-docker` que crea las 32 "VMs" como contenedores, para probar sin gastar en la nube.

## Estructura

```
.
├── app/                         # Servicio contenedorizado (Python, sin dependencias)
├── docker-compose.yml           # Prueba rápida: 32 réplicas con --scale
├── k8s/
│   ├── base/                    # Deployment, Service, HPA, PDB, ConfigMap
│   └── overlays/{aws,gcp,local} # Ajustes por nube (LoadBalancer NLB/NEG, kind)
├── terraform/
│   ├── templates/               # cloud-init común (instala Docker y corre la app)
│   ├── modules/
│   │   ├── aws-network  aws-vm-fleet  aws-eks
│   │   ├── gcp-network  gcp-vm-fleet  gcp-gke
│   │   └── docker-vm-fleet
│   └── environments/
│       ├── aws/                 # VPC + 32 EC2 + EKS   (tests/ con mocks)
│       ├── gcp/                 # VPC + 32 GCE + GKE   (tests/ con mocks)
│       └── local-docker/        # 32 contenedores Docker
├── scripts/test-local.sh        # Prueba de punta a punta con Docker
└── .github/workflows/ci.yml     # Pipeline de pruebas
```

La cantidad de VMs se controla con `vm_groups` (mapa rol → cantidad). Los módulos lo expanden a nombres estables (`web-01` … `data-08`) y reparten las VMs entre zonas.

## Uso

### Local con Docker (sin nube)

Requisitos: Docker y Terraform ≥ 1.7.

```bash
bash scripts/test-local.sh          # crea, verifica y destruye las 32 VMs
KEEP=1 bash scripts/test-local.sh   # las deja corriendo
```

Alternativa sin Terraform: `docker compose up -d --build --scale vm=32`.

### AWS

```bash
cd terraform/environments/aws
cp terraform.tfvars.example terraform.tfvars   # ajustar valores
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --name semana09-dev
kubectl apply -k ../../../k8s/overlays/aws
```

### GCP

```bash
cd terraform/environments/gcp
cp terraform.tfvars.example terraform.tfvars   # poner project_id
terraform init && terraform apply
gcloud container clusters get-credentials semana09-dev --region us-central1
kubectl apply -k ../../../k8s/overlays/gcp
```

> ⚠️ 32 VMs + un clúster Kubernetes generan costos. Usa `terraform destroy` al terminar.

## Pruebas

| Prueba | Dónde | Qué comprueba |
|---|---|---|
| Unitarias de la app | `app/test_app.py` | Endpoints `/`, `/healthz`, 404 |
| Contenedor | CI, job `app` | La imagen construye y responde |
| `terraform validate` + `fmt` | CI, job `terraform` | Sintaxis de los 3 entornos |
| `terraform test` con mocks | `environments/{aws,gcp}/tests` | El plan crea 32 VMs y el clúster, sin credenciales |
| Flota en Docker | `scripts/test-local.sh` | `terraform apply` real: 32 contenedores sanos respondiendo |
| Kubernetes | CI, job `kubernetes` (kind) | Despliegue real del overlay local y validación de los overlays AWS/GCP contra el API server |

En cada push a `main`, la imagen se publica en `ghcr.io/thiagoicochea/ejerciciosemana09cloud`, que es la que usan por defecto las VMs y los overlays de nube.

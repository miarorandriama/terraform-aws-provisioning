# 🚀 Infrastructure AWS as Code avec Terraform & LocalStack

## 📌 Vue d'ensemble

Ce projet démontre la conception et le déploiement d'une infrastructure AWS **modulaire** et **scalable** avec **Terraform** et **LocalStack**. Il fournit un environnement de développement local complet qui reproduit les configurations de production, permettant de valider le réseau, l'IAM et la sécurité avant tout déploiement réel sur AWS.

## 🏗️ Architecture

L'infrastructure est entièrement modulaire et inclut :

- **VPC** — Réseau virtuel isolé avec segmentation de sous-réseaux
- **Subnets** — Sous-réseau public (accès internet) et privé (isolé)
- **Internet Gateway** — Configuration du routage pour l'accès web
- **Instance EC2** — Serveur web dans le sous-réseau privé avec rôle IAM
- **Rôle IAM + Instance Profile** — Permissions EC2 limitées à l'accès S3
- **Security Groups** — Règles firewall autorisant SSH (22), HTTP (80), HTTPS (443)
- **Buckets S3** — Stockage des données applicatives + bucket pour l'état Terraform distant

## 📁 Structure du projet

```
AWS_TF/
├── Keys/                          # Credentials AWS
└── Terraform/
    ├── main.tf                   # Module racine — connecte tous les modules
    ├── variables.tf              # Définitions des variables
    ├── terraform.tfvars          # Valeurs des variables
    ├── providers.tf              # Configuration des providers
    ├── outputs.tf                # Valeurs de sortie
    ├── validate_infra.sh         # Script de validation historique
    └── modules/
        ├── vpc/                  # Module VPC
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── ec2/                  # Module EC2 (avec rôle IAM et instance profile)
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── s3/                   # Module S3
            ├── main.tf
            ├── outputs.tf
            └── variables.tf

scripts/
├── 001_test_vpc.sh               # Audit réseau : VPC, subnets, internet gateway
├── 002_test_s3.sh                # Audit conformité S3 (versioning, chiffrement, tags)
├── 003_test_ec2.sh               # Audit conformité EC2 (IAM, security groups, tags)
└── 004_test_integration_ec2_s3.sh # Test d'intégration : transfert de fichier EC2 ↔ S3
```

## 🛠️ Bonnes pratiques DevOps

- **Infrastructure as Code (IaC)** — Infrastructure complète en fichiers Terraform versionnés
- **Modularité** — Séparation logique des ressources (VPC, EC2, S3) pour une réutilisabilité maximale
- **Tagging dynamique** — Gestion centralisée des tags avec `merge()` pour le suivi des coûts
- **Gestion stricte des variables** — Séparation propre entre définitions et valeurs
- **IAM Least Privilege** — Rôle EC2 limité à l'accès S3 uniquement
- **Gestion des dépendances** — Chaîne `depends_on` explicite garantissant que la policy IAM est attachée avant que l'instance profile soit utilisé
- **Tests de conformité automatisés** — Scripts shell auditant l'état de l'infrastructure après chaque déploiement
- **Simulation cloud locale** — LocalStack élimine les coûts de développement

## 📋 Prérequis

- Docker & Docker Desktop
- Terraform >= 1.10.5
- AWS CLI v2
- `jq` (requis par les scripts de test)
- Connaissances de base AWS et Terraform

## 🚀 Installation & Déploiement

### Étape 1 — Lancer LocalStack

> ⚠️ **Important :** Depuis 2026, `localstack/localstack:latest` est en réalité la version **Pro** et nécessite une licence payante (quitte avec le code 55). Toujours utiliser une version gratuite épinglée :

```powershell
docker run -d --name localstack `
  -p 4566:4566 `
  -p 4510-4559:4510-4559 `
  -e IAM_SOFT_MODE=1 `
  localstack/localstack:3.8.0
```

### Étape 2 — Configurer les credentials AWS

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

### Étape 3 — Initialiser Terraform

```bash
cd Terraform
terraform init
```

### Étape 4 — Vérifier le plan

```bash
terraform plan
```

### Étape 5 — Déployer

```bash
terraform apply -auto-approve
```

## 🧪 Tests & Validation

Après un `terraform apply` réussi, lancer les scripts d'audit dans l'ordre :

```bash
# 1. Audit réseau — VPC, sous-réseaux, internet gateway
bash scripts/001_test_vpc.sh

# 2. Audit conformité S3 — versioning, chiffrement, blocage accès public, tags
bash scripts/002_test_s3.sh

# 3. Audit conformité EC2 — profil IAM, security groups, tags
bash scripts/003_test_ec2.sh

# 4. Test d'intégration — simulation de transfert de fichier EC2 ↔ S3
bash scripts/004_test_integration_ec2_s3.sh
```

Chaque script affiche les résultats avec code couleur : `[OK]` / `[CONFORME]` en vert, les erreurs en rouge.

## 🔍 Vérification manuelle

```bash
# Lister les VPCs
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs --output table

# Lister les instances EC2
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,Tags:Tags}" \
  --output table

# Lister les instance profiles IAM
aws --endpoint-url=http://localhost:4566 iam list-instance-profiles --output table

# Lister les buckets S3
aws --endpoint-url=http://localhost:4566 s3 ls
```

## 🧹 Nettoyage

```bash
terraform destroy -auto-approve
docker stop localstack && docker rm localstack
```

## 💡 Dépannage & Leçons apprises

| Problème | Cause racine | Solution |
|---|---|---|
| EC2 ne trouve pas l'instance profile | `aws_iam_instance_profile` créé avant la fin de `aws_iam_role_policy_attachment` | Ajout de `depends_on = [aws_iam_role_policy_attachment.the_s3_access]` sur l'instance profile |
| `depends_on` et `time_sleep` ne règlent pas l'erreur | LocalStack Pro applique une validation IAM stricte — le profil existe mais le rôle n'a pas encore de policy | Corriger la chaîne de dépendances ET utiliser l'image gratuite |
| LocalStack quitte avec exit code 55 | `localstack:latest` est en réalité la version Pro depuis 2026 — nécessite un token de licence | Utiliser `localstack/localstack:3.8.0` avec `-e IAM_SOFT_MODE=1` |
| Erreurs segfault AWS CLI | Auth par profil non supportée dans LocalStack | Utiliser `--endpoint-url=http://localhost:4566` sur chaque commande |
| Portée des variables dans les modules | Variables non transmises entre modules | Utiliser les outputs de modules comme inputs dans `main.tf` racine |
| Conflits de state file | State local en environnement d'équipe | Utiliser un backend S3 distant en production |

## 📚 Fichiers clés

| Fichier | Rôle |
|---|---|
| `main.tf` | Module racine — connecte tous les sous-modules |
| `variables.tf` | Définitions des variables d'entrée |
| `outputs.tf` | Valeurs de sortie de l'infrastructure |
| `modules/ec2/main.tf` | Instance EC2 + rôle IAM + instance profile + security group |
| `modules/vpc/main.tf` | VPC, subnets, internet gateway, tables de routage |
| `modules/s3/main.tf` | Bucket S3 avec versioning et chiffrement |
| `scripts/001_test_vpc.sh` | Audit VPC/subnets/IGW |
| `scripts/002_test_s3.sh` | Vérifications conformité S3 |
| `scripts/003_test_ec2.sh` | Audit EC2/IAM/SG |
| `scripts/004_test_integration_ec2_s3.sh` | Test d'intégration EC2↔S3 bout en bout |

## 🤝 Contribuer

Les contributions sont les bienvenues. Merci de s'assurer que :

1. Tous les fichiers Terraform sont formatés avec `terraform fmt`
2. `terraform validate` passe sans erreur avant de commiter
3. Les 4 scripts de test sont exécutés et affichent des résultats verts avant d'ouvrir une PR
4. La documentation est mise à jour pour toute nouvelle ressource ou variable

## 📝 Licence

Ce projet est fourni tel quel à des fins éducatives et de développement.

---

**Dernière mise à jour :** Juin 2026

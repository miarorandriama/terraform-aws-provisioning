# 🚀 Infrastructure AWS as Code avec Terraform & LocalStack

## 📌 Présentation du Projet

Ce projet démontre la conception et le déploiement d'une infrastructure cloud AWS **modulaire** et **scalable** utilisant **Terraform** et **LocalStack**. Il fournit un environnement de développement local complet et isolé qui reproduit les configurations de production, permettant de valider les configurations réseau et de sécurité avant tout déploiement réel sur AWS.

## 🏗️ Architecture

L'infrastructure est entièrement modulaire et inclut :

### Composants
- **VPC :** Réseau virtuel isolé avec segmentation par sous-réseaux
- **Sous-réseaux :** Sous-réseau public (accès Internet) et sous-réseau privé (isolé)
- **Internet Gateway :** Configuration du routage pour l'accès web
- **Instances EC2 :** Serveurs web provisionné dans le sous-réseau privé
- **Groupes de Sécurité :** Pare-feu autorisant SSH (22), HTTP (80) et HTTPS (443)

## 📁 Structure du Projet

```
AWS_TF/
├── Keys/                          # Identifiants AWS
└── Terraform/
    ├── main.tf                   # Configuration du module racine
    ├── variables.tf              # Définitions des variables
    ├── terraform.tfvars          # Valeurs des variables
    ├── providers.tf              # Configuration du fournisseur
    ├── outputs.tf                # Valeurs de sortie
    ├── terraform.tfstate         # Fichier d'état (local)
    └── modules/
        ├── vpc/                  # Module VPC (réutilisable)
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── ec2/                  # Module EC2 (réutilisable)
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```

## 🛠️ Bonnes Pratiques DevOps Implémentées

- **Infrastructure as Code (IaC) :** Infrastructure complète définie dans des fichiers Terraform versionnés
- **Modularité :** Séparation logique des ressources (VPC, EC2) pour une réutilisabilité maximale
- **Tagging Dynamique :** Gestion centralisée des étiquettes avec la fonction `merge()` pour le suivi des coûts et la FinOps
- **Gestion Stricte des Variables :** Séparation claire entre les définitions de variables et leurs valeurs
- **Simulation Cloud Locale :** LocalStack élimine les coûts de développement tout en reproduisant les services AWS
- **Sécurité :** Groupes de sécurité avec règles d'entrée précises (SSH, HTTP, HTTPS) et accès de sortie complet

## 📋 Prérequis

- Docker & Docker Desktop (pour LocalStack)
- Terraform >= 1.10.5
- AWS CLI v2
- Connaissance basique d'AWS et Terraform

## 🚀 Installation et Déploiement

### Étape 1 : Lancer LocalStack

```bash
docker run -d -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
```

### Étape 2 : Configurer les Identifiants AWS

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

### Étape 3 : Initialiser Terraform

```bash
cd Terraform
terraform init
```

### Étape 4 : Vérifier le Plan de l'Infrastructure

```bash
terraform plan
```

### Étape 5 : Déployer l'Infrastructure

```bash
terraform apply -auto-approve
```

## 🔍 Vérification et Validation

Après le déploiement, vérifiez les ressources créées dans LocalStack :

```bash
# Lister tous les VPC
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs --output table

# Lister les instances EC2 avec leurs étiquettes
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --query "Reservations[*].Instances[*].{ID:InstanceId, Type:InstanceType, Tags:Tags}" \
  --output table

# Décrire les groupes de sécurité
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups --output table
```

## 🧹 Nettoyage

Pour détruire toutes les ressources et arrêter LocalStack :

```bash
terraform destroy -auto-approve
docker stop $(docker ps -q --filter "ancestor=localstack/localstack")
```

## 💡 Dépannage et Leçons Apprises

| Problème | Solution |
|---------|----------|
| Erreurs de segfault AWS CLI | Utiliser le paramètre `--endpoint-url` pour les appels directs au lieu de l'authentification par profil |
| Portée des variables dans les modules | Implémenter le passage approprié des variables entre modules via les sorties et entrées |
| Problèmes de connectivité LocalStack | S'assurer que le conteneur Docker est en cours d'exécution et que les ports 4566 et 4510-4559 sont accessibles |
| Conflits de fichiers d'état | Utiliser l'état distant (S3) en production pour éviter les conflits de fichiers d'état locaux |

## 📚 Référence des Fichiers Clés

- **[terraform.tfvars](terraform.tfvars)** - Valeurs des variables spécifiques à l'environnement
- **[variables.tf](variables.tf)** - Définitions des variables d'entrée
- **[outputs.tf](outputs.tf)** - Valeurs de sortie de l'infrastructure
- **[modules/vpc/](modules/vpc/)** - Module VPC réutilisable
- **[modules/ec2/](modules/ec2/)** - Module EC2 réutilisable

## 🤝 Contribution

Les contributions sont bienvenues. Veuillez vous assurer que :
1. Tous les fichiers Terraform sont formatés avec `terraform fmt`
2. Vous exécutez `terraform validate` avant de valider
3. Vous mettez à jour la documentation pour toute nouvelle ressource ou variable

## 📝 Licence

Ce projet est fourni tel quel à des fins éducatives et de développement.

---

**Dernière mise à jour :** Avril 2026

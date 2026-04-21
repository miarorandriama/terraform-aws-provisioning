# 🚀 AWS Infrastructure Simulation with Terraform & LocalStack

## 📌 Présentation du Projet
Ce projet démontre la capacité à concevoir et déployer une infrastructure Cloud AWS **modulaire** et **scalable** de manière totalement isolée et gratuite grâce à **LocalStack**.
L'objectif est de fournir un environnement de développement local identique à la production, permettant de valider les configurations réseau et de sécurité avant tout déploiement réel.
## 🏗️ Architecture Déployée
L'infrastructure est entièrement modularisée et comprend :
 * **VPC :** Réseau virtuel isolé avec segmentation par sous-réseaux.
 * **Subnets :** Un sous-réseau Public (accès Internet) et un sous-réseau Privé.
 * **Internet Gateway :** Configuration du routage pour l'accès web.
 * **EC2 Instance :** Serveur web provisionné dans le réseau public.
 * **Security Group :** Pare-feu restrictif autorisant uniquement le trafic HTTP (Port 80).
## 🛠️ Concepts DevOps implémentés
 * **Modularité :** Séparation logique des ressources (VPC, EC2) pour une réutilisation maximale.
 * **Tagging Dynamique :** Utilisation de la fonction merge pour une traçabilité et une gestion des coûts (FinOps) optimale.
 * **Gestion des variables :** Séparation stricte entre la définition (variables.tf) et les valeurs (terraform.tfvars).
 * **Simulation Cloud-Native :** Utilisation de LocalStack pour éliminer les coûts de développement.
## 🚀 Installation et Déploiement
### Prérequis
 * Docker & Docker Desktop
 * Terraform >= 1.10.5
 * AWS CLI
### Étapes
 1. **Lancer LocalStack :**
   ```bash
   docker run -d -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
   
   ```
 2. **Initialiser Terraform :**
   ```bash
   terraform init
   
   ```
 3. **Vérifier l'infrastructure :**
   ```bash
   terraform plan
   
   ```
 4. **Déployer :**
   ```bash
   terraform apply -auto-approve
   
   ```
## 🔍 Vérification (Validation QA)
Une fois déployé, vous pouvez vérifier l'état des ressources dans LocalStack :
```bash
# Vérifier le VPC
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs --output table

# Vérifier l'instance et ses tags
aws --endpoint-url=http://localhost:4566 ec2 describe-instances --query "Reservations[*].Instances[*].{ID:InstanceId, Tags:Tags}" --output table

```
## 💡 Troubleshooting (Leçons Apprises)
| Problème | Solution |
|---|---|
| Conflit AWS CLI (Segfault) | Migration vers l'appel direct via --endpoint-url pour garantir la stabilité. |
| Portée des variables | Implémentation d'un système de passage de variables entre modules pour l'isolation. |
**Auteur :** [Ton Nom] – Consultant DevOps & QA
**Contact :** [Ton lien LinkedIn ou Email]

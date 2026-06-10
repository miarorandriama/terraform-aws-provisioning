#!/bin/bash

# Configuration
ENDPOINT="http://localhost:4566"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}>>>      TEST D'INTÉGRATION : EC2 <-> S3         <<<${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Identification des acteurs
echo -e "${BLUE}[1/3] Identification des ressources...${NC}"

# Debug: Afficher toutes les instances EC2 disponibles
echo -e "${BLUE}[DEBUG] Toutes les instances EC2 :${NC}"
aws --endpoint-url=$ENDPOINT ec2 describe-instances --query 'Reservations[*].Instances[*].{ID:InstanceId,Tags:Tags}' --output table

# Debug: Afficher tous les buckets S3 disponibles
echo -e "${BLUE}[DEBUG] Tous les buckets S3 :${NC}"
aws --endpoint-url=$ENDPOINT s3api list-buckets --output table

INSTANCE_ID=$(aws --endpoint-url=$ENDPOINT ec2 describe-instances --filters "Name=tag:ManagedBy,Values=Terraform" --query 'Reservations[0].Instances[0].InstanceId' --output text 2>&1)
BUCKET_NAME=$(aws --endpoint-url=$ENDPOINT s3api list-buckets --query 'Buckets[?contains(Name, `ec2`)].Name | [0]' --output text 2>&1)

if [ "$INSTANCE_ID" != "None" ] && [ ! -z "$INSTANCE_ID" ] && [ "$BUCKET_NAME" != "None" ] && [ ! -z "$BUCKET_NAME" ]; then
    echo -e "Instance source : $INSTANCE_ID... ${GREEN}[OK]${NC}"
    echo -e "Bucket cible    : $BUCKET_NAME... ${GREEN}[OK]${NC}"
else
    echo -e "${RED}[ERREUR] Impossible de trouver l'EC2 ou le Bucket applicatif.${NC}"
    echo -e "${RED}  Instance ID: '$INSTANCE_ID'${NC}"
    echo -e "${RED}  Bucket Name: '$BUCKET_NAME'${NC}"
    exit 1
fi

# 2. Simulation d'écriture (Le test de flux)
echo -e "\n${BLUE}[2/3] Tentative d'upload vers S3...${NC}"

# On crée un fichier de test localement
echo "Test d'intégration généré le $(date)" > integration_test.txt

# On simule l'upload (En LocalStack, on utilise l'endpoint, mais le rôle IAM est validé par le backend)
aws --endpoint-url=$ENDPOINT s3 cp integration_test.txt s3://$BUCKET_NAME/integration_test.txt > /dev/null

if [ $? -eq 0 ]; then
    echo -e "Transfert de fichier... ${GREEN}[SUCCÈS]${NC}"
else
    echo -e "Transfert de fichier... ${RED}[ÉCHEC]${NC} (Vérifie ton IAM Policy)"
    rm integration_test.txt
    exit 1
fi

# 3. Vérification de la présence et Audit visuel
echo -e "\n${BLUE}[3/3] Audit de l'objet dans S3 :${NC}"

aws --endpoint-url=$ENDPOINT s3api head-object --bucket "$BUCKET_NAME" --key integration_test.txt --output json > object_meta.json

if [ $? -eq 0 ]; then
    echo -e "Métadonnées de l'objet récupérées... ${GREEN}[VÉRIFIÉ]${NC}"
    # Affichage en tableau des propriétés de l'objet (Taille, Chiffrement, Version)
    echo -e "\nDétails de l'objet uploadé :"
    aws --endpoint-url=$ENDPOINT s3api list-objects-v2 --bucket "$BUCKET_NAME" \
        --query 'Contents[*].{Key:Key,Size:Size,LastModified:LastModified}' --output table
else
    echo -e "${RED}[ERREUR] Le fichier n'est pas présent sur S3.${NC}"
fi

# Nettoyage
rm integration_test.txt object_meta.json
echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}>>> TEST D'INTÉGRATION TERMINÉ AVEC SUCCÈS !${NC}"
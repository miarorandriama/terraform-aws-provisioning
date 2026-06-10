#!/bin/bash

# Configuration
ENDPOINT="http://localhost:4566"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}>>>      AUDIT COMPLIANCE : MODULE S3            <<<${NC}"
echo -e "${BLUE}====================================================${NC}"

# --- 1. INVENTAIRE DES BUCKETS ---
echo -e "\n${BLUE}[1/3] Liste des buckets gérés par Terraform...${NC}"

# On liste tous les buckets et on filtre ceux qui ont le tag ManagedBy: Terraform
BUCKET_LIST=$(aws --endpoint-url=$ENDPOINT s3api list-buckets --query 'Buckets[].Name' --output text)

if [ -z "$BUCKET_LIST" ] || [ "$BUCKET_LIST" == "None" ]; then
    echo -e "${RED}[ERREUR CRITIQUE] Aucun bucket S3 détecté dans LocalStack.${NC}"
    exit 1
fi

# Audit visuel des buckets existants
aws --endpoint-url=$ENDPOINT s3api list-buckets --query 'Buckets[*].{Name:Name,CreationDate:CreationDate}' --output table

# --- 2. AUDIT DÉTAILLÉ PAR BUCKET ---
# On va tester chaque bucket trouvé pour vérifier sa configuration technique
for BUCKET in $BUCKET_LIST; do
    echo -e "\n${BLUE}>>> Focus sur le bucket : ${GREEN}$BUCKET${NC}"

    # A. Vérification du Versioning (Essentiel pour le Backend TF)
    VERSIONING=$(aws --endpoint-url=$ENDPOINT s3api get-bucket-versioning --bucket "$BUCKET" --query 'Status' --output text)
    echo -n "Versioning : "
    if [ "$VERSIONING" == "Enabled" ]; then
        echo -e "${GREEN}[ACTIVE]${NC}"
    else
        echo -e "${RED}[INACTIF]${NC} (Recommandé pour TFState)"
    fi

    # B. Vérification du Chiffrement (SSE-S3)
    ENCRYPTION=$(aws --endpoint-url=$ENDPOINT s3api get-bucket-encryption --bucket "$BUCKET" --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null)
    echo -n "Chiffrement : "
    if [ "$ENCRYPTION" == "AES256" ]; then
        echo -e "${GREEN}[AES256 CONFORME]${NC}"
    else
        echo -e "${RED}[NON CHIFFRÉ]${NC}"
    fi

    # C. Vérification de l'Accès Public (Block Public Access)
    # Si la commande retourne un code 0, c'est que le blocage est en place
    aws --endpoint-url=$ENDPOINT s3api get-public-access-block --bucket "$BUCKET" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "Accès Public : ${GREEN}[BLOQUÉ]${NC}"
    else
        echo -e "Accès Public : ${RED}[OUVERT / NON CONFIGURÉ]${NC}"
    fi
done

# --- 3. AUDIT DE CONFORMITÉ DES TAGS ---
echo -e "\n${BLUE}[3/3] Vérification de l'Héritage des Tags :${NC}"

# Pour chaque bucket, on affiche ses tags dans un tableau propre
for BUCKET in $BUCKET_LIST; do
    echo -e "Tags pour $BUCKET :"
    aws --endpoint-url=$ENDPOINT s3api get-bucket-tagging --bucket "$BUCKET" \
        --query 'TagSet[*].{Key:Key,Value:Value}' --output table
done

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}>>> Audit S3 terminé.${NC}"
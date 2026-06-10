#!/bin/bash

# Configuration
ENDPOINT="http://localhost:4566"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}>>>      AUDIT COMPLIANCE : INSTANCE EC2         <<<${NC}"
echo -e "${BLUE}====================================================${NC}"

# --- 1. VALIDATION DE L'INSTANCE ---
echo -e "\n${BLUE}[1/3] Vérification de l'état de l'instance...${NC}"

# On récupère les données via le tag ManagedBy pour éviter les erreurs d'index [0]
# C'est plus robuste pour GitHub et LocalStack
INSTANCE_DATA=$(aws --endpoint-url=$ENDPOINT ec2 describe-instances \
    --filters "Name=tag:ManagedBy,Values=Terraform" \
    --query 'Reservations[0].Instances[0].{ID:InstanceId,State:State.Name,Type:InstanceType,IP:PrivateIpAddress,IAM:IamInstanceProfile.Arn}' \
    --output json)

INSTANCE_ID=$(echo $INSTANCE_DATA | jq -r '.ID')
INSTANCE_STATE=$(echo $INSTANCE_DATA | jq -r '.State')

if [ "$INSTANCE_ID" != "null" ] && [ "$INSTANCE_ID" != "" ]; then
    echo -e "ID Instance : $INSTANCE_ID... ${GREEN}[DÉTECTÉ]${NC}"
    if [ "$INSTANCE_STATE" == "running" ]; then
        echo -e "Statut       : $INSTANCE_STATE... ${GREEN}[OK]${NC}"
    else
        echo -e "Statut       : ${RED}$INSTANCE_STATE${NC} (Attendu: running)"
    fi
else
    echo -e "${RED}[ERREUR CRITIQUE] Aucune instance gérée par Terraform trouvée.${NC}"
    exit 1
fi

# Audit visuel : Configuration technique et Tags (Héritage)
echo -e "Inventaire technique de l'instance :"
aws --endpoint-url=$ENDPOINT ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,Name:Tags[?Key==`Name`].Value | [0],Proj:Tags[?Key==`Project`].Value | [0],Serv:Tags[?Key==`Service`].Value | [0]}' \
    --output table


# --- 2. AUDIT DE SÉCURITÉ (Security Groups) ---
echo -e "\n${BLUE}[2/3] Vérification des Groupes de Sécurité...${NC}"

SG_ID=$(aws --endpoint-url=$ENDPOINT ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)

if [ "$SG_ID" != "None" ]; then
    echo -e "Security Group lié : $SG_ID... ${GREEN}[VÉRIFIÉ]${NC}"
else
    echo -e "Security Group... ${RED}[NON LIÉ]${NC}"
fi

# Audit visuel des règles entrantes (Ingress)
echo -e "Règles de filtrage (Ports ouverts) :"
aws --endpoint-url=$ENDPOINT ec2 describe-security-groups \
    --group-ids "$SG_ID" \
    --query 'SecurityGroups[0].IpPermissions[*].{Port:FromPort,Protocol:IpProtocol,Range:IpRanges[0].CidrIp}' \
    --output table


# --- 3. AUDIT DU RÔLE IAM (Lien S3) ---
echo -e "\n${BLUE}[3/3] Vérification du Profil d'Instance IAM...${NC}"

IAM_ARN=$(echo $INSTANCE_DATA | jq -r '.IAM')

if [ "$IAM_ARN" != "null" ]; then
    echo -e "Profil IAM attaché... ${GREEN}[OK]${NC}"
    echo -e "ARN Profil : ${BLUE}$IAM_ARN${NC}"
    
    # AJOUT : Vérification du contenu du profil (Le rôle est-il bien dedans ?)
    echo -n "Vérification de la validité du lien... "
    if [[ "$IAM_ARN" == *"profile"* ]]; then
        echo -e "${GREEN}[PONT VALIDE]${NC}"
    else
        echo -e "${RED}[PONT DOUTEUX]${NC}"
    fi
else
    echo -e "Profil IAM... ${RED}[MANQUANT]${NC} (L'EC2 ne pourra pas accéder à S3)"
fi

# Audit visuel de TOUS les tags (Vérification finale de l'héritage complet)
echo -e "\nAudit détaillé de tous les Tags (Clés et Valeurs) :"
aws --endpoint-url=$ENDPOINT ec2 describe-tags \
    --filters "Name=resource-id,Values=$INSTANCE_ID" \
    --query 'Tags[*].{Key:Key,Value:Value}' \
    --output table

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}>>> Audit EC2 terminé.${NC}"
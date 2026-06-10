#!/bin/bash

# Configuration
ENDPOINT="http://localhost:4566"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}>>>   AUDIT RÉSEAU : VPC, SUBNETS & GATEWAYS     <<<${NC}"
echo -e "${BLUE}====================================================${NC}"

# --- 1. VALIDATION DU VPC ---
echo -e "\n${BLUE}[1/3] Vérification du VPC Principal...${NC}"
# On filtre spécifiquement pour ne PAS prendre le VPC par défaut
VPC_DATA=$(aws --endpoint-url=$ENDPOINT ec2 describe-vpcs \
    --filters "Name=tag:ManagedBy,Values=Terraform" \
    --query 'Vpcs[0].{ID:VpcId,Cidr:CidrBlock}' --output json)
VPC_ID=$(echo $VPC_DATA | jq -r '.ID')
VPC_CIDR=$(echo $VPC_DATA | jq -r '.Cidr')

if [ "$VPC_ID" != "null" ] && [ "$VPC_ID" != "" ]; then
    echo -e "VPC $VPC_ID détecté... ${GREEN}[OK]${NC}"
    # Test de conformité du CIDR (ex: 10.0.0.0/16)
    if [ "$VPC_CIDR" == "10.0.0.0/16" ]; then
        echo -e "Configuration CIDR ($VPC_CIDR)... ${GREEN}[CONFORME]${NC}"
    else
        echo -e "Configuration CIDR ($VPC_CIDR)... ${RED}[NON-CONFORME]${NC}"
    fi
else
    echo -e "${RED}[ERREUR CRITIQUE] Aucun VPC trouvé. Arrêt du test.${NC}"
    exit 1
fi

# Affichage des Tags du VPC
echo -e "Détails visuels du VPC :"
aws --endpoint-url=$ENDPOINT ec2 describe-vpcs --query 'Vpcs[*].{ID:VpcId,Name:Tags[?Key==`Name`].Value | [0],Project:Tags[?Key==`Project`].Value | [0],Env:Tags[?Key==`Environment`].Value | [0]}' --output table


# --- 2. VALIDATION DES SOUS-RÉSEAUX ---
echo -e "\n${BLUE}[2/3] Vérification des Sous-réseaux...${NC}"

SUBNET_COUNT=$(aws --endpoint-url=$ENDPOINT ec2 describe-subnets --query 'length(Subnets)' --output text)

if [ "$SUBNET_COUNT" -gt 0 ]; then
    echo -e "Nombre de sous-réseaux : $SUBNET_COUNT... ${GREEN}[OK]${NC}"
else
    echo -e "${RED}[ERREUR] Aucun sous-réseau détecté !${NC}"
fi

# Audit visuel des subnets
echo -e "Inventaire des Sous-réseaux :"
aws --endpoint-url=$ENDPOINT ec2 describe-subnets \
    --filters "Name=tag:ManagedBy,Values=Terraform" \
    --query 'Subnets[*].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Name:Tags[?Key==`Name`].Value | [0]}' \
    --output table


# --- 3. VALIDATION DE L'ACCÈS INTERNET ---
echo -e "\n${BLUE}[3/3] Vérification de l'Internet Gateway (IGW)...${NC}"

IGW_ID=$(aws --endpoint-url=$ENDPOINT ec2 describe-internet-gateways --query 'InternetGateways[0].InternetGatewayId' --output text)

if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
    echo -e "Internet Gateway $IGW_ID trouvée... ${GREEN}[OK]${NC}"
    
    # Vérification de l'attachement au VPC
    ATTACHED_VPC=$(aws --endpoint-url=$ENDPOINT ec2 describe-internet-gateways --internet-gateway-ids "$IGW_ID" --query 'InternetGateways[0].Attachments[0].VpcId' --output text)
    
    if [ "$ATTACHED_VPC" == "$VPC_ID" ]; then
        echo -e "Lien IGW <-> VPC... ${GREEN}[VÉRIFIÉ]${NC}"
    else
        echo -e "Lien IGW <-> VPC... ${RED}[ERREUR D'ATTACHEMENT]${NC}"
    fi
else
    echo -e "Internet Gateway... ${RED}[NON TROUVÉE]${NC}"
fi

# Audit visuel des routes vers l'extérieur
echo -e "Table de routage (Vérification des routes 0.0.0.0/0) :"
aws --endpoint-url=$ENDPOINT ec2 describe-route-tables \
    --query 'RouteTables[*].Routes[?DestinationCidrBlock==`0.0.0.0/0`].{Dest:DestinationCidrBlock,Target:GatewayId,State:State}' \
    --output table

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}>>> Audit Réseau terminé avec succès.${NC}"
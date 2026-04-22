#!/bin/bash

# Configuration
ENDPOINT="http://localhost:4566"
REGION="us-east-2"
alias aws_local="aws --endpoint-url=$ENDPOINT --region=$REGION"

echo "-------------------------------------------------------"
echo "🔍 AUDIT DE L'INFRASTRUCTURE (LOCALSTACK)"
echo "-------------------------------------------------------"

# 1. Vérification du VPC
echo -e "\n[1] Vérification du VPC..."
aws_local ec2 describe-vpcs --query "Vpcs[*].{Name:Tags[?Key=='Name']|[0].Value,ID:VpcId,CIDR:CidrBlock}" --output table

# 2. Vérification de la segmentation des Subnets
echo -e "\n[2] Vérification des Sous-réseaux (Public vs Privé)..."
aws_local ec2 describe-subnets --query "Subnets[*].{Name:Tags[?Key=='Name']|[0].Value,CIDR:CidrBlock,PublicIP:MapPublicIpOnLaunch}" --output table

# 3. Vérification de la connectivité (Internet Gateway)
echo -e "\n[3] Vérification de l'Internet Gateway..."
aws_local ec2 describe-internet-gateways --query "InternetGateways[*].{ID:InternetGatewayId,AttachedVPC:Attachments[0].VpcId}" --output table

# 4. Vérification des règles de Pare-feu (Security Groups)
echo -e "\n[4] Audit des ports ouverts (Ingress)..."
aws_local ec2 describe-security-groups --query "SecurityGroups[*].{GroupName:GroupName,Ports:IpPermissions[*].ToPort}" --output table

# 5. État des serveurs EC2
echo -e "\n[5] État des Instances EC2..."
aws_local ec2 describe-instances --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,ID:InstanceId,State:State.Name,Subnet:SubnetId}" --output table

echo -e "\n✅ Audit terminé."

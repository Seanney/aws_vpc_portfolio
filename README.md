# aws_vpc_portfolio
Implementation a high-availability dual-NAT VPC using terraform
# High Availability AWS VPC with Dual NAT Gateways

A production simulated VPC architecture in `eu-north-1` with public and private subnets across two Availability Zones, dual NAT Gateways for high availability, and clean route table design.

## Architecture Overview

Component              Count Details                                      

VPC                    1     `10.0.0.0/16`                                
Public Subnets         2     One in each AZ (`eu-north-1a`, `eu-north-1b`) 
Private Subnets        2     One in each AZ                               
Internet Gateway       1     Attached to VPC                              
NAT Gateways           2     One per AZ (high availability)               
Elastic IPs            2     One per NAT Gateway                          
Route Tables           3     1 public + 2 private                         

### Network Layout

Subnet              CIDR          AZ            Type    Purpose                          
public_subnet1      10.0.1.0/24   eu-north-1a   Public  NAT Gateway 1, public resources  
public_subnet2      10.0.2.0/24   eu-north-1b   Public  NAT Gateway 2, public resources  
private_subnet1     10.0.3.0/24   eu-north-1a   Private Application tier (AZ-a)          
private_subnet2     10.0.4.0/24   eu-north-1b   Private Application tier (AZ-b)          

## Design Decisions

Decision                    Choice                          Reason                                      
Number of AZs               2                               High availability                           
NAT Gateway strategy        1 per AZ                        Avoid single point of failure + cross-AZ costs 
Public route table          Shared                          Both public subnets route to IGW            
Private route tables        Separate (one per AZ)           Each private subnet routes to local NAT     
map_public_ip_on_launch     Enabled on public subnets       Automatic public IPs for public resources   

## Traffic Flow

1. **Public subnet resources** → Internet Gateway → Internet
2. **Private subnet (AZ-a)** → NAT Gateway 1 (same AZ) → Internet Gateway → Internet
3. **Private subnet (AZ-b)** → NAT Gateway 2 (same AZ) → Internet Gateway → Internet

This design ensures that if one Availability Zone fails, the other AZ continues to have outbound internet access.

## Cost Implications

Resource              Approximate Monthly Cost Notes                          
NAT Gateway (x2)      ~$66                     $0.045/hour each              
Data processing       Variable                 $0.045 per GB                  
Elastic IPs (x2)      $0                       Free when associated           
**Fixed baseline**    **~$66/month**           Before data transfer           

## How to Deploy
terraform init
terraform plan
terraform apply

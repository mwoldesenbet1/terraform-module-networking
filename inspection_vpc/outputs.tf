# inspection_vpc/outputs.tf

output "inspection_vpc_id" {
  description = "ID of the inspection VPC"
  value       = aws_vpc.inspection_vpc.id
}

output "inspection_vpc_cidr" {
  description = "CIDR block of the inspection VPC"
  value       = aws_vpc.inspection_vpc.cidr_block
}

output "inspection_public_subnet_ids" {
  description = "IDs of public subnets in the inspection VPC (for GWLB endpoints)"
  value       = aws_subnet.inspection_public_subnets[*].id
}

output "inspection_private_subnet_ids" {
  description = "IDs of private subnets in the inspection VPC (for security appliances)"
  value       = aws_subnet.inspection_private_subnets[*].id
}


output "nat_gateway_ids" {
  description = "IDs of the NAT gateways in the inspection VPC"
  value       = aws_nat_gateway.inspection_nat_gw[*].id
}

output "inspection_public_rt_id" {
  description = "ID of the public route table in the inspection VPC"
  value       = aws_route_table.inspection_public_rt.id
}

output "inspection_private_rt_ids" {
  description = "IDs of the private route tables in the inspection VPC"
  value       = aws_route_table.inspection_private_rt[*].id
}

output "inspection_tgw_subnet_ids" {
  description = "IDs of TGW attachment subnets in the inspection VPC"
  value       = aws_subnet.inspection_tgw_subnets[*].id
}


output "network_firewall_id" {
  description = "ID of the Network Firewall"
  value       = aws_networkfirewall_firewall.inspection_firewall.id
}

output "network_firewall_arn" {
  description = "ARN of the Network Firewall"
  value       = aws_networkfirewall_firewall.inspection_firewall.arn
}

output "network_firewall_endpoints" {
  description = "Map of AZ to Network Firewall endpoint ID"
  value       = {
    for state in aws_networkfirewall_firewall.inspection_firewall.firewall_status[0].sync_states :
    state.availability_zone => state.attachment[0].endpoint_id
  }
}

output "network_firewall_policy_arn" {
  description = "ARN of the Network Firewall policy"
  value       = aws_networkfirewall_firewall_policy.inspection_policy.arn
}

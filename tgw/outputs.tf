output "transit_gateway_id" {
  description = "ID of the created Transit Gateway"
  value       = aws_ec2_transit_gateway.tgw.id
}

output "transit_gateway_arn" {
  description = "ARN of the created Transit Gateway"
  value       = aws_ec2_transit_gateway.tgw.arn
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.tgw_rt.id
}

output "vpc_west_attachment_id" {
  description = "ID of the us-west-2 VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpc_west_attachment.id
}

output "transit_gateway_east_id" {
  description = "ID of the created Transit Gateway in us-east-1"
  value       = aws_ec2_transit_gateway.tgw_east.id
}

output "transit_gateway_east_arn" {
  description = "ARN of the created Transit Gateway in us-east-1"
  value       = aws_ec2_transit_gateway.tgw_east.arn
}

output "transit_gateway_route_table_east_id" {
  description = "ID of the Transit Gateway route table in us-east-1"
  value       = aws_ec2_transit_gateway_route_table.tgw_rt_east.id
}

output "vpc_east_attachment_id" {
  description = "ID of the us-east-1 VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpc_east_attachment.id
}

output "tgw_peering_id" {
  description = "ID of the Transit Gateway peering connection"
  value       = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
}

output "tgw_peering_state" {
  description = "State of the Transit Gateway peering connection"
  value       = aws_ec2_transit_gateway_peering_attachment.tgw_peering.state
}

output "spoke_route_table_id" {
  description = "ID of the spoke route table"
  value       = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

output "inspection_route_table_id" {
  description = "ID of the inspection route table"
  value       = aws_ec2_transit_gateway_route_table.inspection_rt.id
}

output "vpc_dev_attachment_id" {
  description = "ID of the development VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpc_dev_attachment.id
}
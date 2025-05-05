# Network Firewall stateless rule group
resource "aws_networkfirewall_rule_group" "stateless_rules" {
  provider    = aws.delegated_account_us-west-2
  capacity    = 100
  name        = "region-inspection-stateless"
  type        = "STATELESS"
  description = "Stateless rules for basic inspection"
  
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        # Rule for internal VPC traffic - forward to stateful rules
        stateless_rule {
          priority = 10
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = "10.0.0.0/8"  
              }
              destination {
                address_definition = "10.0.0.0/8"  
              }
            }
          }
        }
        
        # Rule for DNS traffic - allow directly
        stateless_rule {
          priority = 20
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              destination {
                address_definition = "8.8.8.8/32"  
              }
              protocols = [17]  # UDP
              destination_port {
                from_port = 53
                to_port   = 53
              }
            }
          }
        }
        
        # Default rule - forward to stateful rules
        stateless_rule {
          priority = 30
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
  
  tags = {
    Name        = "region-inspection-stateless"
    Environment = "security"
    ManagedBy   = "terraform"
  }
}

#stateful rule group for east-west traffic
resource "aws_networkfirewall_rule_group" "stateful_rules" {
  provider    = aws.delegated_account_us-west-2
  capacity    = 100
  name        = "region-inspection-stateful"
  type        = "STATEFUL"
  description = "Stateful rules for traffic inspection"
  
  rule_group {
    rules_source {
      rules_string = <<EOF
# Allow established connections
pass tcp any any <> any any (msg:"Allow established connections"; flow:established; sid:1;)

# Allow ICMP for ping
pass icmp any any -> any any (msg:"Allow ICMP"; sid:2;)

# Allow all internal traffic between VPCs (east-west)
pass ip 10.0.0.0/8 any -> 10.0.0.0/8 any (msg:"Allow internal VPC traffic"; sid:3;)

# Allow DNS traffic
pass udp any any -> any 53 (msg:"Allow DNS"; sid:4;)
pass tcp any any -> any 53 (msg:"Allow DNS TCP"; sid:5;)

# HTTP/HTTPS traffic
pass tcp any any -> any 80 (msg:"Allow HTTP"; sid:6;)
pass tcp any any -> any 443 (msg:"Allow HTTPS"; sid:7;)

# Block common attack vectors
drop tcp any any -> any 22 (msg:"Block SSH from Internet"; sid:8;)
drop tcp any any -> any 3389 (msg:"Block RDP from Internet"; sid:9;)

# Specific East-West traffic rules (production to development)
pass tcp 10.0.0.0/17 any -> 10.0.64.0/18 any (msg:"Allow traffic from prod to dev"; sid:10;)
pass tcp 10.0.64.0/18 any -> 10.0.0.0/17 any (msg:"Allow traffic from dev to prod"; sid:11;)
EOF
    }
  }
  
  tags = {
    Name        = "region-inspection-stateful"
    Environment = "security"
    ManagedBy   = "terraform"
  }
}
# Network Firewall policy
resource "aws_networkfirewall_firewall_policy" "inspection_policy" {
  provider    = aws.delegated_account_us-west-2
  name        = "region-inspection-policy"
  description = "Policy for regional traffic inspection"
  
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    
    # Reference the stateless rule group
    stateless_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateless_rules.arn
      priority     = 10
    }
    
    # Reference the stateful rule group
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful_rules.arn
    }
  }
  
  tags = {
    Name        = "region-inspection-policy"
    Environment = "security"
    ManagedBy   = "terraform"
  }
}

# Network Firewall
resource "aws_networkfirewall_firewall" "inspection_firewall" {
  provider    = aws.delegated_account_us-west-2
  name        = var.network_firewall_name
  description = "Network Firewall for centralized inspection"
  
  firewall_policy_arn = aws_networkfirewall_firewall_policy.inspection_policy.arn
  vpc_id              = aws_vpc.inspection_vpc.id
  
  # Create firewall endpoints in private subnets
  dynamic "subnet_mapping" {
    for_each = aws_subnet.inspection_private_subnets[*].id
    content {
      subnet_id = subnet_mapping.value
    }
  }
  
  tags = {
    Name        = var.network_firewall_name
    Environment = "security"
    ManagedBy   = "terraform"
  }
}

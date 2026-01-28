#!/bin/bash

# List of instance types to try (free tier eligible)
INSTANCE_TYPES=("t2.micro" "t3.micro" "t3a.micro" "t4g.micro")
REGIONS=("us-east-1" "us-west-2" "eu-west-1")

echo "Testing instance types in different regions..."

for region in "${REGIONS[@]}"; do
  echo ""
  echo "=== Testing region: $region ==="
  
  for instance_type in "${INSTANCE_TYPES[@]}"; do
    echo "Trying instance type: $instance_type"
    
    # Update configuration
    cat > terraform.tfvars << TFVARS
aws_region = "$region"
environment = "dev"
instance_type = "$instance_type"
availability_zone = "${region}a"
TFVARS
    
    # Initialize if needed
    terraform init -reconfigure >/dev/null 2>&1
    
    # Try to plan
    if terraform plan -out=tfplan 2>&1 | grep -q "Error"; then
      echo "  ❌ $instance_type failed in $region"
    else
      echo "  ✅ $instance_type works in $region"
      # Try to apply
      if terraform apply -auto-approve 2>&1 | grep -q "Error"; then
        echo "  ⚠️  $instance_type planned but failed to apply"
        terraform destroy -auto-approve >/dev/null 2>&1
      else
        echo "  🎉 Successfully deployed with $instance_type in $region"
        echo "Instance Public IP: $(terraform output -raw ec2_public_ip 2>/dev/null || echo 'N/A')"
        break 2  # Exit both loops on success
      fi
    fi
    
    # Clean up
    terraform destroy -auto-approve >/dev/null 2>&1
  done
done

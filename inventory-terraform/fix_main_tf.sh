#!/bin/bash

# Create backup
cp main.tf main.tf.bak.$(date +%s)

# Remove the problematic line completely
sed -i '/inventory-key = var.key_name/d' main.tf

# Now add the correct line after vpc_security_group_ids
# Find the line with vpc_security_group_ids
LINE_NUM=$(grep -n "vpc_security_group_ids = \[aws_security_group.inventory_sg.id\]" main.tf | cut -d: -f1)

if [ ! -z "$LINE_NUM" ]; then
    # Add key_name on the next line
    sed -i "${LINE_NUM}a \  key_name = var.key_name" main.tf
    echo "Added key_name at line $((LINE_NUM + 1))"
else
    echo "Could not find vpc_security_group_ids line"
    echo "Adding key_name before the closing brace of the EC2 resource"
    # Add before the closing brace of the EC2 resource
    sed -i '/resource "aws_instance" "inventory_ec2"/,/^}/s/^}/  key_name = var.key_name\n}/' main.tf
fi

echo "Fixed main.tf"

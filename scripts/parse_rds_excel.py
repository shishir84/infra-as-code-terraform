import pandas as pd
import json

# Load Excel file
df = pd.read_excel("../templates/dev/dev_config.xlsx", sheet_name="RDS")

rds_instances = []

for _, row in df.iterrows():
    tags = {
        "Tag1": row["Tag1"],
        "Tag2": row["Tag2"],
        "Tag3": row["Tag3"],
        "Tag4": row["Tag4"],
        "Name": row["DBInstanceIdentifier"]
    }
    tags = {k: v for k, v in tags.items() if pd.notna(v)}

    rds_instance = {
        "identifier": row["DBInstanceIdentifier"],
        "db_name": row["DBName"],
        "username": row["DBUsername"],
        "password": row["DBPassword"],
        "instance_class": row["DBInstanceClass"],
        "allocated_storage": int(row["AllocatedStorage"]),
        "engine_version": str(row["EngineVersion"]),
     #   "vpc_security_group_ids": [id.strip() for id in str(row["VPCSecurityGroupIds"]).split(",")],
        "db_subnet_group_name": row["DBSubnetGroupName"],
        "multi_az": str(row["MultiAZ"]).lower() == "true",
        "publicly_accessible": str(row["PubliclyAccessible"]).lower() == "false",
        "backup_retention_period": int(row["BackupRetentionPeriod"]),
        "kms_key_id": row["KMSKeyId"], 
        "subnet_ids_raw": row["Subnets"], 
        "vpc_id": row["VPCId"],
        "tags": tags
    }

    rds_instances.append(rds_instance)

# Write to Terraform-compatible JSON
with open("../modules/rds/rds.auto.tfvars.json", "w") as f:
    json.dump({"rds_instances": rds_instances}, f, indent=2)

print("RDS Terraform variable file generated successfully.")

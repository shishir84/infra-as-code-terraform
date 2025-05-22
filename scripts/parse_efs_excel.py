import pandas as pd
import json

# Load Excel sheet
df = pd.read_excel("../templates/dev/dev_config.xlsx", sheet_name="EFS")

efs_filesystems = []

for _, row in df.iterrows():
    # Parse tags from Tag columns as dict
    tags = {}
    for tag_col in ["TagsTag1", "TagsTag2", "TagsTag3", "TagsTag4"]:
        val = row.get(tag_col, None)
        if pd.notna(val) and "=" in str(val):
            key, value = str(val).split("=", 1)
            tags[key.strip()] = value.strip()
    tags["Name"] = row["FileSystemName"]

    # Parse subnet ids and security group ids as list
    subnet_ids = [s.strip() for s in str(row["SubnetIds"]).split(",") if s.strip()]
    #sg_ids = [s.strip() for s in str(row["SecurityGroupIds"]).split(",") if s.strip()]

    efs_fs = {
        "filesystem_name": row["FileSystemName"],
        "performance_mode": row["PerformanceMode"],
        "encrypted": str(row["Encrypted"]).strip().lower() == "true",
        "kms_key_id": row["KmsKeyId"] if pd.notna(row["KmsKeyId"]) else None,
        "throughput_mode": row["ThroughputMode"],
        "provisioned_throughput_in_mibps": float(row["ProvisionedThroughputInMibps"]) if pd.notna(row["ProvisionedThroughputInMibps"]) else None,
        "subnet_ids": subnet_ids,
        "vpc_id": row["VPCId"],
        "allowed_cidrs": [cidr.strip() for cidr in str(row["AllowedCIDRs"]).split(",")],
        "tags": tags,
        "notes": row.get("Notes", "")
    }

    efs_filesystems.append(efs_fs)

# Write to Terraform compatible JSON
with open("../modules/efs/efs.auto.tfvars.json", "w") as f:
    json.dump({"efs_filesystems": efs_filesystems}, f, indent=2)

print("EFS Terraform variable file generated successfully.")

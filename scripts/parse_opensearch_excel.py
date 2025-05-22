import pandas as pd
import json

# Load Excel file
df = pd.read_excel("../templates/dev/dev_config.xlsx", sheet_name="OpenSearch Clusters")

opensearch_domains = []

for _, row in df.iterrows():
    tags = {
        "Environment": row.get("Environment", ""),
        "Notes": row.get("Notes", ""),
        "Name": row.get("ClusterName", "")
    }
    tags = {k: v for k, v in tags.items() if pd.notna(v) and v != ""}

    domain = {
        "domain_name": row["DomainName"],
        "engine_version": str(row["EngineVersion"]),
        "instance_type": row["InstanceType"],
        "instance_count": int(row["InstanceCount"]),
        "ebs_volume_size": int(row["EBSVolumeGB"]),
        "access_policies": row.get("AccessPolicy", None),
        "environment": row.get("Environment", ""),
        "tags": tags,
        "enable_fine_grained_access": bool(row.get("EnableFineGrainedAccess", False)),
        "master_user_name": row.get("MasterUserName", None),
        "master_user_password": row.get("MasterUserPassword", None)
    }

    # Remove keys with None or empty strings
    domain = {k: v for k, v in domain.items() if pd.notna(v) and v != ""}

    opensearch_domains.append(domain)

# Write to Terraform-compatible JSON
with open("../modules/opensearch/opensearch.auto.tfvars.json", "w") as f:
    json.dump({"opensearch_domains": opensearch_domains}, f, indent=2)

print("OpenSearch Terraform variable file generated successfully.")

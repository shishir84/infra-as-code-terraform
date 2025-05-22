import pandas as pd
import json

# Load Excel file and sheet
df = pd.read_excel("../templates/dev/dev_config.xlsx", sheet_name="ElastiCacheRedis")

elasticache_clusters = []

for _, row in df.iterrows():
    tags = {
        "Tag1": row.get("Tags_Tag1"),
        "Tag2": row.get("Tags_Tag2"),
        "Tag3": row.get("Tags_Tag3"),
        "Tag4": row.get("Tags_Tag4"),
        "Name": row.get("ClusterId")
    }
    tags = {k: v for k, v in tags.items() if pd.notna(v)}

    cluster = {
        "cluster_id": row["ClusterId"],
        "engine_version": str(row["EngineVersion"]),
        "node_type": row["NodeType"],
        "num_cache_nodes": int(row["NumCacheNodes"]),
        "subnet_ids": [s.strip() for s in str(row["SubnetIds"]).split(",")],
        "security_group_name": row["SecurityGroupName"],  # new column in Excel
        "maintenance_window": row["MaintenanceWindow"],
        "vpc_id": row["VpcId"],  # new column in Excel
        "tags": tags
    }

    elasticache_clusters.append(cluster)

# Write to Terraform-compatible JSON
with open("../modules/elasticache-redis/elasticache.auto.tfvars.json", "w") as f:
    json.dump({"elasticache_clusters": elasticache_clusters}, f, indent=2)

print("ElastiCache Redis Terraform variable file generated successfully.")

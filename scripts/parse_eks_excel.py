import pandas as pd
import json

# Load Excel file
df = pd.read_excel("../templates/dev/dev_config.xlsx", sheet_name="EKS")

eks_clusters = []

for _, row in df.iterrows():
    tags = {
        "Tag1": row["Tag1"],
        "Tag2": row["Tag2"],
        "Tag3": row["Tag3"],
        "Tag4": row["Tag4"],
        "Name": row["ClusterName"]
    }
    tags = {k: v for k, v in tags.items() if pd.notna(v)}

    cluster = {
        "name": row["ClusterName"],
        "version": str(row["Version"]),
        "node_group": {
            "name": row["NodeGroupName"],
            "instance_type": row["NodeInstanceType"],
            "desired_capacity": int(row["DesiredCapacity"]),
            "min_size": int(row["MinSize"]),
            "max_size": int(row["MaxSize"])
        },
        "vpc_id": row["VpcId"],
        "subnet_ids_raw": row["SubnetIds"],
        "tags": tags
    }

    eks_clusters.append(cluster)

with open("../modules/eks/eks.auto.tfvars.json", "w") as f:
    json.dump({"eks_clusters": eks_clusters}, f, indent=2)

print("EKS Terraform variable file generated successfully.")

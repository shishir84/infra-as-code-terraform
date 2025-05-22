import pandas as pd
import json

# Load Excel
df = pd.read_excel("../templates/dev/dev_config.xlsx", sheet_name="MSK")

msk_clusters = []

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
        "cluster_name": row["ClusterName"],
        "kafka_version": row["KafkaVersion"],
        "number_of_broker_nodes": int(row["NumberOfBrokerNodes"]),
        "broker_instance_type": row["BrokerInstanceType"],
        "client_subnets": [s.strip() for s in str(row["ClientSubnets"]).split(",")],
        "kms_key_name": row["KmsKeyName"],
        "vpc_id": row["VPCId"],
        "security_group_name": row["SGName"],
        "security_group_description": row["SGDescription"],
        "tags": tags
    }

    msk_clusters.append(cluster)

# Save tfvars
with open("../modules/msk/msk.auto.tfvars.json", "w") as f:
    json.dump({"msk_clusters": msk_clusters}, f, indent=2)

print("MSK Terraform variable file generated successfully.")

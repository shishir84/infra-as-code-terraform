import pandas as pd
import json

# Load Excel file
df = pd.read_excel("../templates/dev/dev_config.xlsx", sheet_name="EC2")

# Filter only EC2 rows
ec2_rows = df[df["AWS Resource"].str.upper() == "EC2"]

instances = []

for _, row in ec2_rows.iterrows():
    tags = {
        "Tag1": row["Tag1"],
        "Tag2": row["Tag2"],
        "Tag3": row["Tag3"],
        "Tag4": row["Tag4"],
        "Name": row["Name"],
        "Storage": row["Storage"]
    }

    # Remove empty/null tags
    tags = {k: v for k, v in tags.items() if pd.notna(v)}

    instance = {
        "name": row["Name"],
        "instance_type": row["InstanceType"],
        "ami": row["AMI"],
        "subnet_id": row["SubnetId"],
        "key_name": row["KeyName"],
        "storage": int(row["Storage"]),
        "tags": tags
    }

    instances.append(instance)

# Save to terraform variable file
with open("../modules/ec2/instances.auto.tfvars.json", "w") as f:
    json.dump({"instances": instances}, f, indent=2)

print("Terraform variable file generated successfully.")
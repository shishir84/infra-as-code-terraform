import pandas as pd
import json

# Load Excel file and S3 sheet
df = pd.read_excel("../templates/dev/dev_config.xlsx", sheet_name="S3")

s3_buckets = []

for _, row in df.iterrows():
    # Parse tags from Tag columns as dict (split key=value)
    tags = {}
    for tag_col in ["TagsTag1", "TagsTag2", "TagsTag3", "TagsTag4"]:
        val = row.get(tag_col, None)
        if pd.notna(val) and "=" in str(val):
            key, value = str(val).split("=", 1)
            tags[key.strip()] = value.strip()
    # Always add bucket name as Name tag
    tags["Name"] = row["BucketName"]

    bucket = {
        "bucket_name": row["BucketName"],
        "region": row["Region"],
        "versioning": True if str(row["Versioning"]).lower() == "enabled" else False,
        "acl": row["ACL"],
        "tags": tags,
        "notes": row.get("Notes", "")
    }

    s3_buckets.append(bucket)

# Write to JSON file
with open("../modules/s3/s3.auto.tfvars.json", "w") as f:
    json.dump({"s3_buckets": s3_buckets}, f, indent=2)

print("S3 Terraform variable file generated successfully.")

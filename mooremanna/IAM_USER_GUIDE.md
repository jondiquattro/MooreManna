# Creating an IAM User for S3 Bucket Management

This guide will help you create an IAM user with permissions to upload and delete files from your Moore Manna S3 bucket.

## Step-by-Step Guide

### Option 1: Using AWS Console (Web Interface)

#### Step 1: Create an IAM User

1. Log in to AWS Console at https://console.aws.amazon.com/iam/
2. In the left navigation pane, click **Users**
3. Click **Add users** (or **Create user**)
4. Enter a username (e.g., `mooremanna-uploader`)
5. Select **Access key - Programmatic access** (for AWS CLI/SDK)
6. Optionally select **Password - AWS Management Console access** (for web console access)
7. Click **Next: Permissions**

#### Step 2: Attach Permissions Policy

**Option A: Use the policy JSON file**
1. Click **Attach policies directly**
2. Click **Create policy**
3. Click the **JSON** tab
4. Copy and paste the policy from `s3-user-policy.json` (see below)
5. Click **Next: Tags**
6. Click **Next: Review**
7. Name the policy: `MooreManna-S3-Upload-Delete`
8. Click **Create policy**
9. Go back to the user creation page and refresh the policy list
10. Search for `MooreManna-S3-Upload-Delete` and select it
11. Click **Next: Tags**

**Option B: Attach existing AWS managed policy (less secure)**
1. Search for `AmazonS3FullAccess` and select it (gives access to ALL S3 buckets)
2. Click **Next: Tags**

#### Step 3: Complete User Creation

1. (Optional) Add tags if desired
2. Click **Next: Review**
3. Review the user details
4. Click **Create user**

#### Step 4: Save Credentials

**IMPORTANT:** Save these credentials immediately - you won't be able to see them again!

1. Download the CSV file with the credentials, or
2. Copy the **Access Key ID** and **Secret Access Key**
3. Store them securely (use a password manager)

---

### Option 2: Using AWS CLI

#### Step 1: Create the IAM User

```bash
# Create the user
aws iam create-user --user-name mooremanna-uploader

# Create access key for the user
aws iam create-access-key --user-name mooremanna-uploader
```

**Save the output!** It will contain the AccessKeyId and SecretAccessKey.

#### Step 2: Create and Attach the Policy

```bash
# Create the policy (replace YOUR-BUCKET-NAME with your actual bucket name)
aws iam create-policy \
  --policy-name MooreManna-S3-Upload-Delete \
  --policy-document file://s3-user-policy.json

# Get your AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Attach the policy to the user
aws iam attach-user-policy \
  --user-name mooremanna-uploader \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/MooreManna-S3-Upload-Delete
```

---

## S3 User Policy (JSON)

Save this as `s3-user-policy.json` and replace `YOUR-BUCKET-NAME` with your actual bucket name:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME"
        },
        {
            "Sid": "UploadDeleteFiles",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```

**What this policy allows:**
- List files in the bucket
- Upload files (PutObject)
- Set file permissions (PutObjectAcl)
- Download files (GetObject)
- Delete files (DeleteObject)

**What this policy does NOT allow:**
- Access to other S3 buckets
- Deleting the bucket itself
- Changing bucket policies
- Changing bucket settings

---

## Using the Credentials

### Configure AWS CLI with the New User

```bash
# Configure AWS CLI with the new credentials
aws configure --profile mooremanna-uploader

# Enter the Access Key ID
# Enter the Secret Access Key
# Enter default region (e.g., us-east-1)
# Enter default output format (json)
```

### Upload Files

```bash
# Upload a single file
aws s3 cp index.html s3://YOUR-BUCKET-NAME/ --profile mooremanna-uploader

# Upload entire directory
aws s3 sync . s3://YOUR-BUCKET-NAME/ --profile mooremanna-uploader

# Upload with public-read permissions
aws s3 cp index.html s3://YOUR-BUCKET-NAME/ --acl public-read --profile mooremanna-uploader
```

### Delete Files

```bash
# Delete a single file
aws s3 rm s3://YOUR-BUCKET-NAME/old-file.html --profile mooremanna-uploader

# Delete multiple files
aws s3 rm s3://YOUR-BUCKET-NAME/ --recursive --exclude "*" --include "*.backup" --profile mooremanna-uploader
```

### List Files

```bash
# List all files in the bucket
aws s3 ls s3://YOUR-BUCKET-NAME/ --profile mooremanna-uploader

# List files in a specific folder
aws s3 ls s3://YOUR-BUCKET-NAME/resources/ --profile mooremanna-uploader
```

---

## Security Best Practices

### 1. Use Multi-Factor Authentication (MFA)
- Enable MFA for the IAM user to add an extra layer of security
- Go to IAM → Users → Security credentials → Enable MFA

### 2. Rotate Access Keys Regularly
```bash
# Create a new access key
aws iam create-access-key --user-name mooremanna-uploader

# After updating your applications, delete the old key
aws iam delete-access-key --user-name mooremanna-uploader --access-key-id OLD-ACCESS-KEY-ID
```

### 3. Monitor User Activity
- Enable CloudTrail to log all API calls
- Review logs regularly for suspicious activity

### 4. Use Least Privilege
- Only grant the minimum permissions needed
- If user only needs upload, remove DeleteObject permission

### 5. Secure Credential Storage
- Never commit credentials to Git
- Use environment variables or AWS Secrets Manager
- Use AWS IAM roles when possible (for EC2, Lambda, etc.)

---

## Updating the Deployment Script

To use the new user credentials with the deployment script, update it:

```bash
#!/bin/bash
# Use the mooremanna-uploader profile
export AWS_PROFILE=mooremanna-uploader

# Or specify in the aws commands
aws s3 sync . s3://YOUR-BUCKET-NAME/ --profile mooremanna-uploader
```

---

## Troubleshooting

### Access Denied Error
- Verify the policy is attached to the user: `aws iam list-attached-user-policies --user-name mooremanna-uploader`
- Check the bucket name in the policy matches exactly
- Ensure the bucket policy allows the user's actions

### Invalid Credentials
- Verify the access key is active: `aws iam list-access-keys --user-name mooremanna-uploader`
- Check that you're using the correct access key and secret

### Cannot Delete Files
- Verify the bucket doesn't have versioning enabled with delete protection
- Check if there's a bucket policy preventing deletions
- Ensure the policy includes "s3:DeleteObject" permission

---

## Revoking Access

If you need to remove access for this user:

```bash
# Deactivate access key
aws iam update-access-key --user-name mooremanna-uploader --access-key-id ACCESS-KEY-ID --status Inactive

# Delete access key
aws iam delete-access-key --user-name mooremanna-uploader --access-key-id ACCESS-KEY-ID

# Detach policy
aws iam detach-user-policy --user-name mooremanna-uploader --policy-arn POLICY-ARN

# Delete user
aws iam delete-user --user-name mooremanna-uploader
```

---

## Alternative: Using IAM Roles (More Secure)

If you're running scripts from an EC2 instance or Lambda function, use IAM roles instead of access keys:

1. Create an IAM role with the same policy
2. Attach the role to your EC2 instance or Lambda function
3. No need to manage access keys!

This is more secure because credentials are automatically rotated and never exposed.


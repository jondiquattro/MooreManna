# Deploying Moore Manna Website to Amazon S3

## Prerequisites
- AWS Account
- AWS CLI installed and configured (optional but recommended)

## Step-by-Step Deployment Guide

### Option 1: Using AWS Console (Web Interface)
http://mooremanna.org.s3-website-us-east-1.amazonaws.com

#### 1. Create an S3 Bucket
1. Log in to AWS Console at https://console.aws.amazon.com/s3/
2. Click "Create bucket"
3. Choose a unique bucket name (e.g., `mooremanna-website`)
4. Select your preferred AWS Region
5. **Uncheck** "Block all public access" (we need public access for website hosting)
6. Acknowledge the warning about public access
7. Click "Create bucket"

#### 2. Enable Static Website Hosting
1. Click on your newly created bucket
2. Go to the "Properties" tab
3. Scroll down to "Static website hosting"
4. Click "Edit"
5. Select "Enable"
6. Set Index document: `index.html`
7. Set Error document: `index.html` (optional)
8. Click "Save changes"
9. **Note the bucket website endpoint URL** (e.g., `http://mooremanna-website.s3-website-us-east-1.amazonaws.com`)

#### 3. Set Bucket Policy for Public Access
1. Go to the "Permissions" tab
2. Scroll to "Bucket policy"
3. Click "Edit"
4. Paste the following policy (replace `YOUR-BUCKET-NAME` with your actual bucket name):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```

5. Click "Save changes"

#### 4. Upload Your Website Files
1. Go to the "Objects" tab
2. Click "Upload"
3. Click "Add files" and select `index.html`
4. Click "Add folder" and select the `resources` folder
5. Click "Upload"
6. Wait for the upload to complete

#### 5. Access Your Website
- Your website will be available at the endpoint URL from Step 2
- Example: `http://mooremanna-website.s3-website-us-east-1.amazonaws.com`

---

### Option 2: Using AWS CLI (Command Line)

#### 1. Install and Configure AWS CLI
```bash
# Install AWS CLI (if not already installed)
# For Ubuntu/Debian:
sudo apt-get install awscli

# For macOS:
brew install awscli

# Configure AWS CLI with your credentials
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-east-1)
# Enter default output format (json)
```

#### 2. Create S3 Bucket
```bash
# Replace 'mooremanna-website' with your desired bucket name
# Replace 'us-east-1' with your preferred region
aws s3 mb s3://mooremanna-website --region us-east-1
```

#### 3. Upload Website Files
```bash
# Navigate to your website directory
cd /home/jon/workspace/mooremanna

# Sync all files to S3
aws s3 sync . s3://mooremanna-website --exclude ".git/*" --exclude "*.md"
```

#### 4. Enable Static Website Hosting
```bash
aws s3 website s3://mooremanna-website --index-document index.html
```

#### 5. Set Bucket Policy
Create a file named `bucket-policy.json` with the following content (replace YOUR-BUCKET-NAME):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```

Then apply it:
```bash
aws s3api put-bucket-policy --bucket mooremanna-website --policy file://bucket-policy.json
```

#### 6. Make Bucket Publicly Accessible
```bash
aws s3api delete-public-access-block --bucket mooremanna-website
```

---

## Updating Your Website

### Using AWS Console:
1. Go to your S3 bucket
2. Select the files you want to update
3. Click "Upload" and select new files
4. Confirm to replace existing files

### Using AWS CLI:
```bash
# Sync updated files (only uploads changed files)
cd /home/jon/workspace/mooremanna
aws s3 sync . s3://mooremanna-website --exclude ".git/*" --exclude "*.md"
```

---

## Setting Up a Custom Domain (Optional)

### 1. Register a Domain
- Use Route 53, GoDaddy, Namecheap, or any domain registrar

### 2. Configure Route 53 (if using AWS)
1. Create a hosted zone for your domain
2. Create an A record alias pointing to your S3 bucket
3. Update your domain's nameservers to AWS nameservers

### 3. Update S3 Bucket Name
- Your bucket name must match your domain name (e.g., `www.mooremanna.org`)

---

## Using CloudFront for HTTPS (Recommended for Production)

For HTTPS support and better performance:

1. Create a CloudFront distribution
2. Set origin to your S3 bucket website endpoint
3. Request an SSL certificate from AWS Certificate Manager
4. Configure CloudFront to use the certificate
5. Update your DNS to point to CloudFront distribution

---

## Costs

S3 Static Website Hosting is very affordable:
- Storage: ~$0.023 per GB/month
- Data transfer: First 1 GB/month is free, then ~$0.09 per GB
- Requests: ~$0.0004 per 1,000 GET requests

For a small website like this, expect **less than $1-5 per month**.

---

## Important Notes

1. **Security**: Your bucket policy makes all files publicly readable. Don't upload sensitive information.
2. **Cache**: Browsers may cache your files. Use Ctrl+F5 to force refresh when testing updates.
3. **File Names**: Ensure all file paths in your HTML match the uploaded file structure (case-sensitive).
4. **Image Files**: Make sure the `resources` folder contains all referenced images:
   - workingbanner.png
   - largestbanner.png (for screens wider than 1330px)
   - IMG_1914.JPG
   - IMG_0733.jpg

---

## Troubleshooting

### Website shows 403 Forbidden
- Check bucket policy is correctly set
- Verify public access block is disabled
- Ensure files are uploaded correctly

### Images not loading
- Check file names match exactly (case-sensitive)
- Verify resources folder structure is maintained
- Check browser console for 404 errors

### Changes not appearing
- Clear browser cache (Ctrl+F5)
- Check if files were actually uploaded/updated
- Wait a few minutes for S3 to propagate changes

---

## Quick Deploy Script

See `deploy-s3.sh` for an automated deployment script.


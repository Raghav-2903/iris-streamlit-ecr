# End-to-end: Trained ML model → Streamlit UI → Docker → Amazon ECR → EC2

This repo is a minimal, working template. It includes:
- `model.pkl` (a trained scikit-learn LogisticRegression on Iris)
- `app.py` (Streamlit UI that loads `model.pkl`)
- `requirements.txt`
- `Dockerfile` and `.dockerignore`
- `deploy_to_ecr.sh` (build, tag, push image to ECR)
- `run_on_ec2.sh` (pull and run the image on an EC2 instance)

## 0) Prereqs
- Python 3.11+ (locally, optional)
- Docker Desktop/Engine (locally, required to build)
- AWS CLI v2 configured (`aws configure`), with permissions for ECR & EC2
- An EC2 instance with a Security Group allowing inbound TCP on the port you expose (80 or 8501)

## 1) Run locally (optional)
```bash
pip install -r requirements.txt
streamlit run app.py
# -> http://localhost:8501
```

Dockerized locally:
```bash
docker build -t iris-streamlit:v1 .
docker run -p 8501:8501 iris-streamlit:v1
# -> http://localhost:8501
```

## 2) Push the image to Amazon ECR
Edit the top of `deploy_to_ecr.sh` with your **AWS_REGION**, **AWS_ACCOUNT_ID**, **ECR_REPO_NAME**, **IMAGE_TAG** (or export env vars before running). Then:
```bash
./deploy_to_ecr.sh
# Outputs: 111122223333.dkr.ecr.ap-south-1.amazonaws.com/iris-streamlit:v1
```

## 3) Run on EC2
SSH into your EC2 (Amazon Linux 2023 recommended), ensure AWS CLI is configured (instance profile or `aws configure`), then:
```bash
./run_on_ec2.sh
# Installs Docker if missing, logs into ECR, pulls the image,
# and runs it mapping host port 80 -> container 8501.
# Ensure your Security Group allows inbound 80 (or whichever you expose).
```

If you prefer port 8501:
```bash
PORT_ON_EC2=8501 ./run_on_ec2.sh
# open 8501 in the Security Group
```

## 4) Handy AWS CLI snippets
Create ECR repo (one-time):
```bash
aws ecr create-repository   --repository-name iris-streamlit   --image-scanning-configuration scanOnPush=true   --region ap-south-1
```

Login to ECR:
```bash
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 111122223333.dkr.ecr.ap-south-1.amazonaws.com
```

Tag & push:
```bash
docker tag iris-streamlit:v1 111122223333.dkr.ecr.ap-south-1.amazonaws.com/iris-streamlit:v1
docker push 111122223333.dkr.ecr.ap-south-1.amazonaws.com/iris-streamlit:v1
```

## 5) Notes & best practices
- Replace `model.pkl` with your own trained model (or update `app.py` to load from S3).
- Use an EC2 Instance Profile for ECR auth in production.
- For HTTPS, place the app behind an ALB or terminate TLS with Nginx on the instance.
- Consider ECS/EKS for autoscaling and rolling deployments.

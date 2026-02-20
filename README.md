# 🎵 Soundboard — Musician Directory App (with RDS Feedback)

A Python Flask app with **Amazon RDS (MySQL)** feedback system, deployed on **ECS Fargate** via a full **CI/CD pipeline**.

---

## 📁 Project Structure

```
simple-musician-app/
├── app.py               # Flask app — musicians + feedback API + RDS connection
├── requirements.txt     # flask, pymysql
├── Dockerfile           # Container definition
├── buildspec.yml        # AWS CodeBuild — build & push Docker image to ECR
├── appspec.yml          # AWS CodeDeploy — deploy to EC2/ECS
├── start_container.sh   # Start Docker container with RDS env vars
├── stop_container.sh    # Stop & clean old container
└── README.md
```

---

## 🚀 Run Locally

### Step 1 — Start a local MySQL (or use RDS endpoint directly)
```bash
# Option A: Use Docker for local MySQL
docker run -d --name mysql-local \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=musicdb \
  -p 3306:3306 mysql:8

# Option B: Skip DB locally — app will warn but still serve musicians page
```

### Step 2 — Set environment variables
```bash
export DB_HOST=localhost        # or your RDS endpoint
export DB_USER=root             # or admin
export DB_PASSWORD=root         # your password
export DB_NAME=musicdb
```

### Step 3 — Run the app
```bash
pip install -r requirements.txt
python app.py
```
Visit: **http://localhost:5000**

---

## ☁️ AWS CI/CD Setup (Step by Step)

### STEP 1 — Create Amazon RDS (MySQL)
1. Go to AWS Console → **RDS** → Create database
2. Engine: **MySQL**
3. Template: **Free tier** (for testing)
4. DB identifier: `musicdb`
5. Username: `admin`, set a strong password
6. Make sure **VPC Security Group** allows port `3306` from ECS tasks
7. Copy the **RDS Endpoint** (looks like `musicdb.xxxx.us-east-1.rds.amazonaws.com`)

### STEP 2 — Create ECR Repository
```bash
aws ecr create-repository --repository-name musician-app --region us-east-1
```

### STEP 3 — Set CodeBuild Environment Variables
In your CodeBuild project → Environment → Add these:

| Variable          | Value                        |
|-------------------|------------------------------|
| `AWS_ACCOUNT_ID`  | Your 12-digit AWS account ID |
| `AWS_DEFAULT_REGION` | e.g. `us-east-1`          |
| `IMAGE_REPO_NAME` | `musician-app`               |

### STEP 4 — Set ECS Task Definition ENV Variables
In ECS → Task Definition → Container → Environment variables:

| Variable      | Value                               |
|---------------|-------------------------------------|
| `DB_HOST`     | `your-rds-endpoint.rds.amazonaws.com` |
| `DB_USER`     | `admin`                             |
| `DB_PASSWORD` | `your-password` (use Secrets Manager 🔥) |
| `DB_NAME`     | `musicdb`                           |

> 💡 **Bonus:** Use **AWS Secrets Manager** for DB_PASSWORD instead of plain text!
> In ECS Task Definition → valueFrom → arn:aws:secretsmanager:...

### STEP 5 — Create CodePipeline
1. **Source** → GitHub (connect your repo)
2. **Build** → CodeBuild (uses `buildspec.yml`)
3. **Deploy** → CodeDeploy or ECS (uses `appspec.yml` / `imagedefinitions.json`)

### STEP 6 — Push & Deploy!
```bash
git add .
git commit -m "add RDS feedback feature"
git push
```
✅ CodePipeline auto-triggers → builds Docker image → pushes to ECR → deploys to ECS!

---

## 🌐 API Endpoints

| Method | Endpoint         | Description                        |
|--------|------------------|------------------------------------|
| GET    | `/`              | Main musician directory UI         |
| GET    | `/health`        | Health check + RDS connectivity    |
| GET    | `/api/musicians` | All musicians as JSON              |
| POST   | `/feedback`      | Submit feedback → saved to RDS     |
| GET    | `/feedbacks`     | View all feedback from RDS         |

### POST /feedback (form data)
```
name    = "John Doe"
email   = "john@example.com"
message = "Great app!"
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE feedback (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    email      VARCHAR(150)  NOT NULL,
    message    TEXT          NOT NULL,
    created_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
```
> Table is auto-created on app startup via `init_db()` — no manual SQL needed!

---

## 🛠️ Tech Stack

| Layer     | Technology                        |
|-----------|-----------------------------------|
| Backend   | Python 3.11, Flask                |
| Database  | Amazon RDS (MySQL 8), PyMySQL     |
| Container | Docker                            |
| Registry  | Amazon ECR                        |
| Compute   | ECS Fargate                       |
| CI/CD     | CodePipeline + CodeBuild + CodeDeploy |
| Secrets   | AWS Secrets Manager (recommended) |

# 🏥 Hospital Management System (Python + MySQL + Terraform + AWS)

![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)
![Flask](https://img.shields.io/badge/Flask-Web%20Framework-black.svg)
![MySQL](https://img.shields.io/badge/MySQL-Database-orange.svg)
![Docker](https://img.shields.io/badge/Docker-Containerized-blue.svg)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple.svg)
![AWS](https://img.shields.io/badge/AWS-Cloud-yellow.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## 🚀 Overview

A **cloud-native Hospital Management System** built using **Python, MySQL, Docker, and Terraform**, deployed on **AWS infrastructure**.

It demonstrates a complete **DevOps lifecycle**:
> Development → Containerization → Infrastructure as Code → Cloud Deployment

---

## 🧱 Tech Stack

💻 Backend: Python (Flask) + Gunicorn  
🐬 Database: MySQL  
🐳 Containerization: Docker & Docker Compose  
☁️ Cloud: AWS (EC2, VPC, Security Groups)  
⚙️ IaC: Terraform  
🔗 Version Control: Git & GitHub  

---

## 🏗️ Architecture


User
↓
Nginx (optional)
↓
Flask Backend (Gunicorn)
↓
MySQL Database
↓
Docker Containers
↓
AWS Infrastructure (Terraform)


---

## 📂 Project Structure


hospital-management-system-pysql-aws-terra/
│
├── backend/ # Flask App
│ ├── app.py
│ ├── requirements.txt
│ ├── Dockerfile
│ └── docker-compose.yml
│
├── terraform/ # AWS Infrastructure
│ ├── main.tf
│ ├── vpc.tf
│ ├── ec2.tf
│ └── security-group.tf
│
└── README.md


---

## ⚙️ Features

✔ Patient Management System  
✔ Doctor & Staff Records  
✔ Appointment Scheduling  
✔ MySQL Database Integration  
✔ Dockerized Microservices  
✔ AWS Infrastructure via Terraform  
✔ Scalable & Cloud Ready  

---

## 🐳 Docker Setup

```bash
docker-compose up --build

Stop containers:

docker-compose down
☁️ Terraform Deployment
terraform init
terraform validate
terraform apply
terraform destroy
▶️ Run Locally
pip install -r requirements.txt
python app.py
🔐 Environment Variables
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=yourpassword
MYSQL_DB=hospital_db
📈 Future Enhancements
☸️ Kubernetes (EKS) deployment
🔄 CI/CD pipelines (GitHub Actions / Azure DevOps)
📊 Monitoring with Prometheus & Grafana
🌐 Nginx reverse proxy
🚀 Auto scaling on AWS
👨‍💻 Author

Saibaba Kola

📌 DevOps | Cloud | AWS | Kubernetes | Terraform

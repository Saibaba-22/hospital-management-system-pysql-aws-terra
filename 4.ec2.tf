# EC2 App Server (FINAL FIXED)
resource "aws_instance" "app" {
  ami                    = "ami-05d2d839d4f73aafb"
  instance_type          = "m7i-flex.large"
  subnet_id              = aws_subnet.app_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = "ec2-key"

    root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = var.ec2_name
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("ec2-key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
        # 1. CREATE PARENT PROJECT DIRECTORY
        "sudo mkdir -p /home/ubuntu/hospital-mgmt/backend/",
        "sudo mkdir -p /home/ubuntu/hospital-mgmt/backend/app/routes",
        "sudo mkdir -p /home/ubuntu/hospital-mgmt/frontend",
        "sudo mkdir -p /home/ubuntu/hospital-mgmt/dockerf",
        "sudo mkdir -p /home/ubuntu/hospital-mgmt/kube",
        "sudo mkdir -p /var/www/hospital-mgmt",
        "sudo mkdir -p ~/docker-project/app",

        # 2. CHANGE OWNER & PERMISSIONS
        "sudo chown -R ubuntu:ubuntu /home/ubuntu/hospital-mgmt",
        "sudo chown -R ubuntu:ubuntu /home/ubuntu/hospital-mgmt/dockerf",
        "sudo chown -R www-data:www-data /var/www/hospital-mgmt",
        "sudo chmod -R 755 /var/www/hospital-mgmt",
        "sudo chmod -R 755 ~/docker-project",
        "sudo chown -R ubuntu:ubuntu ~/docker-project",
        "sudo chown -R ubuntu:ubuntu /home/ubuntu/hospital-mgmt/kube",
        "sudo chmod -R 755 /home/ubuntu/hospital-mgmt/kube",
    ]
  }

# BACKEND FILES COPY Destination: /home/ubuntu/hospital-mgmt/backend
provisioner "file" {
  source      = "./backend/app/__init__.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/app/__init__.py"
}

provisioner "file" {
  source      = "./backend/app/database.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/app/database.py"
}

provisioner "file" {
  source      = "./backend/app/routes/patients.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/app/routes/patients.py"
}

provisioner "file" {
  source      = "./backend/app/routes/doctors.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/app/routes/doctors.py"
}

provisioner "file" {
  source      = "./backend/app/routes/appointments.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/app/routes/appointments.py"
}

provisioner "file" {
  source      = "./backend/app/routes/departments.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/app/routes/departments.py"
}

provisioner "file" {
  source      = "./backend/app/routes/stats.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/app/routes/stats.py"
}

provisioner "file" {
  source      = "./backend/wsgi.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/wsgi.py"
}

provisioner "file" {
  source      = "./backend/gunicorn.conf.py"
  destination = "/home/ubuntu/hospital-mgmt/backend/gunicorn.conf.py"
}

provisioner "file" {
  source      = "./backend/requirements.txt"
  destination = "/home/ubuntu/hospital-mgmt/backend/requirements.txt"
}

provisioner "file" {
  source      = "./backend/.env"
  destination = "/home/ubuntu/hospital-mgmt/backend/.env"
}

provisioner "file" {
  source      = "./backend/Dockerfile"
  destination = "/home/ubuntu/hospital-mgmt/backend/Dockerfile"
}

# FRONTEND FILES COPY Destination : /home/ubuntu/hospital-mgmt/frontend
provisioner "file" {
  source      = "./frontend/index.html"
  destination = "/home/ubuntu/hospital-mgmt/frontend/index.html"
}

provisioner "file" {
  source      = "./frontend/config.nginx"
  destination = "/home/ubuntu/hospital-mgmt/frontend/config.nginx"
}

# FRONTEND FILES COPY Destination : /home/ubuntu/hospital-mgmt/dockerf
provisioner "file" {
  source      = "./frontend1/index.html"
  destination = "/home/ubuntu/hospital-mgmt/dockerf/index.html"
}

provisioner "file" {
  source      = "./frontend1/nginx.conf"
  destination = "/home/ubuntu/hospital-mgmt/dockerf/nginx.conf"
}

provisioner "file" {
  source      = "./frontend1/Dockerfile"
  destination = "/home/ubuntu/hospital-mgmt/dockerf/Dockerfile"
}

# Files for Kubernetes 
provisioner "file" {
  source      = "./kubernetes/backend.yaml.tpl"
  destination = "/home/ubuntu/hospital-mgmt/kube/backend.yaml"
}

provisioner "file" {
  source      = "./kubernetes/configmap.yaml"
  destination = "/home/ubuntu/hospital-mgmt/kube/config.yaml"
}

provisioner "file" {
  source      = "./kubernetes/frontend.yaml.tpl"
  destination = "/home/ubuntu/hospital-mgmt/kube/frontend.yaml"
}

provisioner "file" {
  source      = "./kubernetes/namespace.yaml"
  destination = "/home/ubuntu/hospital-mgmt/kube/namespace.yaml"
}

provisioner "file" {
  source      = "./kubernetes/network-policy.yaml"
  destination = "/home/ubuntu/hospital-mgmt/kube/network-policy.yaml"
}

provisioner "file" {
  source      = "./kubernetes/secrets.yaml"
  destination = "/home/ubuntu/hospital-mgmt/kube/secrets.yaml"
}


provisioner "remote-exec" {
  inline = [

    # UPDATE PACKAGES
    "sudo apt update -y",

    # MOVE TO BACKEND
    "cd /home/ubuntu/hospital-mgmt/backend",

    # INSTALL PYTHON + NGINX
    "sudo DEBIAN_FRONTEND=noninteractive apt install -y python3 python3-pip python3-venv python3-dev build-essential pkg-config libssl-dev libffi-dev mysql-client-core-8.0 nginx docker.io dos2unix unzip curl",

    # CREATE VENV
    "python3 -m venv venv",

    # ACTIVATE VENV + INSTALL REQUIREMENTS
    "bash -c 'source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt'",

    # EXPORT ENV VARIABLES is exported from -> backend -> .env file 

   # Create backend .env
    "echo DB_HOST=${aws_db_instance.db.address} > /home/ubuntu/hospital-mgmt/backend/.env",
    "echo DB_PORT=3306 >> /home/ubuntu/hospital-mgmt/backend/.env",
    "echo DB_NAME=${var.db_name} >> /home/ubuntu/hospital-mgmt/backend/.env",
    "echo DB_USER=${var.db_user} >> /home/ubuntu/hospital-mgmt/backend/.env",
    "echo DB_PASSWORD=${var.db_password} >> /home/ubuntu/hospital-mgmt/backend/.env",

    # Flask settings
    "echo FLASK_ENV=development >> /home/ubuntu/hospital-mgmt/backend/.env",
    "echo PORT=5000 >> /home/ubuntu/hospital-mgmt/backend/.env",

    # LOAD ENV
    "source ~/.bashrc",

    # RUN GUNICORN IN BACKGROUND
    "bash -c 'cd /home/ubuntu/hospital-mgmt/backend && source venv/bin/activate && nohup gunicorn -c gunicorn.conf.py wsgi:app > gunicorn.log 2>&1 &'",

    # MOVE TO FRONTEND
    "cd /home/ubuntu/hospital-mgmt/frontend",

    # REMOVE DEFAULT NGINX CONFIG
    "sudo rm -f /etc/nginx/sites-enabled/default",
    "sudo rm -f /etc/nginx/sites-available/default",

    # COPY NGINX CONFIG
    "sudo cp /home/ubuntu/hospital-mgmt/frontend/config.nginx /etc/nginx/sites-available/hospital-mgmt",
    "sudo cp -r /home/ubuntu/hospital-mgmt/frontend/* /var/www/hospital-mgmt/",

    # ENABLE CONFIG
    "sudo ln -sf /etc/nginx/sites-available/hospital-mgmt /etc/nginx/sites-enabled/hospital-mgmt",

    # TEST NGINX
    "sudo nginx -t",
    "sudo systemctl enable nginx",
    "sudo systemctl restart nginx",

      # Docker 
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo systemctl restart docker",
 
      # IMPORTANT: do NOT use newgrp in terraform
      "sleep 5",

      # Docker Network 
      "sudo docker network create hospital",
  
      # build python image and run container 
      "sudo docker stop backend || true",
      "sudo docker rm backend || true",
      "sudo docker build -t hospital-back /home/ubuntu/hospital-mgmt/backend",
      "sudo docker run -d --name backend --network hospital -p 5005:5000 -e DB_HOST=${aws_db_instance.db.address} -e DB_PORT=3306 -e DB_NAME=${var.db_name} -e DB_USER=${var.db_user} -e DB_PASSWORD=${var.db_password} hospital-back",

      # build docker image and run container 
      "sudo docker stop frontend || true",
      "sudo docker rm frontend || true",
      "sudo docker build -t hospital-front /home/ubuntu/hospital-mgmt/dockerf",
      "sudo docker run -d --name frontend --network hospital -p 81:80 hospital-front",

      # Rancher
      "sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged --name rancher rancher/rancher:latest",

    # AWS CLI INSTALL
    "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip",
    "unzip -o awscliv2.zip",
    "sudo ./aws/install",
    "aws --version",

    # KUBECTL INSTALL
    "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
    "chmod +x kubectl",
    "sudo mv kubectl /usr/local/bin/",
    "kubectl version --client",
    
  ]
}
}


/*

sudo apt update -y

sudo apt install -y unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install

aws --version






# Inside execute 
  provisioner "remote-exec" {
    inline = [
      "set -e",

  "sudo apt update -y",
  "sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y",

  # INSTALL PACKAGES
  "sudo DEBIAN_FRONTEND=noninteractive apt install -y python3 python3-pip python3-venv nginx git curl",

  # CREATE PROJECT DIRECTORY
  "sudo mkdir -p /home/ubuntu/hospital-mgmt",

  # CHANGE OWNER
  "sudo chown -R ubuntu:ubuntu /home/ubuntu/hospital-mgmt",

  # GO TO HOME
  "cd /home/ubuntu",

  # CLONE PROJECT
  "git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git hospital-mgmt || true",

  # VERIFY FILES
  "ls -la /home/ubuntu/hospital-mgmt/backend",

  # CREATE ENV FILE
  "echo 'MYSQL_HOST=${aws_db_instance.db.endpoint}' > /home/ubuntu/hospital-mgmt/backend/.env",
  "echo 'MYSQL_DB=${var.db_name}' >> /home/ubuntu/hospital-mgmt/backend/.env",
  "echo 'MYSQL_USER=${var.db_user}' >> /home/ubuntu/hospital-mgmt/backend/.env",
  "echo 'MYSQL_PASSWORD=${var.db_password}' >> /home/ubuntu/hospital-mgmt/backend/.env",
  "echo 'MYSQL_PORT=3306' >> /home/ubuntu/hospital-mgmt/backend/.env",

  # MOVE TO BACKEND
  "cd /home/ubuntu/hospital-mgmt/backend",

  # REMOVE OLD VENV
  "rm -rf venv",

  # CREATE NEW VENV
  "python3 -m venv venv",

  # UPGRADE PIP
  "./venv/bin/pip install --upgrade pip",

  # INSTALL REQUIREMENTS
  "./venv/bin/pip install -r requirements.txt",

  # VERIFY FLASK
  "./venv/bin/pip list | grep Flask",

  # STOP OLD GUNICORN
  "pkill gunicorn || true",

  # START GUNICORN
  "nohup ./venv/bin/gunicorn --workers 5 --bind 0.0.0.0:5000 wsgi:app > backend.log 2>&1 &",

    # NGINX CONFIGURATION
    "sudo cp /home/ubuntu/hospital-mgmt/frontend/nginx.conf /etc/nginx/sites-available/hms",
    "sudo ln -sf /etc/nginx/sites-available/hms /etc/nginx/sites-enabled/hms",
    "sudo rm -f /etc/nginx/sites-enabled/default",
    "sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup",
    "sudo cp /home/ubuntu/hospital-mgmt/frontend/nginx.conf /etc/nginx/conf.d/hospital.conf",

    # TEST NGINX
    "sudo nginx -t",

    # ENABLE + RESTART NGINX
    "sudo systemctl enable nginx",
    "sudo systemctl restart nginx",

    # INSTALL AZURE CLI (NON-INTERACTIVE)
    "curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null",
    "AZ_REPO=$(lsb_release -cs) && echo \"deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main\" | sudo tee /etc/apt/sources.list.d/azure-cli.list",
    "sudo apt update -y",
    "sudo DEBIAN_FRONTEND=noninteractive apt install -y azure-cli",

    # VERIFY AZURE CLI
    "az version",

    # INSTALL KUBECTL (NON-INTERACTIVE)
    "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
    "chmod +x kubectl",

    "sudo mv kubectl /usr/local/bin/",

    # VERIFY KUBECTL
    "kubectl version --client",

    # INSTALL DOCKER
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
    "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt update -y",
    "sudo DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io",
    "sudo systemctl enable docker",
    "sudo systemctl start docker",

    # INSTALL RANCHER USING DOCKER
    "sudo docker run -d --restart=unless-stopped --privileged -p 8080:80 -p 445:443 --name rancher rancher/rancher:latest",

    # VERIFY RANCHER CONTAINER
    "sudo docker ps"

  ]
}
}
*/

# 📦 Inventory Manager Project (DevOps)

## 1️⃣ Project Overview
- **Application:** Inventory Manager  
- **Tech Stack:** Python (Flask), HTML, Docker, Docker Compose, Terraform, Jenkins  
- **Purpose:** Manage inventory by adding, editing, and updating items with quantities & prices.  
- **Execution:** Runs on `http://localhost:5000` after starting Flask or Docker container.  

---

## 2️⃣ Project Structure
```
.
├── Dockerfile
├── Jenkinsfile
├── LICENSE
├── README.md
├── app
│   ├── main.py
│   ├── requirements.txt
│   └── templates
│       ├── add_item.html
│       ├── edit_item.html
│       ├── index.html
│       └── layout.html
├── docker-compose.yml
├── jenkins-install.sh
├── k8s
│   └── staging-deployment.yaml
└── terraform
    ├── eks.tf
    ├── outputs.tf
    ├── provider.tf
    ├── variables.tf
    ├── versions.tf
    └── vpc.tf
```

---

## 3️⃣ Local Setup
1. Clone the repository.  
2. Navigate to application folder (`app/`).  
3. Open `main.py` and `index.html`.  
4. Install Flask:  
   ```bash
   pip install flask
   ```
5. Run locally:  
   ```bash
   python3 main.py
   ```
6. Access app via → [http://localhost:5000](http://localhost:5000).  

---

## 4️⃣ Docker Setup
- Install Docker:  
  ```bash
  sudo yum install docker -y
  sudo systemctl start docker
  sudo systemctl enable docker
  ```
- Build image:  
  ```bash
  sudo docker build -t <image_name> .
  ```
- List images:  
  ```bash
  sudo docker images
  ```
- Run container:  
  ```bash
  sudo docker run -d -p 5000:5000 <image_name>
  ```
- Logs & Management:  
  ```bash
  sudo docker logs <container_id>
  sudo docker container ls
  sudo docker container stop <container_id>
  ```

---

## 5️⃣ Docker Compose
- Install Docker Compose plugin:  
  ```bash
  sudo mkdir -p /usr/local/lib/docker/cli-plugins
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64     -o /usr/local/lib/docker/cli-plugins/docker-compose
  sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  docker compose version
  ```
- Start app with Compose:  
  ```bash
  sudo docker compose up --build
  ```
- Configuration managed via `docker-compose.yml`.  

---

## 6️⃣ Common Issues & Fixes
- **Port conflict (5000 already in use):**  
  ```bash
  sudo docker ps
  sudo docker stop <id>
  ```
- **Permission denied with Docker:**  
  Run with `sudo` or add user to `docker` group.  
- **Old Docker Compose version:**  
  Re-install updated plugin.  
- **Git push errors (README/LICENSE conflicts):**  
  ```bash
  git pull --allow-unrelated-histories
  git add .
  git commit -m "resolved conflicts"
  git push origin main
  ```
  Or overwrite remote:  
  ```bash
  git push origin main --force
  ```

---

## 7️⃣ Git Workflow Notes
- Clone friend’s repo → reconfigure origin to your own GitHub repo.  
- If repo was created with README & License → resolve non-fast-forward errors.  
- Options:  
  - Pull with `--allow-unrelated-histories` then push.  
  - Or force push to overwrite.  

---

## 🚀 Workflow Diagram

```mermaid
flowchart TD
    A[👨‍💻 Local Development<br>(Flask App)] --> B[🐳 Docker<br>Build & Run Image]
    B --> C[🧩 Docker Compose<br>Multi-container Setup]
    C --> D[📂 GitHub Repo<br>Code + CI/CD]
    D --> E[🚀 Jenkins / Terraform / K8s<br>Deployment]
```

---

## Author
**Avinash Tale**  
GitHub: [AvinashTale99](https://github.com/AvinashTale99)  
Email: aatale99@gmail.com


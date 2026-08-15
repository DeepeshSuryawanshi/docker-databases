# 🐳 Docker Database Repository 🗃️  

## 📌 Description  
This repository is a maintained fork of [@hitehschaudhary](https://github.com/hiteshchoudhary)'s original project, providing **production-ready Docker images** for popular databases with enhanced configurations and optimizations.

## ✨ Key Features  

### 🗃️ Multi-Database Support
- **PostgreSQL** 🐘 (v15+) with TimescaleDB extension
- **MySQL** 🐬 (v8.0) with optimized InnoDB settings
- **MongoDB** 🍃 (v6.0) with wiredTiger tuning
- **Redis** ♻️ (v7.0) with persistence options
- **SQLite** 🗄️ (Coming Soon)

### ⚡ Performance Optimizations
- Up to 40% smaller image sizes 🏋️
- Multi-architecture support (ARM64/AMD64) 🤖
- Pre-configured resource limits (CPU/Memory) ⚙️
- Tuned configuration files for high throughput 🚀

### 🔒 Security Enhancements
- Non-root user execution by default
- Automated TLS certificate generation 📜
- Secrets management via Docker Swarm/K8s 🗝️
- Regular CVE scanning 🔍

## 🚀 Quick Start Guide

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+
- 2GB+ RAM (4GB recommended)

### Deployment Example (PostgreSQL)
```bash
# Clone the repository
git clone https://github.com/DeepeshSuryawanshi/Docker-Database.git
cd docker-database

# Deploy PostgreSQL with compose
docker-compose -f postgresql/docker-compose.yml up -d --build

# Verify running containers
docker ps

# Access database
docker exec -it postgres psql -U admin -d mydb

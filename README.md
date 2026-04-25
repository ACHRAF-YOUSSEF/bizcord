# 💬 BizCord

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.10-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Angular](https://img.shields.io/badge/Angular-21-DD0031?logo=angular&logoColor=white)](https://angular.dev/)
[![mediasoup](https://img.shields.io/badge/mediasoup-v3-ff6600)](https://mediasoup.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker%20Compose-ready-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[![GitHub](https://img.shields.io/badge/GitHub-ACHRAF--YOUSSEF-181717?logo=github)](https://github.com/ACHRAF-YOUSSEF)
[![Portfolio](https://img.shields.io/badge/Portfolio-achraf--youssef.github.io-0A66C2)](https://achraf-youssef.github.io/portfolio/)

> A full-stack, self-hosted Discord-like team communication platform — real-time messaging, voice/video channels, direct messages, and server management, all deployable with a single `docker compose up`.

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Architecture](#️-architecture)
- [Services](#-services)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Setup Guide](#-setup-guide)
- [Environment Variables Reference](#-environment-variables-reference)
- [Port Reference](#-port-reference)
- [Docker Images](#-docker-images)
- [Screenshots](#-screenshots)
- [Author](#-author)

---

## 🔭 Overview

BizCord is a self-hosted, full-featured team communication platform inspired by Discord. It supports:

- **Real-time text messaging** in server channels and direct messages
- **Voice & video channels** powered by a WebRTC Selective Forwarding Unit (mediasoup v3)
- **Server & channel management** with drag-and-drop ordering, invite links, and member roles
- **Email verification** on registration and a full forgot/reset password flow
- **File uploads**, emoji reactions, typing indicators, user status, message search, and notifications

The entire stack runs in Docker Compose — four containers, one command.

---

## 🏗️ Architecture

```
Browser Client
  │
  ▼
bizcord-frontend (nginx:8080)
  ├── /           → Angular SPA (static files)
  ├── /api/*      → reverse proxy → bizcord-backend:8080
  ├── /ws         → WS proxy      → bizcord-backend:8080 (STOMP)
  └── /uploads/*  → reverse proxy → bizcord-backend:8080 (media files)
  
bizcord-backend (Spring Boot:8080)
  ├── REST API   → JWT auth, resource CRUD, file uploads
  ├── STOMP WS   → real-time messages, typing, notifications
  └── REST calls → bizcord-mediasoup:3000 (voice room orchestration)
  
bizcord-mediasoup (Bun:3000)
  └── WebRTC SFU → UDP/TCP 52000–52999 (direct browser ↔ SFU)
  
bizcord-postgres (PostgreSQL 17:5432)
  └── Persistent data volume
```

---

## 📦 Services

| Service | Image | Internal Port | Description |
|---|---|---|---|
| Frontend | `achrafyoussef/bizcord-frontend` | 8080 | Angular SPA + nginx reverse proxy |
| Backend | `achrafyoussef/bizcord-backend` | 8080 | Spring Boot REST API + WebSocket |
| Mediasoup | `achrafyoussef/bizcord-mediasoup` | 3000 | mediasoup v3 WebRTC SFU |
| PostgreSQL | `postgres:17.9-alpine3.23` | 5432 | Relational database |

---

## ✨ Features

- **Authentication** — Register / login / logout with JWT access tokens; refresh tokens stored in HttpOnly cookies for passive token rotation
- **Email Verification** — Confirmation email on registration; account activation via link; resend endpoint
- **Password Reset** — Forgot-password flow with time-limited reset link sent by email
- **Servers** — Create and manage servers, invite members via shareable links
- **Text Channels** — Real-time message delivery, edits, deletes, pagination
- **Channel Categories** — Collapsible categories with drag-and-drop ordering
- **Direct Messages** — Private 1-to-1 conversations
- **Voice & Video Channels** — WebRTC-powered with mic, camera, and screen sharing via mediasoup SFU
- **File Uploads** — Images and attachments (up to 4 MB) in messages; custom server icons and profile avatars
- **Emoji Reactions** — React to any message
- **Typing Indicators** — Live presence in channels and DMs
- **User Status** — Online, Idle, Do Not Disturb, and Invisible statuses with persistent preferred status
- **Notifications** — Real-time in-app notification feed
- **Message Search** — Full-text search across a server's channels
- **Rate Limiting** — Per-endpoint throttling via Bucket4j

---

## ✅ Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Docker Engine | ≥ 24.x | [Install Docker](https://docs.docker.com/engine/install/) |
| Docker Compose | ≥ 2.x | Included in Docker Desktop |
| Git | Any | [Install Git](https://git-scm.com/) |

> No local JDK or Node.js needed — everything runs in containers.

---

## 🚀 Setup Guide

### 1. Clone the repository

```bash
git clone https://github.com/ACHRAF-YOUSSEF/bizcord.git
cd bizcord
```

### 2. Create an environment file

```bash
cp bizcord-backtend/.env.example bizcord-backtend/.env
```

Edit `bizcord-backtend/.env` and fill in your values (see [Environment Variables Reference](#-environment-variables-reference)).

### 3. Start the stack

```bash
cd bizcord-backtend
docker compose --env-file=.env up -d
```

### 4. Open the app

Navigate to [http://localhost:8080](http://localhost:8080) and register your first account.

### 5. Check status

```bash
docker compose ps
docker compose logs -f
```

### 6. Stop the stack

```bash
# Stop without removing data
docker compose down

# Stop and wipe the database
docker compose down -v
```

---

## 🔑 Environment Variables Reference

Create `bizcord-backtend/.env`:

```bash
# ── Auth ─────────────────────────────────────────────────────────────
# Strong random string used to sign JWTs. Generate with:
#   openssl rand -hex 64
APP_JWT_SECRET_KEY=

# ── Cookie ───────────────────────────────────────────────────────────
# Set to "false" when running on plain HTTP (http://localhost)
# Set to "true" when running behind HTTPS in production
APP_COOKIE_SECURE=false

# ── CORS ─────────────────────────────────────────────────────────────
# The origin(s) the browser connects from (comma-separated)
APP_CORS_ALLOWED_ORIGIN_PATTERNS=http://localhost:8080

# ── Mediasoup ────────────────────────────────────────────────────────
# Shared secret between backend and mediasoup containers
MEDIASOUP_API_SECRET=

# Public IP of this machine — browsers use this for WebRTC ICE candidates
# Use 127.0.0.1 for local testing; replace with real IP for LAN/internet
MEDIASOUP_ANNOUNCED_IP=127.0.0.1

# WebRTC media port range (must be open in your firewall/router for voice)
MEDIASOUP_RTC_MIN_PORT=52000
MEDIASOUP_RTC_MAX_PORT=52999
```

> **Security:** Never commit `.env` to version control. Add it to `.gitignore`.

### Full variable listing

| Variable | Used by | Default | Description |
|---|---|---|---|
| `APP_JWT_SECRET_KEY` | backend | `bizcord-secret-key` | JWT HS256 signing key |
| `APP_COOKIE_SECURE` | backend | `true` | `true` for HTTPS, `false` for HTTP |
| `APP_CORS_ALLOWED_ORIGIN_PATTERNS` | backend | `https://bizcord.achrafyoussef.tech` | Allowed CORS origins |
| `MEDIASOUP_API_SECRET` | backend + mediasoup | `bizcord-mediasoup-secret` | Shared secret between services |
| `MEDIASOUP_ANNOUNCED_IP` | mediasoup | `127.0.0.1` | Public IP for WebRTC ICE |
| `MEDIASOUP_RTC_MIN_PORT` | mediasoup | `52000` | RTC port range start |
| `MEDIASOUP_RTC_MAX_PORT` | mediasoup | `52999` | RTC port range end |
| `MAIL_HOST` | backend | `localhost` | SMTP server hostname |
| `MAIL_PORT` | backend | `1025` | SMTP server port |
| `MAIL_USERNAME` | backend | — | SMTP username |
| `MAIL_PASSWORD` | backend | — | SMTP password |
| `MAIL_SMTP_AUTH` | backend | `false` | Enable SMTP authentication |
| `MAIL_SMTP_STARTTLS` | backend | `false` | Enable STARTTLS |
| `MAIL_FROM` | backend | `noreply@bizcord.achrafyoussef.tech` | Sender address for outgoing emails |
| `APP_FRONTEND_URL` | backend | `https://bizcord.achrafyoussef.tech` | Base URL embedded in verification/reset email links |

---

## 🔌 Port Reference

| Port | Protocol | Service | Description |
|---|---|---|---|
| `8080` | TCP | Frontend | Main app entry point (nginx) |
| `5432` | TCP | PostgreSQL | Database (exposed for local dev only — remove in production) |
| `52000–52999` | UDP | Mediasoup | WebRTC media transport — must be reachable by browser clients |
| `52000–52999` | TCP | Mediasoup | WebRTC media transport fallback |

> Ports `3000` (mediasoup API) and `8080` (backend API) are **internal only** — accessed via the nginx proxy or Docker internal networking.

---

## 🐳 Docker Images

| Image | Docker Hub |
|---|---|
| `achrafyoussef/bizcord-backend` | [hub.docker.com/r/achrafyoussef/bizcord-backend](https://hub.docker.com/r/achrafyoussef/bizcord-backend) |
| `achrafyoussef/bizcord-frontend` | [hub.docker.com/r/achrafyoussef/bizcord-frontend](https://hub.docker.com/r/achrafyoussef/bizcord-frontend) |
| `achrafyoussef/bizcord-mediasoup` | [hub.docker.com/r/achrafyoussef/bizcord-mediasoup](https://hub.docker.com/r/achrafyoussef/bizcord-mediasoup) |

Each sub-project contains its own `README.md` and `DOCKER_HUB.md` with detailed documentation.

---

## 📸 Screenshots

> Screenshots coming soon.

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=ACHRAF-YOUSSEF/bizcord&type=Date)](https://star-history.com/#ACHRAF-YOUSSEF/bizcord&Date)

---

## 👨‍💻 Author

**Achraf Youssef**  
Engineering Student at ISITCOM | Software Engineering & Computer Systems

[![GitHub](https://img.shields.io/badge/GitHub-ACHRAF--YOUSSEF-181717?logo=github)](https://github.com/ACHRAF-YOUSSEF)
[![Portfolio](https://img.shields.io/badge/Portfolio-achraf--youssef.github.io-0A66C2)](https://achraf-youssef.github.io/portfolio/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-achraf--youssef-0077B5?logo=linkedin)](https://www.linkedin.com/in/achraf-youssef/)
[![Twitter](https://img.shields.io/badge/Twitter-@achrafYoussef__-1DA1F2?logo=twitter&logoColor=white)](https://twitter.com/achrafYoussef_)

If this project helped you, consider leaving a ⭐ — it means a lot!

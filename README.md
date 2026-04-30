# 📦 Delivery System — Grails

A full-stack delivery management web application built with **Grails 6**, **PostgreSQL**, and **HashiCorp Vault**. It features role-based access control, encrypted coordinate storage, REST API with token authentication, data minimization, bulk CSV import/export, and an AI-powered location insight engine.

---

## ✨ Features

- 🔐 **Role-based authentication** — `ADMIN` and `USER` roles with URL-level security
- 🗺️ **Encrypted location storage** — GPS coordinates encrypted at rest using AES via pgcrypto
- 🔑 **HashiCorp Vault integration** — encryption keys fetched securely at runtime via AppRole
- 📡 **REST API (v1 & v2)** — token-authenticated endpoints for locations, warehouses, delivery points, and assignments
- 📊 **Admin dashboard** — live stats, high-priority delivery points, and warehouse capacity
- 📁 **Bulk CSV import/export** — import locations in bulk; export decrypted Excel sheets
- 🧹 **Data minimization** — automatic anonymization of inactive users and purging of stale tokens
- 🧪 **Encryption benchmark** — startup benchmark comparing 2-column vs 4-column encrypted storage
- 🤖 **AI location insights** — Claude-powered natural language insights per location
- 📋 **API request logging** — all API calls logged with masked IPs and truncated tokens

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Grails 6 (Groovy / Spring Boot) |
| Database | PostgreSQL 16 with pgcrypto |
| Secret Management | HashiCorp Vault (AppRole auth) |
| ORM | GORM / Hibernate 5 |
| Frontend | GSP views, Bootstrap 5, Bootstrap Icons |
| Security | Spring Security Crypto, custom interceptors |
| Build | Gradle 8 |
| Java | Java 17 |

---

## 📋 Prerequisites

Make sure the following are installed before you start:

- **Java 17** — [Download](https://adoptium.net/)
- **Docker & Docker Compose** — [Download](https://www.docker.com/)
- **HashiCorp Vault** — [Download](https://developer.hashicorp.com/vault/downloads)

---

## 🚀 Running the Full App

Follow these steps **in order**: Database → Vault → App.

---

### Step 1 — Start the PostgreSQL Database

The database runs in Docker. From the project root:

```bash
cd delivery-pgcrypto
docker compose up -d
```

This starts a PostgreSQL 16 container with:

| Setting | Value |
|---|---|
| Host | `localhost` |
| Port | `5433` |
| Database | `deliverydb` |
| Username | `postgres` |
| Password | `postgres` |

Verify it's running:

```bash
docker ps
# You should see: pgdb_delivery
```

> **Note:** The `delivery-pgcrypto/data/` directory holds the persistent database volume. Do **not** commit this folder to GitHub — it is already in `.gitignore`.

---

### Step 2 — Start and Configure HashiCorp Vault

#### 2a. Start Vault in development mode

```bash
vault server -dev -dev-root-token-id="root"
```

Leave this terminal open. Vault will run on `http://127.0.0.1:8200`.

#### 2b. In a new terminal, configure Vault

Export the root token:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'
```

Enable the AppRole auth method:

```bash
vault auth enable approle
```

Create a policy for the app using the provided policy file:

```bash
vault policy write delivery-policy delivery-policy.hcl
```

Create the AppRole:

```bash
vault write auth/approle/role/delivery-app \
    token_policies="delivery-policy" \
    token_ttl=1h \
    token_max_ttl=4h
```

Store the encryption key in Vault:

```bash
vault kv put secret/delivery-app/encryption-key \
    value=b15217c752d2fa421084c1694ca7113f69b63602ae2b8a244319d76e96bb79c4
```

> **Tip:** In development you can use the default `devKey` in `application.yml` instead of Vault by commenting out the Vault config. For production, always use Vault.

#### 2c. Fetch your AppRole credentials

```bash
# Get Role ID
vault read auth/approle/role/delivery-app/role-id

# Generate Secret ID
vault write -f auth/approle/role/delivery-app/secret-id
```

Save the `role_id` and `secret_id` — you will need them in the next step.

---

### Step 3 — Set Environment Variables

The app reads Vault credentials from environment variables. Set them in your terminal before starting:

```bash
export VAULT_ROLE_ID=<your-role-id>
export VAULT_SECRET_ID=<your-secret-id>
```

On Windows (Command Prompt):

```cmd
set VAULT_ROLE_ID=<your-role-id>
set VAULT_SECRET_ID=<your-secret-id>
```

---

### Step 4 — Run the Application

#### Option A — Quick start script (auto-opens Chrome)

```bash
chmod +x start.sh
./start.sh
```

This starts Grails on port `8080`, waits for it to be ready, then opens `http://localhost:8080/login` in Chrome automatically.

You can also specify a custom port:

```bash
./start.sh 9090
```

#### Option B — Standard Grails command

```bash
./grailsw run-app
```

Then open your browser at: **http://localhost:8080/login**

---

### Step 5 — Log In

On first startup, BootStrap seeds two default users:

| Username | Password | Role |
|---|---|---|
| `admin` | `admin123` | ADMIN — full access |
| `user` | `user123` | USER — read-only access |

> **Security reminder:** Change these passwords immediately in any non-development environment.

---

## 🔑 API Authentication

The REST API uses static bearer tokens. On first startup, tokens are printed to the console:

```
>>> TEST TOKEN CREATED: my-test-token-abc123
================ API TOKENS ================
Token 1 (plain, use in Bruno): <uuid>
Token 2 (plain, use in Bruno): <uuid>
```

Use the token in your requests:

```bash
curl -H "X-Auth-Token: my-test-token-abc123" http://localhost:8080/api/v2/locations
```

---

## 📡 REST API Endpoints

### Locations
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v2/locations` | List all locations |
| GET | `/api/v1/locations` | List locations (legacy v1) |

### Warehouses
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/warehouses` | List all warehouses |
| POST | `/api/warehouses` | Create a warehouse |
| PUT | `/api/warehouses/{id}` | Update a warehouse |
| DELETE | `/api/warehouses/{id}` | Delete a warehouse |

### Delivery Points
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/deliveryPoints` | List all delivery points |
| POST | `/api/deliveryPoints` | Create a delivery point |
| PUT | `/api/deliveryPoints/{id}` | Update a delivery point |
| DELETE | `/api/deliveryPoints/{id}` | Delete a delivery point |

### Delivery Assignments
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/deliveryAssignments` | List all assignments |
| POST | `/api/deliveryAssignments` | Create an assignment |

### Admin
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v2/admin/logs` | View API request logs |
| GET | `/api/health` | Health check |

---

## 📁 Project Structure

```
delivery-system-grails/
├── grails-app/
│   ├── conf/
│   │   ├── application.yml        # Main config (DB, Vault, Spring)
│   │   └── application.groovy     # Upload size limits
│   ├── controllers/               # Web + API controllers
│   ├── domain/                    # GORM domain classes
│   ├── services/                  # Business logic services
│   ├── views/                     # GSP templates (Bootstrap UI)
│   └── init/
│       └── BootStrap.groovy       # DB seed data & startup tasks
├── delivery-pgcrypto/
│   ├── docker-compose.yml         # PostgreSQL Docker setup
│   └── data/                      # DB volume (not committed)
├── delivery-policy.hcl            # Vault policy definition
├── start.sh                       # Quick-start script
└── build.gradle                   # Gradle dependencies
```

---

## 🔒 Security Notes

- Encryption keys are **never** stored in the codebase in production — always use Vault
- Coordinates are encrypted using AES-256 via PostgreSQL's `pgcrypto` extension
- API tokens are stored hashed; plaintext tokens are only printed once at creation time
- IPs in API logs are masked; tokens are truncated before storage
- Inactive users are automatically anonymized on a scheduled basis

---

## 🐳 GitHub Setup Tips

Before pushing to GitHub, make sure your `.gitignore` excludes:

```
delivery-pgcrypto/data/   # PostgreSQL data volume
.gradle/
build/
*.DS_Store
```

The project already has a `.gitignore` — verify it covers the `data/` folder before your first commit.

---

## 📄 License

This project is for educational and demonstration purposes.

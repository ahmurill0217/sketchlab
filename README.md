# **SketchLab**

## **I. Overview**

This project provides a robust, standardized development environment powered by Docker, with a dynamic setup system using a Makefile. This boilerplate includes:

- **Next.js frontends**: Client application and/or Admin dashboard
- **FastAPI backend**: RESTful API with automatic documentation
- **PostgreSQL database**: Persistent data storage
- **Flexible service combinations**: Choose exactly what you need
- **Containerized services** with project-specific naming
- **Guided setup** via interactive prompts
- **CI/CD Integration**: Automated Azure Container Apps deployment

### **Tech Stack**

- **Frontend**: [Next.js](https://nextjs.org/) (React + Typescript)
- **Backend**: [FastAPI](https://fastapi.tiangolo.com/) (Python)
- **API Documentation**: Swagger UI (`/docs` endpoint)
- **Database**: PostgreSQL
- **Containerization**: Docker & Docker Compose
- **Infrastructure Setup**: Makefile-based automation

## **II. Getting Started**

### **Prerequisites**

Ensure you have the following installed:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)
- [Node.js](https://nodejs.org/): Required for running the frontend
- [npm](https://www.npmjs.com/): Comes with Node.js; make sure it's installed for managing frontend dependencies
- `envsubst`: Used to inject project variables into Docker and env templates
  - **macOS users:** install via [Homebrew](https://brew.sh/):
    ```bash
    brew install gettext
    ```

### **Setup Workflow (via Makefile)**

All commands are **guided with interactive prompts**. Just run the command and follow the menu:

#### **1. Initialize New Project**

```bash
make init
```

Guided project initialization with options:
- **Full Stack**: Client + API + Database
- **Full Stack with Admin**: Client + Admin + API + Database  
- **Frontend Only**: Client and/or Admin dashboard
- **Backend Only**: API and/or Database

Prompts for your project name, checks port availability, generates all necessary files, and starts services.

#### **2. Add Services to Existing Project**

```bash
make add
```

Intelligently detects existing services and offers options to add missing ones. Can add individual services (client, admin, API, database) or combinations (backend = API + Database).

#### **3. View Project Services**

```bash
make services
```

Shows which services are currently present in your project.

#### **4. Add CI/CD Configuration**

```bash
make add-cicd
```

Automatically detects your project services and generates:
- GitHub Actions workflows for PR, staging, and production deployments
- Azure Container Apps configuration files
- Setup documentation in `.github/docs/`

#### **5. View All Available Commands**

```bash
make help
# or just:
make
```

Shows all available commands with descriptions.

## **III. Running the Project After Setup**

Once your project is set up using `make init`, you can manage it using the provided development commands:

### **Development Commands**

#### **Core Development**

```bash
make dev        # Guided development server startup with options:
                #   1) All services via Docker
                #   2) Backend only via Docker 
                #   3) Frontend(s) locally via npm
                #   4) Mixed: Backend via Docker + Frontend(s) locally

make stop       # Stop all services (Docker + local npm processes)
make restart    # Restart all services
make status     # Show project status, running services, and actual ports
make install    # Install/update dependencies for all services
```

#### **Cleanup Commands**

```bash
make clean      # Guided cleanup with options:
                #   1) Local frontend artifacts (node_modules, .next, etc.)
                #   2) Docker resources (images, containers, volumes)
                #   3) Everything (local frontend + Docker)

make reset      # Complete project reset - removes all containers, images, and files
make delete-templates  # Remove templates directory after project setup
```

### **Docker Compose Commands**

You can also use standard Docker Compose commands directly:

```bash
docker compose up              # Start all services
docker compose up api postgres # Start only API and database
docker compose up client       # Start only frontend
docker compose down            # Stop all services
docker compose up --build      # Rebuild and start services
```

## **IV. Accessing Services**

Once services are up, access them via:

- Frontend: http://localhost:<client_port> (default: 3000)
- Admin: http://localhost:<admin_port> (default: 3001)
- Backend API: http://localhost:<api_port> (default: 8000)
- API Documentation: http://localhost:<api_port>/docs

**Note**: If default ports are unavailable, the system will automatically assign alternative ports. The actual ports in use will be displayed in a summary table when services start. Use `make status` to see the actual ports of running services.

## **V. CI/CD Deployment**

After setting up CI/CD with `make add-cicd`, your project will have automated deployments:

### **Generated Files**

- **`.github/workflows/`**: GitHub Actions for automated deployments
- **`.github/docs/`**: Setup and deployment documentation  
- **`configs/container-apps/`**: Azure Container Apps configuration

### **Deployment Workflow**

1. **Development**: Create feature branch → Open PR to `staging` → Auto-deploy PR environment
2. **Staging**: Push to `staging` branch → Auto-deploy to staging environment  
3. **Production**: Create git tag (e.g., `v1.0.0`) → Auto-deploy to production

### **Setup Steps**

1. Run `make add-cicd` to generate configuration
2. Follow the generated setup guide at `.github/docs/SETUP.md`
3. Configure GitHub repository secrets
4. Push code to trigger first deployment

See `.github/docs/SETUP.md` for detailed setup instructions.

## **VI. Project Structure**

The repository is organized as follows:

```bash
project/
│── services/                       # Generated services (empty initially)
├── templates/                      # All template files organized by type
│   ├── ci-cd/                      # GitHub Actions workflows and Azure configs
│   ├── docker-compose/             # Docker compose configurations
│   │   ├── docker-compose.admin.yml.template
│   │   ├── docker-compose.api.yml.template
│   │   ├── docker-compose.backend.yml.template
│   │   ├── docker-compose.client.yml.template
│   │   ├── docker-compose.database.yml.template
│   │   ├── docker-compose.full-admin.yml.template
│   │   └── docker-compose.full.yml.template
│   ├── dockerfiles/                # Container definitions
│   │   ├── Dockerfile.api.template
│   │   └── Dockerfile.frontend.template
│   ├── env/                        # Environment variable templates
│   │   ├── .env.admin.template
│   │   ├── .env.admin-only.template
│   │   ├── .env.api.template
│   │   ├── .env.api-only.template
│   │   ├── .env.client.template
│   │   └── .env.client-only.template
│   └── services/                   # Complete service templates
│       ├── api/                    # FastAPI backend service
│       └── frontend/               # Shared Next.js template for client/admin
│-- .gitignore                      # Prevents committing local-only or build-related files
│-- Makefile                        # Automated init & clean commands
│── README.md                       # Project documentation
```

## **VII. Makefile Organization**

The Makefile is organized into three logical sections:

### **User-Facing Commands**
Commands you'll actually use:
- `help`, `init`, `add`, `add-cicd`, `services`, `dev`, `stop`, `restart`, `install`, `status`, `clean`, `reset`, `delete-templates`

### **Internal Commands** 
Implementation details (you typically won't call these directly):
- **Init variants**: `init-full`, `init-client`, `init-admin`, etc.
- **Add variants**: `add-client`, `add-admin`, `add-api`, etc. 
- **Dev helpers**: `dev-all`, `dev-backend`, `dev-frontend`
- **Setup helpers**: `setup-client`, `setup-admin`, `setup-api`

### **Configuration & Utilities**
Port detection functions, environment checking, and configuration variables.

## **VIII. Key Features**

### **Guided Interactive Setup**

- **Smart menus**: All commands use interactive prompts to guide you through options
- **Flexible combinations**: Choose exactly the services you need (frontend-only, backend-only, or full-stack)
- **Auto-generation**: Creates all necessary Dockerfiles, docker-compose.yml, and environment files

### **Isolated Environments**

- Each service runs in its own Docker container.
- Project name is used to label all resources (containers, volumes, images) for easy cleanup and isolation.

### **Clean Development Workflow**

- **Multiple development modes**: Docker-only, local-only, or mixed development
- **Intelligent port management**: Auto-detects port conflicts and assigns alternatives
- **Granular cleanup**: Choose what to clean (frontend artifacts, Docker resources, or everything)
- **Service isolation**: Run only the services you need
- **Zero manual configuration**: No need to manually edit container names or labels




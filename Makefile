# ============================================================================
# CONFIGURATION & UTILITIES
# ============================================================================

.PHONY: init init-full init-full-admin init-client init-admin init-api init-backend \
        add add-client add-admin add-api add-database add-backend add-cicd \
        dev dev-all dev-backend dev-frontend stop restart install status services clean-frontend clean-docker clean reset delete-templates \
        check-envsubst setup-client setup-admin setup-api

# Configuration variables
COMPOSE_FILE := docker-compose.yml
ENVSUBST := $(shell which envsubst)

# Helper function to find an available port
define find_port
	tmp_port=$(1); \
	if lsof -i:$$tmp_port > /dev/null 2>&1; then \
		echo "Default port $$tmp_port is in use for $(2), finding alternative..." 1>&2; \
		while lsof -i:$$tmp_port > /dev/null 2>&1; do \
			tmp_port=$$((tmp_port + 1)); \
		done; \
		echo "✅ Using port $$tmp_port for $(2)" 1>&2; \
	else \
		echo "✅ Using default port $$tmp_port for $(2)" 1>&2; \
	fi; \
	echo $$tmp_port
endef

# Default target (runs when you type just 'make')
.DEFAULT_GOAL := help

# Check for envsubst at expected location
check-envsubst:
	@if ! which envsubst > /dev/null; then \
		echo "Error: envsubst not found. Please install gettext:"; \
		echo "  brew install gettext"; \
		echo "  brew link --force gettext"; \
		exit 1; \
	fi

# Service detection functions
define detect_services
	services=""; \
	if [ -d "services/client" ]; then services="$$services client"; fi; \
	if [ -d "services/admin" ]; then services="$$services admin"; fi; \
	if [ -d "services/api" ]; then services="$$services api"; fi; \
	if grep -q "postgres:" $(COMPOSE_FILE) 2>/dev/null; then services="$$services database"; fi; \
	echo "$$services"
endef


# ============================================================================
# USER-FACING COMMANDS
# ============================================================================

# Help command
help: ## Show available commands
	@echo "Avidity Boilerplate Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""

# Guided initialization target
init: check-envsubst ## Initialize a new project with guided selection
	@echo ""
	@echo "Starting new project setup..."
	@echo ""
	@echo "Select the type of project to initialize:" && \
	echo "  1) Full Stack (Client, API, and Database)" && \
	echo "  2) Full Stack with Admin (Client, Admin, API, and Database)" && \
	echo "  3) Frontend Only (Client and/or Admin)" && \
	echo "  4) Backend Only (API with or without Database)" && \
	echo "  0) Cancel" && \
	echo "" && \
	read -p "Enter your choice (0-4): " CHOICE && \
	echo "" && \
	case $$CHOICE in \
		0) \
			echo "Setup cancelled." && \
			exit 0 ;; \
		1) \
			echo "Initializing full stack project..." && \
			$(MAKE) init-full ;; \
		2) \
			echo "Initializing full stack project with admin..." && \
			$(MAKE) init-full-admin ;; \
		3) \
			echo "" && \
			echo "Select frontend services:" && \
			echo "  1) Client only" && \
			echo "  2) Admin only" && \
			echo "  3) Both Client and Admin" && \
			echo "  0) Go back to main menu" && \
			echo "" && \
			read -p "Enter your choice (0-3): " FRONTEND_CHOICE && \
			echo "" && \
			case $$FRONTEND_CHOICE in \
				0) \
					echo "Going back to main menu..." && \
					$(MAKE) init ;; \
				1) \
					echo "Initializing client-only project..." && \
					$(MAKE) init-client ;; \
				2) \
					echo "Initializing admin-only project..." && \
					$(MAKE) init-admin ;; \
				3) \
					echo "Initializing both client and admin services..." && \
					$(MAKE) init-frontend-both ;; \
				*) \
					echo "Invalid choice. Please run 'make init' again." && \
					exit 1 ;; \
			esac ;; \
		4) \
			echo "" && \
			echo "Select backend services:" && \
			echo "  1) API only" && \
			echo "  2) API with Database" && \
			echo "  0) Go back to main menu" && \
			echo "" && \
			read -p "Enter your choice (0-2): " BACKEND_CHOICE && \
			echo "" && \
			case $$BACKEND_CHOICE in \
				0) \
					echo "Going back to main menu..." && \
					$(MAKE) init ;; \
				1) \
					echo "Initializing API-only project..." && \
					$(MAKE) init-api ;; \
				2) \
					echo "Initializing API with Database..." && \
					$(MAKE) init-backend ;; \
				*) \
					echo "Invalid choice. Please run 'make init' again." && \
					exit 1 ;; \
			esac ;; \
		*) \
			echo "Invalid choice. Please run 'make init' again and select a valid option (0-4)." && \
			exit 1 ;; \
	esac

# Guided add services target
add: check-envsubst ## Add services to existing project (guided selection)
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "❌ No existing project found. Please run 'make init' first."; \
		exit 1; \
	fi && \
	\
	echo "" && \
	echo "🔍 Checking existing services..." && \
	HAS_CLIENT=$$([ -d "services/client" ] && echo "1" || echo "0") && \
	HAS_ADMIN=$$([ -d "services/admin" ] && echo "1" || echo "0") && \
	HAS_API=$$([ -d "services/api" ] && echo "1" || echo "0") && \
	HAS_DB=$$(grep -q "postgres:" $(COMPOSE_FILE) && echo "1" || echo "0") && \
	\
	echo "📋 Current services:" && \
	if [ "$$HAS_CLIENT" = "1" ]; then echo "  ✅ Client"; else echo "  ❌ Client"; fi && \
	if [ "$$HAS_ADMIN" = "1" ]; then echo "  ✅ Admin"; else echo "  ❌ Admin"; fi && \
	if [ "$$HAS_API" = "1" ]; then echo "  ✅ API"; else echo "  ❌ API"; fi && \
	if [ "$$HAS_DB" = "1" ]; then echo "  ✅ Database"; else echo "  ❌ Database"; fi && \
	\
	echo "" && \
	echo "Select service(s) to add:" && \
	OPTION_NUM=1 && \
	OPTIONS="" && \
	if [ "$$HAS_CLIENT" = "0" ]; then echo "  $$OPTION_NUM) Client"; OPTIONS="$$OPTIONS $$OPTION_NUM:client"; OPTION_NUM=$$((OPTION_NUM + 1)); fi && \
	if [ "$$HAS_ADMIN" = "0" ]; then echo "  $$OPTION_NUM) Admin"; OPTIONS="$$OPTIONS $$OPTION_NUM:admin"; OPTION_NUM=$$((OPTION_NUM + 1)); fi && \
	if [ "$$HAS_API" = "0" ]; then echo "  $$OPTION_NUM) API"; OPTIONS="$$OPTIONS $$OPTION_NUM:api"; OPTION_NUM=$$((OPTION_NUM + 1)); fi && \
	if [ "$$HAS_DB" = "0" ]; then echo "  $$OPTION_NUM) Database"; OPTIONS="$$OPTIONS $$OPTION_NUM:database"; OPTION_NUM=$$((OPTION_NUM + 1)); fi && \
	if [ "$$HAS_API" = "0" ] && [ "$$HAS_DB" = "0" ]; then echo "  $$OPTION_NUM) Full Backend (API + Database)"; OPTIONS="$$OPTIONS $$OPTION_NUM:backend"; OPTION_NUM=$$((OPTION_NUM + 1)); fi && \
	echo "  0) Cancel" && \
	\
	if [ -z "$$OPTIONS" ]; then \
		echo "" && \
		echo "✅ All services are already set up!" && \
		exit 0; \
	fi && \
	\
	echo "" && \
	read -p "Enter your choice: " CHOICE && \
	\
	if [ "$$CHOICE" = "0" ]; then \
		echo "❌ Cancelled"; \
		exit 0; \
	fi && \
	\
	SELECTED_SERVICE=$$(echo "$$OPTIONS" | tr ' ' '\n' | grep "^$$CHOICE:" | cut -d: -f2) && \
	\
	if [ -z "$$SELECTED_SERVICE" ]; then \
		echo "❌ Invalid choice. Please run 'make add' again."; \
		exit 1; \
	fi && \
	\
	echo "" && \
	echo "Adding $$SELECTED_SERVICE service..." && \
	$(MAKE) add-$$SELECTED_SERVICE

# Development commands
dev: ## Start development servers (guided selection)
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "❌ No project found. Please run 'make init' first."; \
		exit 1; \
	fi && \
	echo "" && \
	echo "🚀 Start Development Servers" && \
	echo "" && \
	echo "Select how to start services:" && \
	echo "  1) All services via Docker (docker compose up)" && \
	echo "  2) Backend only via Docker (API + Database)" && \
	echo "  3) Frontend(s) locally via npm (client/admin with npm run dev)" && \
	echo "  4) Mixed: Backend via Docker + Frontend(s) locally" && \
	echo "  0) Cancel" && \
	echo "" && \
	read -p "Enter your choice (0-4): " CHOICE && \
	echo "" && \
	case $$CHOICE in \
		0) \
			echo "❌ Cancelled" && \
			exit 0 ;; \
		1) \
			echo "🚀 Starting all services via Docker..." && \
			$(MAKE) dev-all ;; \
		2) \
			echo "🚀 Starting backend services via Docker..." && \
			$(MAKE) dev-backend ;; \
		3) \
			echo "🚀 Starting frontend(s) locally..." && \
			$(MAKE) dev-frontend ;; \
		4) \
			echo "🚀 Starting backend via Docker + frontend(s) locally..." && \
			bash -c 'trap "docker compose down; kill 0" EXIT; \
			echo "Starting backend services..." && \
			docker compose up api postgres & \
			sleep 2 && \
			echo "Starting frontend services locally..." && \
			$(MAKE) dev-frontend' ;; \
		*) \
			echo "❌ Invalid choice. Please run 'make dev' again." && \
			exit 1 ;; \
	esac

stop: ## Stop all development servers (Docker + local)
	@echo "🛑 Stopping all services..." && \
	docker compose down 2>/dev/null || true && \
	pkill -f "npm run dev" 2>/dev/null || true && \
	pkill -f "next-router-worker" 2>/dev/null || true && \
	pkill -f "node.*next" 2>/dev/null || true && \
	echo "✅ All services stopped"

restart: stop dev ## Restart development servers

install: ## Install/update dependencies for all services
	@echo "📦 Installing dependencies..." && \
	if [ -d "services/client" ]; then \
		echo "Installing client dependencies..." && \
		(cd services/client && npm install); \
	fi && \
	if [ -d "services/admin" ]; then \
		echo "Installing admin dependencies..." && \
		(cd services/admin && npm install); \
	fi && \
	if [ -d "services/api" ]; then \
		echo "Installing API dependencies..." && \
		(cd services/api && pip install -r requirements.txt); \
	fi && \
	echo "✅ Dependencies installed"

status: ## Show project status and running services
	@echo "📊 Project Status:" && \
	echo "" && \
	echo "📁 Services:" && \
	if [ -d "services/client" ]; then echo "  ✅ Client"; else echo "  ❌ Client"; fi && \
	if [ -d "services/admin" ]; then echo "  ✅ Admin"; else echo "  ❌ Admin"; fi && \
	if [ -d "services/api" ]; then echo "  ✅ API"; else echo "  ❌ API"; fi && \
	if [ -f $(COMPOSE_FILE) ] && grep -q "postgres:" $(COMPOSE_FILE); then echo "  ✅ Database"; else echo "  ❌ Database"; fi && \
	echo "" && \
	echo "🐳 Docker Services:" && \
	if docker compose ps --format table 2>/dev/null | grep -q "Up"; then \
		docker compose ps --format table; \
		echo "" && \
		echo "🌐 Service URLs:" && \
		if docker compose ps --format "{{.Service}}" 2>/dev/null | grep -q "client"; then \
			CLIENT_PORT=$$(docker compose port client 3000 2>/dev/null | cut -d: -f2 || echo "not running"); \
			echo "  Frontend: http://localhost:$$CLIENT_PORT"; \
		fi && \
		if docker compose ps --format "{{.Service}}" 2>/dev/null | grep -q "admin"; then \
			ADMIN_PORT=$$(docker compose port admin 3001 2>/dev/null | cut -d: -f2 || echo "not running"); \
			echo "  Admin: http://localhost:$$ADMIN_PORT"; \
		fi && \
		if docker compose ps --format "{{.Service}}" 2>/dev/null | grep -q "api"; then \
			API_PORT=$$(docker compose port api 8000 2>/dev/null | cut -d: -f2 || echo "not running"); \
			echo "  Backend: http://localhost:$$API_PORT"; \
			echo "  API Docs: http://localhost:$$API_PORT/docs"; \
		fi; \
	else \
		echo "  ❌ No services running"; \
		echo "" && \
		echo "💡 Run 'make dev' to start services"; \
	fi

services: ## Detect which services are present in the project
	@services=$$($(call detect_services)); \
	echo "Detected services:$$services"; \
	if [ -z "$$services" ]; then \
		echo "No services detected. Run 'make init' to get started."; \
	fi

# Guided clean command
clean: ## Clean build artifacts and Docker resources (guided selection)
	@echo "" && \
	echo "🧹 Clean Project Resources" && \
	echo "" && \
	echo "Select what to clean:" && \
	echo "  1) Local frontend artifacts (node_modules, .next, package-lock.json)" && \
	echo "  2) Docker resources (images, containers, volumes, build cache)" && \
	echo "  3) Everything (local frontend + Docker)" && \
	echo "  0) Cancel" && \
	echo "" && \
	read -p "Enter your choice (0-3): " CHOICE && \
	echo "" && \
	case $$CHOICE in \
		0) \
			echo "❌ Cancelled" && \
			exit 0 ;; \
		1) \
			echo "🧹 Cleaning frontend..." && \
			$(MAKE) clean-frontend ;; \
		2) \
			echo "🧹 Cleaning Docker..." && \
			$(MAKE) clean-docker ;; \
		3) \
			echo "🧹 Cleaning everything..." && \
			$(MAKE) clean-frontend && \
			$(MAKE) clean-docker ;; \
		*) \
			echo "❌ Invalid choice. Please run 'make clean' again." && \
			exit 1 ;; \
	esac

# Full reset (simple cleanup)
reset: ## Reset the project setup
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "❌ No project found in this directory. Nothing to reset."; \
		exit 1; \
	fi && \
	NAME=$$(grep "project=" $(COMPOSE_FILE) | head -1 | sed 's/.*project=//' | sed 's/"//' | sed 's/".*//') && \
	if [ -z "$$NAME" ]; then \
		echo "❌ Could not determine project name from $(COMPOSE_FILE)"; \
		exit 1; \
	fi && \
	echo "\n⚠️  This will reset project '$$NAME' and remove:" && \
	echo "   - All Docker containers, images, and volumes for '$$NAME'" && \
	echo "   - All service directories (services/)" && \
	echo "   - Docker compose file and scripts" && \
	echo "   - CI/CD configuration (.github/, configs/)" && \
	echo "" && \
	read -p "Are you sure you want to proceed? (y/N): " CONFIRM && \
	if [ "$$CONFIRM" != "y" ]; then echo "Aborted."; exit 1; fi && \
	echo "Resetting project '$$NAME'..." && \
	echo "Stopping and removing all Docker resources..." && \
	docker compose down -v --remove-orphans 2>/dev/null || true && \
	echo "Removing any remaining containers..." && \
	docker container rm -f $$(docker container ls -qa --filter "label=project=$$NAME") 2>/dev/null || true && \
	echo "Removing images..." && \
	docker image rm -f $$(docker image ls -q --filter "label=project=$$NAME") 2>/dev/null || true && \
	echo "Removing any remaining volumes..." && \
	docker volume rm -f $$NAME\_db-data 2>/dev/null || true && \
	docker volume rm $$(docker volume ls -q --filter "label=project=$$NAME") 2>/dev/null || true && \
	echo "✅ Docker resources cleaned." && \
	echo "Cleaning up files..." && \
	rm -rf ./services && \
	rm -rf ./.github && \
	rm -rf ./configs && \
	rm -f $(COMPOSE_FILE) && \
	echo "✅ Reset complete. You can now run 'make init' again."

# Remove boilerplate templates  
delete-templates: ## Delete templates directory (no longer needed after setup)
	@echo "\n⚠️  This will delete the templates directory." && \
	read -p "Are you sure you want to proceed? (y/N): " CONFIRM && \
	if [ "$$CONFIRM" != "y" ]; then echo "Aborted."; exit 1; fi && \
	echo "Removing template files..." && \
	rm -rf templates && \
	echo "✅ Templates removed."

# ============================================================================
# INTERNAL COMMANDS
# ============================================================================

# Init Variants
init-full: check-envsubst
	@echo ""
	@read -p "Enter your project name: " NAME && \
	DEFAULT_PG_PORT=5432 && \
	DEFAULT_API_PORT=8000 && \
	DEFAULT_CLIENT_PORT=3000 && \
	\
	echo "Checking port availability..." && \
	\
	echo "Checking PostgreSQL port..." && \
	PG_PORT=`$(call find_port,$$DEFAULT_PG_PORT,PostgreSQL)` && \
	\
	echo "Checking API port..." && \
	API_PORT=`$(call find_port,$$DEFAULT_API_PORT,API)` && \
	\
	echo "Checking Client port..." && \
	CLIENT_PORT=`$(call find_port,$$DEFAULT_CLIENT_PORT,Client)` && \
	\
	echo "Creating services directories..." && \
	mkdir -p services/api services/client && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-client PROJECT_NAME=$$NAME && \
	$(MAKE) setup-api PROJECT_NAME=$$NAME && \
	\
	echo "Generating .env files..." && \
	echo "APP_NAME=\"$$NAME\"" > services/api/.env && \
	echo "DOCS_URL=\"/docs\"" >> services/api/.env && \
	echo "CLIENT_URL=\"http://localhost:$$CLIENT_PORT\"" >> services/api/.env && \
	echo "DATABASE_URL=\"postgresql://postgres:securepassword@postgres/$$NAME\"" >> services/api/.env && \
	echo "ROOT_DOMAIN=\"http://localhost:$$CLIENT_PORT\"" > services/client/.env && \
	echo "NEXT_PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/client/.env && \
	echo "PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/client/.env && \
	\
	echo "Generating Dockerfiles..." && \
	env PROJECT_NAME=$$NAME $(ENVSUBST) < templates/dockerfiles/Dockerfile.api.template > services/api/Dockerfile && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3000 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/client/Dockerfile && \
	echo "Generating docker-compose.yml..." && \
	export PROJECT_NAME=$$NAME && \
	export PG_PORT=$$PG_PORT && \
	export API_PORT=$$API_PORT && \
	export CLIENT_PORT=$$CLIENT_PORT && \
	$(ENVSUBST) < templates/docker-compose/docker-compose.full.yml.template > $(COMPOSE_FILE) && \
	\
	echo "" && \
	echo "🚀 Starting containers with the following ports:" && \
	echo "┌─────────────┬───────┬───────────────┐" && \
	echo "│ Service     │ Port  │ Status        │" && \
    echo "└─────────────┴───────┴───────────────┘" && \
	printf "  PostgreSQL  │ %-5s │ %-10s \n" "$${PG_PORT}" "$$([ "$$PG_PORT" = "$$DEFAULT_PG_PORT" ] && echo "Default" || echo "Non-standard")" && \
	printf "  API         │ %-5s │ %-10s \n" "$${API_PORT}" "$$([ "$$API_PORT" = "$$DEFAULT_API_PORT" ] && echo "Default" || echo "Non-standard")" && \
	printf "  Client      │ %-5s │ %-10s \n" "$${CLIENT_PORT}" "$$([ "$$CLIENT_PORT" = "$$DEFAULT_CLIENT_PORT" ] && echo "Default" || echo "Non-standard")" && \
	echo "" && \
	\
	if [ "$$PG_PORT" != "$$DEFAULT_PG_PORT" ] || [ "$$API_PORT" != "$$DEFAULT_API_PORT" ] || [ "$$CLIENT_PORT" != "$$DEFAULT_CLIENT_PORT" ]; then \
		echo "⚠️  IMPORTANT: Non-standard ports are being used." && \
		echo "   To access your app, use: http://localhost:$$CLIENT_PORT" && \
		echo "   To access the API, use: http://localhost:$$API_PORT" && \
		echo "" ; \
	fi && \
	\
	echo "Starting Docker services..." && \
	docker compose -f $(COMPOSE_FILE) up

init-full-admin: check-envsubst
	@echo ""
	@read -p "Enter your project name: " NAME && \
	DEFAULT_PG_PORT=5432 && \
	DEFAULT_API_PORT=8000 && \
	DEFAULT_CLIENT_PORT=3000 && \
	DEFAULT_ADMIN_PORT=3001 && \
	\
	echo "Checking port availability..." && \
	\
	echo "Checking PostgreSQL port..." && \
	PG_PORT=`$(call find_port,$$DEFAULT_PG_PORT,PostgreSQL)` && \
	\
	echo "Checking API port..." && \
	API_PORT=`$(call find_port,$$DEFAULT_API_PORT,API)` && \
	\
	echo "Checking Client port..." && \
	CLIENT_PORT=`$(call find_port,$$DEFAULT_CLIENT_PORT,Client)` && \
	\
	echo "Checking Admin port..." && \
	ADMIN_PORT=`$(call find_port,$$DEFAULT_ADMIN_PORT,Admin)` && \
	\
	echo "Creating services directories..." && \
	mkdir -p services/api services/client services/admin && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-client PROJECT_NAME=$$NAME && \
	$(MAKE) setup-admin PROJECT_NAME=$$NAME && \
	$(MAKE) setup-api PROJECT_NAME=$$NAME && \
	\
	echo "Generating .env files..." && \
	echo "APP_NAME=\"$$NAME\"" > services/api/.env && \
	echo "DOCS_URL=\"/docs\"" >> services/api/.env && \
	echo "CLIENT_URL=\"http://localhost:$$CLIENT_PORT\"" >> services/api/.env && \
	echo "DATABASE_URL=\"postgresql://postgres:securepassword@postgres/$$NAME\"" >> services/api/.env && \
	echo "ROOT_DOMAIN=\"http://localhost:$$CLIENT_PORT\"" > services/client/.env && \
	echo "NEXT_PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/client/.env && \
	echo "PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/client/.env && \
	echo "ROOT_DOMAIN=\"http://localhost:$$ADMIN_PORT\"" > services/admin/.env && \
	echo "NEXT_PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/admin/.env && \
	echo "PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/admin/.env && \
	\
	echo "Generating Dockerfiles..." && \
	env PROJECT_NAME=$$NAME $(ENVSUBST) < templates/dockerfiles/Dockerfile.api.template > services/api/Dockerfile && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3000 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/client/Dockerfile && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3001 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/admin/Dockerfile && \
	echo "Generating docker-compose.yml..." && \
	export PROJECT_NAME=$$NAME && \
	export PG_PORT=$$PG_PORT && \
	export API_PORT=$$API_PORT && \
	export CLIENT_PORT=$$CLIENT_PORT && \
	export ADMIN_PORT=$$ADMIN_PORT && \
	$(ENVSUBST) < templates/docker-compose/docker-compose.full-admin.yml.template > $(COMPOSE_FILE) && \
	\
		\
	echo "" && \
	echo "🚀 Starting containers with the following ports:" && \
	echo "┌─────────────┬───────┬───────────────┐" && \
	echo "│ Service     │ Port  │ Status        │" && \
    echo "└─────────────┴───────┴───────────────┘" && \
	printf "  PostgreSQL  │ %-5s │ %-10s \n" "$${PG_PORT}" "$$([ "$$PG_PORT" = "$$DEFAULT_PG_PORT" ] && echo "Default" || echo "Non-standard")" && \
	printf "  API         │ %-5s │ %-10s \n" "$${API_PORT}" "$$([ "$$API_PORT" = "$$DEFAULT_API_PORT" ] && echo "Default" || echo "Non-standard")" && \
	printf "  Client      │ %-5s │ %-10s \n" "$${CLIENT_PORT}" "$$([ "$$CLIENT_PORT" = "$$DEFAULT_CLIENT_PORT" ] && echo "Default" || echo "Non-standard")" && \
	printf "  Admin       │ %-5s │ %-10s \n" "$${ADMIN_PORT}" "$$([ "$$ADMIN_PORT" = "$$DEFAULT_ADMIN_PORT" ] && echo "Default" || echo "Non-standard")" && \
	echo "" && \
	echo "" && \
	\
	if [ "$$PG_PORT" != "$$DEFAULT_PG_PORT" ] || [ "$$API_PORT" != "$$DEFAULT_API_PORT" ] || [ "$$CLIENT_PORT" != "$$DEFAULT_CLIENT_PORT" ] || [ "$$ADMIN_PORT" != "$$DEFAULT_ADMIN_PORT" ]; then \
		echo "⚠️  IMPORTANT: Non-standard ports are being used." && \
		echo "   To access your app, use: http://localhost:$$CLIENT_PORT" && \
		echo "   To access the admin dashboard, use: http://localhost:$$ADMIN_PORT" && \
		echo "   To access the API, use: http://localhost:$$API_PORT" && \
		echo "" ; \
	fi && \
	\
	echo "Starting Docker services..." && \
	docker compose -f $(COMPOSE_FILE) up

init-client: check-envsubst
	@echo ""
	@read -p "Enter your project name: " NAME && \
	DEFAULT_CLIENT_PORT=3000 && \
	\
	echo "Checking Client port..." && \
	CLIENT_PORT=`$(call find_port,$$DEFAULT_CLIENT_PORT,Client)` && \
	\
	echo "Creating services directory..." && \
	mkdir -p services/client && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-client PROJECT_NAME=$$NAME && \
	\
	echo "Generating .env files..." && \
	echo "ROOT_DOMAIN=\"http://localhost:$$CLIENT_PORT\"" > services/client/.env && \
	\
	echo "Generating Dockerfiles..." && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3000 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/client/Dockerfile && \
	\
	echo "Generating docker-compose.yml..." && \
	export PROJECT_NAME=$$NAME && \
	export CLIENT_PORT=$$CLIENT_PORT && \
	$(ENVSUBST) < templates/docker-compose/docker-compose.client.yml.template > $(COMPOSE_FILE) && \
	\
	\
	\
	echo "" && \
	echo "🚀 Starting client with the following ports:" && \
	echo "┌─────────────┬───────┬───────────────┐" && \
	echo "│ Service     │ Port  │ Status        │" && \
    echo "└─────────────┴───────┴───────────────┘" && \
	printf "  Client      │ %-5s │ %-10s \n" "$${CLIENT_PORT}" "$$([ "$$CLIENT_PORT" = "$$DEFAULT_CLIENT_PORT" ] && echo "Default" || echo "Non-standard")" && \
	echo "" && \
	\
	if [ "$$CLIENT_PORT" != "$$DEFAULT_CLIENT_PORT" ]; then \
		echo "⚠️  IMPORTANT: Non-standard client port is being used." && \
		echo "   To access your app, use: http://localhost:$$CLIENT_PORT" && \
		echo "" ; \
	fi && \
	\
	echo "Starting client service..." && \
	docker compose -f $(COMPOSE_FILE) up

init-admin: check-envsubst
	@echo ""
	@read -p "Enter your project name: " NAME && \
	DEFAULT_ADMIN_PORT=3001 && \
	\
	echo "Checking Admin port..." && \
	ADMIN_PORT=`$(call find_port,$$DEFAULT_ADMIN_PORT,Admin)` && \
	\
	echo "Creating services directory..." && \
	mkdir -p services/admin && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-admin PROJECT_NAME=$$NAME && \
	\
	echo "Generating .env files..." && \
	echo "ROOT_DOMAIN=\"http://localhost:$$ADMIN_PORT\"" > services/admin/.env && \
	\
	echo "Generating Dockerfiles..." && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3001 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/admin/Dockerfile && \
	\
	echo "Generating docker-compose.yml..." && \
	export PROJECT_NAME=$$NAME && \
	export ADMIN_PORT=$$ADMIN_PORT && \
	$(ENVSUBST) < templates/docker-compose/docker-compose.admin.yml.template > $(COMPOSE_FILE) && \
	\
	\
	\
		\
	echo "" && \
	echo "🚀 Starting admin with the following ports:" && \
	echo "┌─────────────┬───────┬───────────────┐" && \
	echo "│ Service     │ Port  │ Status        │" && \
    echo "└─────────────┴───────┴───────────────┘" && \
	printf "  Admin       │ %-5s │ %-10s \n" "$${ADMIN_PORT}" "$$([ "$$ADMIN_PORT" = "$$DEFAULT_ADMIN_PORT" ] && echo "Default" || echo "Non-standard")" && \
	echo "" && \
	echo "" && \
	\
	if [ "$$ADMIN_PORT" != "$$DEFAULT_ADMIN_PORT" ]; then \
		echo "⚠️  IMPORTANT: Non-standard admin port is being used." && \
		echo "   To access your admin dashboard, use: http://localhost:$$ADMIN_PORT" && \
		echo "" ; \
	fi && \
	\
	echo "Starting admin service..." && \
	docker compose -f $(COMPOSE_FILE) up

init-api: check-envsubst
	@echo ""
	@read -p "Enter your project name: " NAME && \
	DEFAULT_API_PORT=8000 && \
	\
	echo "Checking API port..." && \
	API_PORT=`$(call find_port,$$DEFAULT_API_PORT,API)` && \
	\
	echo "Creating services directory..." && \
	mkdir -p services/api && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-api-minimal PROJECT_NAME=$$NAME && \
	\
	echo "Generating .env files..." && \
	echo "APP_NAME=\"$$NAME\"" > services/api/.env && \
	echo "DOCS_URL=\"/docs\"" >> services/api/.env && \
	\
	echo "Generating Dockerfiles..." && \
	env PROJECT_NAME=$$NAME $(ENVSUBST) < templates/dockerfiles/Dockerfile.api.template > services/api/Dockerfile && \
	\
	echo "Generating docker-compose.yml..." && \
	export PROJECT_NAME=$$NAME && \
	export API_PORT=$$API_PORT && \
	$(ENVSUBST) < templates/docker-compose/docker-compose.api.yml.template > $(COMPOSE_FILE) && \
	\
	\
	\
		\
	echo "" && \
	echo "🚀 Starting API with the following ports:" && \
	echo "┌─────────────┬───────┬───────────────┐" && \
	echo "│ Service     │ Port  │ Status        │" && \
    echo "└─────────────┴───────┴───────────────┘" && \
	printf "  API         │ %-5s │ %-10s \n" "$${API_PORT}" "$$([ "$$API_PORT" = "$$DEFAULT_API_PORT" ] && echo "Default" || echo "Non-standard")" && \
	echo "" && \
	echo "" && \
	\
	if [ "$$API_PORT" != "$$DEFAULT_API_PORT" ]; then \
		echo "⚠️  IMPORTANT: Non-standard API port is being used." && \
		echo "   To access the API, use: http://localhost:$$API_PORT" && \
		echo "" ; \
	fi && \
	\
	echo "ℹ️  Note: This API has no database. Use 'make add-database' to add one." && \
	echo "" && \
	echo "Starting API service..." && \
	docker compose -f $(COMPOSE_FILE) up


init-backend: check-envsubst
	@echo ""
	@read -p "Enter your project name: " NAME && \
	DEFAULT_PG_PORT=5432 && \
	DEFAULT_API_PORT=8000 && \
	\
	echo "Checking PostgreSQL port..." && \
	PG_PORT=`$(call find_port,$$DEFAULT_PG_PORT,PostgreSQL)` && \
	\
	echo "Checking API port..." && \
	API_PORT=`$(call find_port,$$DEFAULT_API_PORT,API)` && \
	\
	echo "Creating services directory..." && \
	mkdir -p services/api && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-api PROJECT_NAME=$$NAME && \
	\
	echo "Generating .env files..." && \
	echo "APP_NAME=\"$$NAME\"" > services/api/.env && \
	echo "DOCS_URL=\"/docs\"" >> services/api/.env && \
	echo "DATABASE_URL=\"postgresql://postgres:securepassword@postgres/$$NAME\"" >> services/api/.env && \
	\
	echo "Generating Dockerfiles..." && \
	env PROJECT_NAME=$$NAME $(ENVSUBST) < templates/dockerfiles/Dockerfile.api.template > services/api/Dockerfile && \
	\
	echo "Generating docker-compose.yml..." && \
	export PROJECT_NAME=$$NAME && \
	export PG_PORT=$$PG_PORT && \
	export API_PORT=$$API_PORT && \
	$(ENVSUBST) < templates/docker-compose/docker-compose.backend.yml.template > $(COMPOSE_FILE) && \
	\
	\
	\
		\
	echo "" && \
	echo "🚀 Starting backend with the following ports:" && \
	echo "┌─────────────┬───────┬───────────────┐" && \
	echo "│ Service     │ Port  │ Status        │" && \
    echo "└─────────────┴───────┴───────────────┘" && \
	printf "  PostgreSQL  │ %-5s │ %-10s \n" "$${PG_PORT}" "$$([ "$$PG_PORT" = "$$DEFAULT_PG_PORT" ] && echo "Default" || echo "Non-standard")" && \
	printf "  API         │ %-5s │ %-10s \n" "$${API_PORT}" "$$([ "$$API_PORT" = "$$DEFAULT_API_PORT" ] && echo "Default" || echo "Non-standard")" && \
	echo "" && \
	echo "" && \
	\
	if [ "$$PG_PORT" != "$$DEFAULT_PG_PORT" ] || [ "$$API_PORT" != "$$DEFAULT_API_PORT" ]; then \
		echo "⚠️  IMPORTANT: Non-standard ports are being used." && \
		if [ "$$API_PORT" != "$$DEFAULT_API_PORT" ]; then \
			echo "   To access the API, use: http://localhost:$$API_PORT" ; \
		fi && \
		echo "" ; \
	fi && \
	\
	echo "Starting backend services..." && \
	docker compose -f $(COMPOSE_FILE) up

init-frontend-both: check-envsubst
	@echo ""
	@read -p "Enter your project name: " NAME && \
	DEFAULT_CLIENT_PORT=3000 && \
	DEFAULT_ADMIN_PORT=3001 && \
	\
	echo "Checking Client port..." && \
	CLIENT_PORT=`$(call find_port,$$DEFAULT_CLIENT_PORT,Client)` && \
	\
	echo "Checking Admin port..." && \
	ADMIN_PORT=`$(call find_port,$$DEFAULT_ADMIN_PORT,Admin)` && \
	\
	echo "Creating services directories..." && \
	mkdir -p services/client services/admin && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-client PROJECT_NAME=$$NAME && \
	$(MAKE) setup-admin PROJECT_NAME=$$NAME && \
	\
	echo "Generating .env files..." && \
	echo "ROOT_DOMAIN=\"http://localhost:$$CLIENT_PORT\"" > services/client/.env && \
	echo "ROOT_DOMAIN=\"http://localhost:$$ADMIN_PORT\"" > services/admin/.env && \
	\
	echo "Generating Dockerfiles..." && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3000 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/client/Dockerfile && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3001 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/admin/Dockerfile && \
	\
	echo "Generating docker-compose.yml..." && \
	export PROJECT_NAME=$$NAME && \
	export CLIENT_PORT=$$CLIENT_PORT && \
	export ADMIN_PORT=$$ADMIN_PORT && \
	echo "version: \"3.9\"" > $(COMPOSE_FILE) && \
	echo "" >> $(COMPOSE_FILE) && \
	echo "services:" >> $(COMPOSE_FILE) && \
	echo "  client:" >> $(COMPOSE_FILE) && \
	echo "    container_name: $$NAME-client" >> $(COMPOSE_FILE) && \
	echo "    build:" >> $(COMPOSE_FILE) && \
	echo "      context: ./services/client/" >> $(COMPOSE_FILE) && \
	echo "      target: local" >> $(COMPOSE_FILE) && \
	echo "    ports:" >> $(COMPOSE_FILE) && \
	echo "      - $$CLIENT_PORT:3000" >> $(COMPOSE_FILE) && \
	echo "    volumes:" >> $(COMPOSE_FILE) && \
	echo "      - ./services/client/:/usr/src/app" >> $(COMPOSE_FILE) && \
	echo "      - /usr/src/app/node_modules" >> $(COMPOSE_FILE) && \
	echo "    environment:" >> $(COMPOSE_FILE) && \
	echo "      - NEXT_TELEMETRY_DISABLED=1" >> $(COMPOSE_FILE) && \
	echo "    env_file:" >> $(COMPOSE_FILE) && \
	echo "      - services/client/.env" >> $(COMPOSE_FILE) && \
	echo "    labels:" >> $(COMPOSE_FILE) && \
	echo "      - \"project=$$NAME\"" >> $(COMPOSE_FILE) && \
	echo "" >> $(COMPOSE_FILE) && \
	echo "  admin:" >> $(COMPOSE_FILE) && \
	echo "    container_name: $$NAME-admin" >> $(COMPOSE_FILE) && \
	echo "    build:" >> $(COMPOSE_FILE) && \
	echo "      context: ./services/admin/" >> $(COMPOSE_FILE) && \
	echo "      target: local" >> $(COMPOSE_FILE) && \
	echo "    ports:" >> $(COMPOSE_FILE) && \
	echo "      - $$ADMIN_PORT:3001" >> $(COMPOSE_FILE) && \
	echo "    volumes:" >> $(COMPOSE_FILE) && \
	echo "      - ./services/admin/:/usr/src/app" >> $(COMPOSE_FILE) && \
	echo "      - /usr/src/app/node_modules" >> $(COMPOSE_FILE) && \
	echo "    environment:" >> $(COMPOSE_FILE) && \
	echo "      - NEXT_TELEMETRY_DISABLED=1" >> $(COMPOSE_FILE) && \
	echo "    env_file:" >> $(COMPOSE_FILE) && \
	echo "      - services/admin/.env" >> $(COMPOSE_FILE) && \
	echo "    labels:" >> $(COMPOSE_FILE) && \
	echo "      - \"project=$$NAME\"" >> $(COMPOSE_FILE) && \
	\
	\
	\
	echo "" && \
	echo "🚀 Starting client and admin with the following ports:" && \
	echo "┌─────────────┬───────┬───────────────┐" && \
	echo "│ Service     │ Port  │ Status        │" && \
	echo "└─────────────┴───────┴───────────────┘" && \
	printf "  Client      │ %-5s │ %-10s \n" "$${CLIENT_PORT}" "$$([ "$$CLIENT_PORT" = "$$DEFAULT_CLIENT_PORT" ] && echo "Default" || echo "Non-standard")" && \
	printf "  Admin       │ %-5s │ %-10s \n" "$${ADMIN_PORT}" "$$([ "$$ADMIN_PORT" = "$$DEFAULT_ADMIN_PORT" ] && echo "Default" || echo "Non-standard")" && \
	echo "" && \
	\
	if [ "$$CLIENT_PORT" != "$$DEFAULT_CLIENT_PORT" ] || [ "$$ADMIN_PORT" != "$$DEFAULT_ADMIN_PORT" ]; then \
		echo "⚠️  IMPORTANT: Non-standard ports are being used." && \
		echo "   To access your client, use: http://localhost:$$CLIENT_PORT" && \
		echo "   To access your admin, use: http://localhost:$$ADMIN_PORT" && \
		echo "" ; \
	fi && \
	\
	echo "Starting client and admin services..." && \
	docker compose -f $(COMPOSE_FILE) up

# Add Variants
add-client: check-envsubst
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "Error: No existing project found. Please run 'make init' first."; \
		exit 1; \
	fi && \
	if [ -d "services/client" ]; then \
		echo "Error: Client service already exists in this project."; \
		exit 1; \
	fi && \
	\
	echo "Adding client service to existing project..." && \
	\
	NAME=$$(grep "project=" $(COMPOSE_FILE) | head -1 | sed 's/.*project=//' | sed 's/"//' | sed 's/".*//') && \
	if [ -z "$$NAME" ]; then \
		echo "Error: Could not determine project name from $(COMPOSE_FILE)" && \
		exit 1; \
	fi && \
	\
	echo "Creating client service directory..." && \
	mkdir -p services/client && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-client PROJECT_NAME=$$NAME && \
	\
	DEFAULT_CLIENT_PORT=3000 && \
	echo "Checking Client port..." && \
	CLIENT_PORT=`$(call find_port,$$DEFAULT_CLIENT_PORT,Client)` && \
	\
	echo "Generating client .env file..." && \
	mkdir -p services/client && \
	echo "ROOT_DOMAIN=\"http://localhost:$$CLIENT_PORT\"" > services/client/.env && \
	\
	API_PORT=8000 && \
	if [ -n "$$API_PORT" ]; then \
		echo "NEXT_PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/client/.env && \
		echo "PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/client/.env; \
	fi && \
	\
	echo "Generating client Dockerfile..." && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3000 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/client/Dockerfile && \
	\
	\
	echo "Adding client service to docker-compose.yml..." && \
	\
	if grep -q "^volumes:" $(COMPOSE_FILE); then \
		cp $(COMPOSE_FILE) $(COMPOSE_FILE).tmp && \
		awk '/^volumes:/ { \
			print ""; \
			print "  client:"; \
			print "    container_name: '$$NAME'-client"; \
			print "    build:"; \
			print "      context: ./services/client/"; \
			print "      target: local"; \
			print "    ports:"; \
			print "      - '$$CLIENT_PORT':3000"; \
			print "    volumes:"; \
			print "      - ./services/client/:/usr/src/app"; \
			print "      - /usr/src/app/node_modules"; \
			print "    environment:"; \
			print "      - NEXT_TELEMETRY_DISABLED=1"; \
			print "    env_file:"; \
			print "      - services/client/.env"; \
			print "    labels:"; \
			print "      - \"project='$$NAME'\""; \
			print ""; \
		} \
		{ print }' $(COMPOSE_FILE).tmp > $(COMPOSE_FILE) && \
		rm $(COMPOSE_FILE).tmp; \
	else \
		echo "" >> $(COMPOSE_FILE) && \
		echo "  client:" >> $(COMPOSE_FILE) && \
		echo "    container_name: $$NAME-client" >> $(COMPOSE_FILE) && \
		echo "    build:" >> $(COMPOSE_FILE) && \
		echo "      context: ./services/client/" >> $(COMPOSE_FILE) && \
		echo "      target: local" >> $(COMPOSE_FILE) && \
		echo "    ports:" >> $(COMPOSE_FILE) && \
		echo "      - $$CLIENT_PORT:3000" >> $(COMPOSE_FILE) && \
		echo "    volumes:" >> $(COMPOSE_FILE) && \
		echo "      - ./services/client/:/usr/src/app" >> $(COMPOSE_FILE) && \
		echo "      - /usr/src/app/node_modules" >> $(COMPOSE_FILE) && \
		echo "    environment:" >> $(COMPOSE_FILE) && \
		echo "      - NEXT_TELEMETRY_DISABLED=1" >> $(COMPOSE_FILE) && \
		echo "    env_file:" >> $(COMPOSE_FILE) && \
		echo "      - services/client/.env" >> $(COMPOSE_FILE) && \
		echo "    labels:" >> $(COMPOSE_FILE) && \
		echo "      - \"project=$$NAME\"" >> $(COMPOSE_FILE); \
	fi && \
	\
	echo "" && \
	echo "✅ Client service added successfully!" && \
	echo "   Client will run on port: $$CLIENT_PORT" && \
	echo "" && \
	echo "Run 'docker compose up client' to start the client service."

add-admin: check-envsubst
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "Error: No existing project found. Please run 'make init' first."; \
		exit 1; \
	fi && \
	if [ -d "services/admin" ]; then \
		echo "Error: Admin service already exists in this project."; \
		exit 1; \
	fi && \
	\
	echo "Adding admin service to existing project..." && \
	\
	NAME=$$(grep "project=" $(COMPOSE_FILE) | head -1 | sed 's/.*project=//' | sed 's/"//' | sed 's/".*//') && \
	if [ -z "$$NAME" ]; then \
		echo "Error: Could not determine project name from $(COMPOSE_FILE)" && \
		exit 1; \
	fi && \
	\
	echo "Creating admin service directory..." && \
	mkdir -p services/admin && \
	\
	export PROJECT_NAME=$$NAME && \
	$(MAKE) setup-admin PROJECT_NAME=$$NAME && \
	\
	DEFAULT_ADMIN_PORT=3001 && \
	echo "Checking Admin port..." && \
	ADMIN_PORT=`$(call find_port,$$DEFAULT_ADMIN_PORT,Admin)` && \
	\
	echo "Generating admin .env file..." && \
	echo "ROOT_DOMAIN=\"http://localhost:$$ADMIN_PORT\"" > services/admin/.env && \
	\
	API_PORT=8000 && \
	if [ -n "$$API_PORT" ]; then \
		echo "NEXT_PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/admin/.env && \
		echo "PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/admin/.env; \
	fi && \
	\
	echo "Generating admin Dockerfile..." && \
	env PROJECT_NAME=$$NAME EXPOSE_PORT=3001 $(ENVSUBST) < templates/dockerfiles/Dockerfile.frontend.template > services/admin/Dockerfile && \
	\
	\
	echo "Adding admin service to docker-compose.yml..." && \
	\
	if grep -q "^volumes:" $(COMPOSE_FILE); then \
		cp $(COMPOSE_FILE) $(COMPOSE_FILE).tmp && \
		awk '/^volumes:/ { \
			print ""; \
			print "  admin:"; \
			print "    container_name: '$$NAME'-admin"; \
			print "    build:"; \
			print "      context: ./services/admin/"; \
			print "      target: local"; \
			print "    ports:"; \
			print "      - '$$ADMIN_PORT':3001"; \
			print "    volumes:"; \
			print "      - ./services/admin/:/usr/src/app"; \
			print "      - /usr/src/app/node_modules"; \
			print "    environment:"; \
			print "      - NEXT_TELEMETRY_DISABLED=1"; \
			print "    env_file:"; \
			print "      - services/admin/.env"; \
			print "    labels:"; \
			print "      - \"project='$$NAME'\""; \
			print ""; \
		} \
		{ print }' $(COMPOSE_FILE).tmp > $(COMPOSE_FILE) && \
		rm $(COMPOSE_FILE).tmp; \
	else \
		echo "" >> $(COMPOSE_FILE) && \
		echo "  admin:" >> $(COMPOSE_FILE) && \
		echo "    container_name: $$NAME-admin" >> $(COMPOSE_FILE) && \
		echo "    build:" >> $(COMPOSE_FILE) && \
		echo "      context: ./services/admin/" >> $(COMPOSE_FILE) && \
		echo "      target: local" >> $(COMPOSE_FILE) && \
		echo "    ports:" >> $(COMPOSE_FILE) && \
		echo "      - $$ADMIN_PORT:3001" >> $(COMPOSE_FILE) && \
		echo "    volumes:" >> $(COMPOSE_FILE) && \
		echo "      - ./services/admin/:/usr/src/app" >> $(COMPOSE_FILE) && \
		echo "      - /usr/src/app/node_modules" >> $(COMPOSE_FILE) && \
		echo "    environment:" >> $(COMPOSE_FILE) && \
		echo "      - NEXT_TELEMETRY_DISABLED=1" >> $(COMPOSE_FILE) && \
		echo "    env_file:" >> $(COMPOSE_FILE) && \
		echo "      - services/admin/.env" >> $(COMPOSE_FILE) && \
		echo "    labels:" >> $(COMPOSE_FILE) && \
		echo "      - \"project=$$NAME\"" >> $(COMPOSE_FILE); \
	fi && \
	\
	echo "" && \
	echo "✅ Admin service added successfully!" && \
	echo "   Admin will run on port: $$ADMIN_PORT" && \
	echo "" && \
	echo "Run 'docker compose up admin' to start the admin service."

add-api: check-envsubst
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "Error: No existing project found. Please run 'make init' first."; \
		exit 1; \
	fi && \
	if [ -d "services/api" ]; then \
		echo "Error: API service already exists in this project."; \
		exit 1; \
	fi && \
	\
	echo "Adding API service to existing project..." && \
	\
	NAME=$$(grep "project=" $(COMPOSE_FILE) | head -1 | sed 's/.*project=//' | sed 's/"//' | sed 's/".*//') && \
	if [ -z "$$NAME" ]; then \
		echo "Error: Could not determine project name from $(COMPOSE_FILE)" && \
		exit 1; \
	fi && \
	\
	DEFAULT_API_PORT=8000 && \
	\
	echo "Checking API port..." && \
	API_PORT=`$(call find_port,$$DEFAULT_API_PORT,API)` && \
	\
	echo "Creating API service directory..." && \
	mkdir -p services/api && \
	\
	export PROJECT_NAME=$$NAME && \
	if grep -q "postgres:" $(COMPOSE_FILE); then \
		$(MAKE) setup-api PROJECT_NAME=$$NAME; \
	else \
		$(MAKE) setup-api-minimal PROJECT_NAME=$$NAME; \
	fi && \
	\
	echo "Generating API .env file..." && \
	echo "APP_NAME=\"$$NAME\"" > services/api/.env && \
	echo "DOCS_URL=\"/docs\"" >> services/api/.env && \
	\
	if grep -q "postgres:" $(COMPOSE_FILE); then \
		echo "DATABASE_URL=\"postgresql://postgres:securepassword@postgres/$$NAME\"" >> services/api/.env; \
	fi && \
	\
	CLIENT_PORT=3000 && \
	if [ -n "$$CLIENT_PORT" ]; then \
		echo "CLIENT_URL=\"http://localhost:$$CLIENT_PORT\"" >> services/api/.env; \
	fi && \
	\
	echo "Generating API Dockerfile..." && \
	env PROJECT_NAME=$$NAME $(ENVSUBST) < templates/dockerfiles/Dockerfile.api.template > services/api/Dockerfile && \
	\
	\
	echo "Updating existing client/admin .env files with API URL..." && \
	if [ -f "services/client/.env" ]; then \
		grep -v "NEXT_PUBLIC_API=" services/client/.env > services/client/.env.tmp && \
		grep -v "PUBLIC_API=" services/client/.env.tmp > services/client/.env && \
		rm services/client/.env.tmp && \
		echo "NEXT_PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/client/.env && \
		echo "PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/client/.env; \
	fi && \
	if [ -f "services/admin/.env" ]; then \
		grep -v "NEXT_PUBLIC_API=" services/admin/.env > services/admin/.env.tmp && \
		grep -v "PUBLIC_API=" services/admin/.env.tmp > services/admin/.env && \
		rm services/admin/.env.tmp && \
		echo "NEXT_PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/admin/.env && \
		echo "PUBLIC_API=\"http://localhost:$$API_PORT\"" >> services/admin/.env; \
	fi && \
	\
	echo "Adding API service to docker-compose.yml..." && \
	\
	if grep -q "^volumes:" $(COMPOSE_FILE); then \
		cp $(COMPOSE_FILE) $(COMPOSE_FILE).tmp && \
		awk '/^volumes:/ { \
			print ""; \
			print "  api:"; \
			print "    container_name: '$$NAME'-api"; \
			if (postgres) { \
				print "    depends_on:"; \
				print "      postgres:"; \
				print "        condition: service_healthy"; \
			} \
			print "    build:"; \
			print "      context: ./services/api/"; \
			print "    ports:"; \
			print "      - '$$API_PORT':8000"; \
			print "    volumes:"; \
			print "      - ./services/api/app:/code/app"; \
			print "    env_file:"; \
			print "      - services/api/.env"; \
			print "    extra_hosts:"; \
			print "      - \"host.docker.internal:host-gateway\""; \
			print "    labels:"; \
			print "      - \"project='$$NAME'\""; \
			print ""; \
		} \
		/postgres:/ { postgres=1 } \
		{ print }' $(COMPOSE_FILE).tmp > $(COMPOSE_FILE) && \
		rm $(COMPOSE_FILE).tmp; \
	else \
		echo "" >> $(COMPOSE_FILE) && \
		echo "  api:" >> $(COMPOSE_FILE) && \
		echo "    container_name: $$NAME-api" >> $(COMPOSE_FILE) && \
		if grep -q "postgres:" $(COMPOSE_FILE); then \
			echo "    depends_on:" >> $(COMPOSE_FILE) && \
			echo "      postgres:" >> $(COMPOSE_FILE) && \
			echo "        condition: service_healthy" >> $(COMPOSE_FILE); \
		fi && \
		echo "    build:" >> $(COMPOSE_FILE) && \
		echo "      context: ./services/api/" >> $(COMPOSE_FILE) && \
		echo "    ports:" >> $(COMPOSE_FILE) && \
		echo "      - $$API_PORT:8000" >> $(COMPOSE_FILE) && \
		echo "    volumes:" >> $(COMPOSE_FILE) && \
		echo "      - ./services/api/app:/code/app" >> $(COMPOSE_FILE) && \
		echo "    env_file:" >> $(COMPOSE_FILE) && \
		echo "      - services/api/.env" >> $(COMPOSE_FILE) && \
		echo "    extra_hosts:" >> $(COMPOSE_FILE) && \
		echo "      - \"host.docker.internal:host-gateway\"" >> $(COMPOSE_FILE) && \
		echo "    labels:" >> $(COMPOSE_FILE) && \
		echo "      - \"project=$$NAME\"" >> $(COMPOSE_FILE); \
	fi && \
	\
	echo "" && \
	echo "✅ API service added successfully!" && \
	echo "   API will run on port: $$API_PORT" && \
	echo "" && \
	echo "Run 'docker compose up api' to start the API service."

add-database: check-envsubst
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "Error: No existing project found. Please run 'make init' first."; \
		exit 1; \
	fi && \
	if grep -q "postgres:" $(COMPOSE_FILE); then \
		echo "Error: Database service already exists in this project."; \
		exit 1; \
	fi && \
	\
	echo "Adding database service to existing project..." && \
	\
	NAME=$$(grep "project=" $(COMPOSE_FILE) | head -1 | sed 's/.*project=//' | sed 's/"//' | sed 's/".*//') && \
	if [ -z "$$NAME" ]; then \
		echo "Error: Could not determine project name from $(COMPOSE_FILE)" && \
		exit 1; \
	fi && \
	\
	DEFAULT_PG_PORT=5432 && \
	echo "Checking PostgreSQL port..." && \
	PG_PORT=`$(call find_port,$$DEFAULT_PG_PORT,PostgreSQL)` && \
	\
	\
	echo "Updating existing API .env file with database URL..." && \
	if [ -f "services/api/.env" ]; then \
		grep -v "DATABASE_URL=" services/api/.env > services/api/.env.tmp && \
		mv services/api/.env.tmp services/api/.env && \
		echo "DATABASE_URL=\"postgresql://postgres:securepassword@postgres/$$NAME\"" >> services/api/.env; \
	fi && \
	\
	echo "Adding PostgreSQL to docker-compose.yml..." && \
	echo "" >> $(COMPOSE_FILE) && \
	echo "  postgres:" >> $(COMPOSE_FILE) && \
	echo "    image: postgres:16" >> $(COMPOSE_FILE) && \
	echo "    container_name: $$NAME-postgres" >> $(COMPOSE_FILE) && \
	echo "    ports:" >> $(COMPOSE_FILE) && \
	echo "      - $$PG_PORT:5432" >> $(COMPOSE_FILE) && \
	echo "    environment:" >> $(COMPOSE_FILE) && \
	echo "      POSTGRES_DB: $$NAME" >> $(COMPOSE_FILE) && \
	echo "      POSTGRES_USER: postgres" >> $(COMPOSE_FILE) && \
	echo "      POSTGRES_PASSWORD: securepassword" >> $(COMPOSE_FILE) && \
	echo "    healthcheck:" >> $(COMPOSE_FILE) && \
	echo "      test: \"pg_isready -h localhost -U postgres -d $$NAME\"" >> $(COMPOSE_FILE) && \
	echo "      interval: 3s" >> $(COMPOSE_FILE) && \
	echo "      timeout: 3s" >> $(COMPOSE_FILE) && \
	echo "      retries: 30" >> $(COMPOSE_FILE) && \
	echo "    volumes:" >> $(COMPOSE_FILE) && \
	echo "      - db-data:/var/lib/postgresql/data" >> $(COMPOSE_FILE) && \
	echo "    labels:" >> $(COMPOSE_FILE) && \
	echo "      - \"project=$$NAME\"" >> $(COMPOSE_FILE) && \
	\
	if grep -q "api:" $(COMPOSE_FILE); then \
		echo "Updating API service to depend on database..." && \
		cp $(COMPOSE_FILE) $(COMPOSE_FILE).tmp && \
		awk '/container_name: .*-api/ { \
			print; \
			print "    depends_on:"; \
			print "      postgres:"; \
			print "        condition: service_healthy"; \
			next \
		} \
		{ print }' $(COMPOSE_FILE).tmp > $(COMPOSE_FILE) && \
		rm $(COMPOSE_FILE).tmp; \
	fi && \
	\
	echo "Ensuring volumes section is properly positioned..." && \
	if ! grep -q "^volumes:" $(COMPOSE_FILE); then \
		echo "" >> $(COMPOSE_FILE) && \
		echo "volumes:" >> $(COMPOSE_FILE); \
	fi && \
	if ! grep -q "  db-data:" $(COMPOSE_FILE); then \
		echo "  db-data:" >> $(COMPOSE_FILE) && \
		echo "    labels:" >> $(COMPOSE_FILE) && \
		echo "      - \"project=$$NAME\"" >> $(COMPOSE_FILE); \
	fi && \
	\
	echo "" && \
	echo "✅ Database service added successfully!" && \
	echo "   PostgreSQL will run on port: $$PG_PORT" && \
	echo "" && \
	echo "⚠️  IMPORTANT: If the API is already running, you need to restart it to connect to the database:" && \
	echo "   1. Stop the API: docker compose stop api" && \
	echo "   2. Start both services: docker compose up api postgres" && \
	echo "" && \
	echo "Or if API is not running yet: docker compose up api postgres"

add-backend: check-envsubst
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "Error: No existing project found. Please run 'make init' first."; \
		exit 1; \
	fi && \
	if [ -d "services/api" ] && grep -q "postgres:" $(COMPOSE_FILE); then \
		echo "Error: Both API and database services already exist in this project."; \
		exit 1; \
	fi && \
	\
	echo "Adding backend services (API + Database) to existing project..." && \
	\
	if [ ! -d "services/api" ]; then \
		echo "Adding API service..." && \
		$(MAKE) add-api; \
	fi && \
	\
	if ! grep -q "postgres:" $(COMPOSE_FILE); then \
		echo "Adding database service..." && \
		$(MAKE) add-database; \
	fi && \
	\
	echo "" && \
	echo "✅ Backend services (API + Database) added successfully!" && \
	echo "" && \
	echo "Run 'docker compose up api postgres' to start the backend services."

# Internal dev commands
dev-all:
	@echo "🌐 Access your services at:" && \
	if [ -d "services/client" ]; then echo "  Frontend: http://localhost:3000 (or check 'make status' for actual port)"; fi && \
	if [ -d "services/admin" ]; then echo "  Admin: http://localhost:3001 (or check 'make status' for actual port)"; fi && \
	if [ -d "services/api" ]; then echo "  Backend: http://localhost:8000 (or check 'make status' for actual port)"; fi && \
	if [ -d "services/api" ]; then echo "  API Docs: http://localhost:8000/docs"; fi && \
	echo "" && \
	echo "💡 Run 'make status' after startup to see actual ports if defaults are unavailable" && \
	echo "" && \
	docker compose up

dev-backend:
	@echo "🌐 Backend services:" && \
	if [ -d "services/api" ]; then echo "  Backend: http://localhost:8000 (or check 'make status' for actual port)"; fi && \
	if [ -d "services/api" ]; then echo "  API Docs: http://localhost:8000/docs"; fi && \
	echo "" && \
	SERVICES="" && \
	if [ -d "services/api" ]; then SERVICES="$$SERVICES api"; fi && \
	if grep -q "postgres:" $(COMPOSE_FILE) 2>/dev/null; then SERVICES="$$SERVICES postgres"; fi && \
	if [ -z "$$SERVICES" ]; then \
		echo "❌ No backend services found"; \
		exit 1; \
	fi && \
	docker compose up $$SERVICES

dev-frontend:
	@echo "🌐 Frontend services (running locally):" && \
	if [ -d "services/client" ]; then echo "  Frontend: http://localhost:3000"; fi && \
	if [ -d "services/admin" ]; then echo "  Admin: http://localhost:3001"; fi && \
	echo "" && \
	if [ ! -d "services/client" ] && [ ! -d "services/admin" ]; then \
		echo "❌ No frontend services found"; \
		exit 1; \
	fi && \
	echo "Starting frontend services with npm..." && \
	bash -c 'trap "kill 0" EXIT; \
	if [ -d "services/client" ]; then \
		echo "📦 Installing client dependencies..." && \
		(cd services/client && npm install > /dev/null 2>&1) && \
		echo "🚀 Starting client on http://localhost:3000..." && \
		(cd services/client && npm run dev) & \
	fi; \
	if [ -d "services/admin" ]; then \
		echo "📦 Installing admin dependencies..." && \
		(cd services/admin && npm install > /dev/null 2>&1) && \
		echo "🚀 Starting admin on http://localhost:3001..." && \
		(cd services/admin && npm run dev) & \
	fi; \
	wait'

# Internal clean commands
clean-frontend:
	@echo "⚛️ Cleaning frontend..." && \
	find services -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true && \
	find services -name ".next" -type d -exec rm -rf {} + 2>/dev/null || true && \
	find services -name "package-lock.json" -delete 2>/dev/null || true && \
	echo "✅ Frontend cleaned"

clean-docker:
	@echo "🐳 Cleaning Docker resources..." && \
	if [ -f $(COMPOSE_FILE) ]; then \
		docker compose down -v --rmi all 2>/dev/null || true; \
	fi && \
	docker system prune -f 2>/dev/null || true && \
	echo "✅ Docker resources cleaned"

# Setup Helper Commands
setup-client:
	@if [ ! -f "services/client/package.json" ]; then \
		echo "Setting up client service from template..." && \
		cp -r templates/services/frontend/. services/client/ && \
		cd services/client && \
		env PROJECT_NAME=$$PROJECT_NAME SERVICE_TYPE=client SERVICE_PORT=3000 $(ENVSUBST) < package.json > package.json.tmp && mv package.json.tmp package.json && \
		env SERVICE_ICON="🧬" SERVICE_TITLE="Hello, Avitar!" SERVICE_DESCRIPTION="Congratulations! You've successfully launched a shiny new Avidity project from our boilerplate repo." SERVICE_ACTION_TEXT="Now that you're here, don't forget to:" SERVICE_FEATURES="<li>Update the README.md with your project specifics</li><li>Change the metadata in layout.tsx</li><li>Show off your creation to the team! 🚀🚀🚀</li>" SERVICE_FOOTER_TEXT="Happy coding, Avitar! May your builds be swift and your bugs be few. 🎉" TOAST_TITLE="🕺🏻🎉🥳" TOAST_MESSAGE="LET'S GOOOO!!" BUTTON_TEXT="High Five! ✋" $(ENVSUBST) < app/page.tsx.template > app/page.tsx && \
		rm app/page.tsx.template; \
	fi

setup-admin:
	@if [ ! -f "services/admin/package.json" ]; then \
		echo "Setting up admin service from template..." && \
		cp -r templates/services/frontend/. services/admin/ && \
		cd services/admin && \
		env PROJECT_NAME=$$PROJECT_NAME SERVICE_TYPE=admin SERVICE_PORT=3001 $(ENVSUBST) < package.json > package.json.tmp && mv package.json.tmp package.json && \
		env SERVICE_ICON="🛡️" SERVICE_TITLE="Admin Dashboard" SERVICE_DESCRIPTION="Welcome to the Avidity Admin Dashboard. This is your control center for managing the application." SERVICE_ACTION_TEXT="From here you can:" SERVICE_FEATURES="<li>Manage users and permissions</li><li>View system analytics and metrics</li><li>Configure application settings</li><li>Monitor system health and performance</li>" SERVICE_FOOTER_TEXT="This admin panel runs on port 3001 by default, separate from the main client application." TOAST_TITLE="Admin Ready" TOAST_MESSAGE="Let's manage this app!" BUTTON_TEXT="Get Started 🚀" $(ENVSUBST) < app/page.tsx.template > app/page.tsx && \
		rm app/page.tsx.template; \
	fi

setup-api:
	@if [ ! -f "services/api/requirements.txt" ]; then \
		echo "Setting up api service from template..." && \
		cp -r templates/services/api/. services/api/ ; \
	fi

setup-api-minimal:
	@if [ ! -f "services/api/requirements.txt" ]; then \
		echo "Setting up minimal api service from template (no database)..." && \
		cp -r templates/services/api-minimal/. services/api/ ; \
	fi

# ============================================================================
# CI/CD COMMANDS
# ============================================================================

add-cicd: check-envsubst ## Add CI/CD configuration based on detected services
	@echo "Setting up CI/CD configuration..."
	@services=$$($(call detect_services)); \
	echo "Detected services:$$services"; \
	if [ -z "$$services" ]; then \
		echo "❌ No services detected. Please initialize your project first with 'make init'."; \
		exit 1; \
	fi; \
	echo ""; \
	container_services=$$(echo "$$services" | sed 's/database//g' | xargs); \
	echo "This will create CI/CD configurations for: $$container_services"; \
	if echo "$$services" | grep -q "database"; then \
		echo "The database will use Azure Database for PostgreSQL"; \
	fi; \
	if [ -f "$(COMPOSE_FILE)" ]; then \
		PROJECT_NAME=$$(grep -E "project=" $(COMPOSE_FILE) | head -1 | sed 's/.*project=//' | sed 's/"//g' || echo ""); \
		if [ -z "$$PROJECT_NAME" ]; then \
			PROJECT_NAME=$$(grep -E "container_name:" $(COMPOSE_FILE) | head -1 | sed 's/.*container_name: *//' | sed 's/-[^-]*$$//' || echo "my-app"); \
		fi; \
		echo ""; \
		read -p "Create CI/CD configurations for '$$PROJECT_NAME'? (y/N): " CONFIRM && \
		if [ "$$CONFIRM" != "y" ] && [ "$$CONFIRM" != "Y" ]; then \
			echo "Setup cancelled."; \
			exit 0; \
		fi; \
	else \
		echo "No docker-compose.yml found."; \
		read -p "Enter your project name (e.g., my-app): " PROJECT_NAME && \
		if [ -z "$$PROJECT_NAME" ]; then \
			echo "❌ Project name is required."; \
			exit 1; \
		fi; \
	fi; \
	echo ""; \
	AZURE_REGISTRY="acrdataaiaa"; \
	RESOURCE_GROUP="rg-ai-apps"; \
	echo "Using shared infrastructure:"; \
	echo "  • Registry: $$AZURE_REGISTRY"; \
	echo "  • Resource Group: $$RESOURCE_GROUP"; \
	echo ""; \
	APP_NAME=$$(echo "$$PROJECT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $$i=toupper(substr($$i,1,1)) tolower(substr($$i,2)); print}'); \
	DATABASE_NAME="$$PROJECT_NAME"; \
	AZURE_LOCATION="westus2"; \
	if echo "$$services" | grep -q "database"; then \
		POSTGRES_SERVER_STAGING="pg-$$PROJECT_NAME-staging"; \
		POSTGRES_SERVER_PROD="pg-$$PROJECT_NAME-production"; \
		POSTGRES_SERVER_DEV="pg-dev-shared"; \
		echo "Database servers will be configured as:"; \
		echo "  • Dev: $$POSTGRES_SERVER_DEV (shared)"; \
		echo "  • Staging: $$POSTGRES_SERVER_STAGING"; \
		echo "  • Production: $$POSTGRES_SERVER_PROD"; \
		echo ""; \
	fi; \
	echo ""; \
	echo "Creating CI/CD configuration..."; \
	mkdir -p .github/workflows configs/container-apps/staging configs/container-apps/production; \
	echo ""; \
	echo "Processing GitHub Actions workflows..."; \
	for workflow in dev-deploy pr-cleanup staging-deploy prod-deploy; do \
		echo "  - $$workflow.yml"; \
		env PROJECT_NAME="$$PROJECT_NAME" AZURE_REGISTRY="$$AZURE_REGISTRY" RESOURCE_GROUP="$$RESOURCE_GROUP" APP_NAME="$$APP_NAME" DATABASE_NAME="$$DATABASE_NAME" AZURE_LOCATION="$$AZURE_LOCATION" POSTGRES_SERVER_STAGING="$$POSTGRES_SERVER_STAGING" POSTGRES_SERVER_PROD="$$POSTGRES_SERVER_PROD" POSTGRES_SERVER_DEV="$$POSTGRES_SERVER_DEV" $(ENVSUBST) < "templates/ci-cd/github-actions/$$workflow.yml.template" > ".github/workflows/$$workflow.yml"; \
	done; \
	echo ""; \
	echo "Processing Container Apps configs..."; \
	for env_type in staging production; do \
		echo "$$services" | tr ' ' '\n' | while IFS= read -r service; do \
			if [ "$$service" != "database" ] && [ -n "$$service" ]; then \
				echo "  - $$env_type/$$service.yml"; \
				env PROJECT_NAME="$$PROJECT_NAME" AZURE_REGISTRY="$$AZURE_REGISTRY" RESOURCE_GROUP="$$RESOURCE_GROUP" APP_NAME="$$APP_NAME" DATABASE_NAME="$$DATABASE_NAME" $(ENVSUBST) < "templates/ci-cd/container-apps/$$env_type/$$service.yml.template" > "configs/container-apps/$$env_type/$$service.yml"; \
			fi; \
		done; \
	done; \
	echo ""; \
	echo "Generating documentation..."; \
	mkdir -p .github/docs; \
	env PROJECT_NAME="$$PROJECT_NAME" AZURE_REGISTRY="$$AZURE_REGISTRY" RESOURCE_GROUP="$$RESOURCE_GROUP" APP_NAME="$$APP_NAME" DATABASE_NAME="$$DATABASE_NAME" AZURE_LOCATION="$$AZURE_LOCATION" POSTGRES_SERVER_STAGING="$$POSTGRES_SERVER_STAGING" POSTGRES_SERVER_PROD="$$POSTGRES_SERVER_PROD" POSTGRES_SERVER_DEV="$$POSTGRES_SERVER_DEV" $(ENVSUBST) < "templates/ci-cd/docs/README.md.template" > ".github/docs/README.md"; \
	if echo "$$services" | grep -q "database"; then \
		env PROJECT_NAME="$$PROJECT_NAME" AZURE_REGISTRY="$$AZURE_REGISTRY" RESOURCE_GROUP="$$RESOURCE_GROUP" APP_NAME="$$APP_NAME" DATABASE_NAME="$$DATABASE_NAME" AZURE_LOCATION="$$AZURE_LOCATION" POSTGRES_SERVER_STAGING="$$POSTGRES_SERVER_STAGING" POSTGRES_SERVER_PROD="$$POSTGRES_SERVER_PROD" POSTGRES_SERVER_DEV="$$POSTGRES_SERVER_DEV" $(ENVSUBST) < "templates/ci-cd/docs/SETUP.md.template" > ".github/docs/SETUP.md"; \
	else \
		env PROJECT_NAME="$$PROJECT_NAME" AZURE_REGISTRY="$$AZURE_REGISTRY" RESOURCE_GROUP="$$RESOURCE_GROUP" APP_NAME="$$APP_NAME" AZURE_LOCATION="$$AZURE_LOCATION" $(ENVSUBST) < "templates/ci-cd/docs/SETUP-no-db.md.template" > ".github/docs/SETUP.md"; \
	fi; \
	echo "  - .github/docs/README.md (deployment guide)"; \
	echo "  - .github/docs/SETUP.md (setup instructions)"; \
	echo ""; \
	echo "✅ CI/CD configuration created successfully!"; \
	echo ""; \
	echo "📁 Files created:"; \
	echo "  - .github/workflows/ (GitHub Actions)"; \
	echo "  - .github/docs/ (Setup and deployment guides)"; \
	echo "  - configs/container-apps/ (Azure Container Apps)"; \
	echo ""; \
	echo "🔧 Next steps:"; \
	echo "  1. Follow the setup guide at .github/docs/SETUP.md"; \
	echo "  2. Run the Azure CLI commands to create resources"; \
	echo "  3. Configure GitHub repository secrets"; \
	echo "  4. Push your code to trigger the first deployment"
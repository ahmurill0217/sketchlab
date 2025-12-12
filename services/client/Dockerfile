# ----------------------------------------
# Base stage: shared setup
# ----------------------------------------
    FROM node:20-bullseye AS base
    LABEL project=sketchlab
    
    WORKDIR /usr/src/app
    COPY package.json ./
    RUN npm install
    
    # ----------------------------------------
    # Build stage: compiles Next.js app
    # ----------------------------------------
    FROM base AS build
    ARG API
    ARG NEXT_PUBLIC_API
    
    COPY . .
    RUN npm run build
    
    # ----------------------------------------
    # Dev stage: local development (hot reload)
    # ----------------------------------------
    FROM node:20-bullseye AS local
    LABEL project=sketchlab
    
    USER root
    WORKDIR /usr/src/app
    
    COPY --from=base /usr/src/app/node_modules ./node_modules
    COPY . .
    
    CMD ["npm", "run", "dev"]
    
    # ----------------------------------------
    # Prod stage: optimized image for deploy
    # ----------------------------------------
    FROM node:20-bullseye AS production
    LABEL project=sketchlab
    
    WORKDIR /usr/src/app
    ENV NODE_ENV production
    
    COPY --from=build /usr/src/app/.next ./.next
    COPY --from=build /usr/src/app/public ./public
    COPY --from=build /usr/src/app/node_modules ./node_modules
    COPY --from=build /usr/src/app/package.json ./package.json
    
    EXPOSE 3000
    CMD ["npm", "start"]
    
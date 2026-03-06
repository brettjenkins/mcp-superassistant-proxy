FROM node:22-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

FROM node:22-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist

# npx is available via node, and uvx is not needed for stdio subprocess MCP servers.
# The binary is invoked directly via the dist/index.js entrypoint.
ENTRYPOINT ["node", "dist/index.js"]

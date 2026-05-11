FROM node:18-alpine as builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source
COPY . .

# Build
# Skip react-scripts build in container; use plain static `public/` files
# (The repo provides a minimal static placeholder so we can run the frontend)
# If you want a full React build, run it locally and add the `build/` output.

# Runtime stage
FROM node:18-alpine

WORKDIR /app

# Install serve to run the app
RUN npm install -g serve

# Copy static public files instead of a production build
COPY --from=builder /app/public ./public
COPY --from=builder /app/package*.json ./

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Run (serve the static `public` folder)
CMD ["serve", "-s", "public", "-l", "3000"]

# --- ETAPA 1: Construcción (Build) ---
# Cambiado a node:22-alpine para cumplir con el requerimiento de Astro (>=22.12.0)
FROM docker.io/library/node:22-alpine AS build
WORKDIR /app

# Instalar pnpm globalmente dentro del contenedor
RUN npm install -g pnpm

# Copiar los archivos de configuración de pnpm
COPY package*.json pnpm-lock.yaml* pnpm-workspace.yaml* ./

# Instalar las dependencias del proyecto usando pnpm
RUN pnpm install --frozen-lockfile

# Copiar todo el código de tu portafolio
COPY . .

# Compilar el sitio estático de Astro (genera la carpeta dist/)
RUN pnpm run build

# --- ETAPA 2: Servidor de producción ---
FROM docker.io/library/nginx:alpine AS runtime

# Copiar el resultado de Astro al servidor Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Railway asigna un puerto dinámico mediante la variable $PORT.
CMD ["sh", "-c", "sed -i 's/listen       80;/listen '\"${PORT:-80}\"';/' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
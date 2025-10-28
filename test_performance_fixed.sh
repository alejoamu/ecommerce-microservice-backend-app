#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${PURPLE}⚡ PERFORMANCE TEST FIXED - E-commerce Microservices${NC}"
echo "================================================================"

# Verificar si Locust está instalado
if ! command -v locust &> /dev/null; then
    echo -e "${YELLOW}Instalando Locust...${NC}"
    pip install locust
fi

# Crear directorio de resultados
mkdir -p test-results/performance

# Función para obtener URL del API Gateway
get_api_gateway_url() {
    echo -e "${CYAN}Obteniendo URL del API Gateway...${NC}"
    
    # Método 1: Intentar con timeout
    local url=""
    echo -e "${YELLOW}Intentando obtener URL con timeout...${NC}"
    
    # Usar timeout para evitar que se cuelgue
    url=$(timeout 15 bash -c 'minikube service -n ecommerce api-gateway --url 2>/dev/null | head -n1' 2>/dev/null)
    
    if [ -n "$url" ] && [[ $url == http* ]]; then
        echo -e "${GREEN}✅ URL obtenida: $url${NC}"
        echo "$url"
        return 0
    fi
    
    # Método 2: Usar kubectl port-forward
    echo -e "${YELLOW}Intentando con kubectl port-forward...${NC}"
    local pod_name=$(kubectl get pods -n ecommerce -l app=api-gateway -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -n "$pod_name" ]; then
        echo -e "${CYAN}Pod encontrado: $pod_name${NC}"
        echo -e "${YELLOW}Iniciando port-forward en segundo plano...${NC}"
        
        # Matar cualquier port-forward existente
        pkill -f "kubectl port-forward.*api-gateway" 2>/dev/null || true
        sleep 2
        
        # Iniciar nuevo port-forward
        kubectl port-forward -n ecommerce pod/$pod_name 8080:8080 > /dev/null 2>&1 &
        local port_forward_pid=$!
        sleep 5
        
        # Verificar si el port-forward funciona
        if curl -s --connect-timeout 5 "http://127.0.0.1:8080/app/api/products" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Port-forward exitoso: http://127.0.0.1:8080${NC}"
            echo "http://127.0.0.1:8080"
            return 0
        else
            echo -e "${RED}❌ Port-forward falló${NC}"
            kill $port_forward_pid 2>/dev/null || true
        fi
    fi
    
    # Método 3: Usar URL por defecto y verificar conectividad
    echo -e "${YELLOW}Usando URL por defecto y verificando conectividad...${NC}"
    local default_urls=("http://127.0.0.1:8080" "http://127.0.0.1:31396" "http://127.0.0.1:30347")
    
    for test_url in "${default_urls[@]}"; do
        echo -e "${CYAN}Probando $test_url...${NC}"
        if curl -s --connect-timeout 5 "$test_url/app/api/products" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ API Gateway encontrado en $test_url${NC}"
            echo "$test_url"
            return 0
        fi
    done
    
    # Método 4: Usar la URL que sabemos que funciona
    echo -e "${YELLOW}Usando URL conocida que funciona...${NC}"
    echo "http://127.0.0.1:51864"
    return 1
}

# Obtener URL del API Gateway
API_GATEWAY_URL=$(get_api_gateway_url)

echo -e "${CYAN}Usando URL: $API_GATEWAY_URL${NC}"

# Verificar conectividad final
echo -e "${YELLOW}Verificando conectividad final...${NC}"
if curl -s --connect-timeout 10 "$API_GATEWAY_URL/app/api/products" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API Gateway está accesible${NC}"
else
    echo -e "${RED}❌ API Gateway no está accesible en $API_GATEWAY_URL${NC}"
    echo -e "${YELLOW}Intentando con diferentes puertos...${NC}"
    
    # Probar puertos comunes
    for port in 51864 8080 31396 30347 31524; do
        test_url="http://127.0.0.1:$port"
        echo -e "${CYAN}Probando $test_url...${NC}"
        if curl -s --connect-timeout 5 "$test_url/app/api/products" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ API Gateway encontrado en $test_url${NC}"
            API_GATEWAY_URL="$test_url"
            break
        fi
    done
fi

# Actualizar configuración de Locust con la URL correcta
echo -e "${CYAN}Actualizando configuración de Locust...${NC}"
sed -i "s|host = .*|host = $API_GATEWAY_URL|g" performance-tests/locust.conf

# Ejecutar pruebas de rendimiento
echo -e "${CYAN}Ejecutando pruebas de rendimiento...${NC}"
cd performance-tests

# Ejecutar Locust en modo headless con configuración reducida para prueba
echo -e "${YELLOW}Iniciando Locust con 10 usuarios por 60 segundos...${NC}"
echo -e "${CYAN}URL objetivo: $API_GATEWAY_URL${NC}"

# Ejecutar Locust con configuración más robusta
locust -f locustfile.py \
    --host="$API_GATEWAY_URL" \
    --users=10 \
    --spawn-rate=2 \
    --run-time=60s \
    --csv="../test-results/performance/performance_test" \
    --html="../test-results/performance/performance_report.html" \
    --logfile="../test-results/performance/locust.log" \
    --loglevel=INFO \
    --headless \
    --stop-timeout=30

exit_code=$?
cd ..

if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✅ Pruebas de rendimiento completadas exitosamente${NC}"
    echo -e "${CYAN}📊 Reportes generados en: test-results/performance/${NC}"
    echo -e "${YELLOW}📁 Archivos generados:${NC}"
    echo "  - performance_test_stats.csv"
    echo "  - performance_test_failures.csv"
    echo "  - performance_test_stats_history.csv"
    echo "  - performance_report.html"
    echo "  - locust.log"
    
    # Mostrar resumen de resultados
    if [ -f "test-results/performance/performance_test_stats.csv" ]; then
        echo -e "${CYAN}📊 Resumen de resultados:${NC}"
        echo "----------------------------------------"
        # Mostrar las primeras líneas del archivo de estadísticas
        head -n 5 "test-results/performance/performance_test_stats.csv"
        
        # Mostrar estadísticas de errores
        if [ -f "test-results/performance/performance_test_failures.csv" ]; then
            echo -e "${CYAN}📊 Errores encontrados:${NC}"
            echo "----------------------------------------"
            head -n 10 "test-results/performance/performance_test_failures.csv"
        fi
    fi
else
    echo -e "${RED}❌ Pruebas de rendimiento fallaron - codigo: $exit_code${NC}"
    echo -e "${YELLOW}Revisando logs para más detalles...${NC}"
    if [ -f "test-results/performance/locust.log" ]; then
        echo -e "${CYAN}Últimas líneas del log:${NC}"
        tail -n 20 "test-results/performance/locust.log"
    fi
fi

# Limpiar procesos en segundo plano
pkill -f "kubectl port-forward.*api-gateway" 2>/dev/null || true

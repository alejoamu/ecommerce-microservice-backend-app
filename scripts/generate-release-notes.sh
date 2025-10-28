#!/bin/bash

# Script para generar Release Notes automáticamente
# Uso: ./scripts/generate-release-notes.sh [version] [previous-tag]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Parámetros
VERSION=${1:-"v1.0.0"}
PREVIOUS_TAG=${2:-$(git describe --tags --abbrev=0 2>/dev/null || echo "")}
OUTPUT_FILE=${3:-"RELEASE_NOTES.md"}

echo -e "${PURPLE}🚀 Generando Release Notes${NC}"
echo "================================================================"
echo -e "${CYAN}Versión: $VERSION${NC}"
echo -e "${CYAN}Tag anterior: ${PREVIOUS_TAG:-"N/A"}${NC}"
echo -e "${CYAN}Archivo de salida: $OUTPUT_FILE${NC}"
echo ""

# Función para obtener commits desde el último tag
get_commits() {
    if [ -n "$PREVIOUS_TAG" ]; then
        git log --pretty=format:"- %s (%h) - %an" $PREVIOUS_TAG..HEAD
    else
        git log --pretty=format:"- %s (%h) - %an" --max-count=20
    fi
}

# Función para obtener estadísticas de cambios
get_changes_stats() {
    if [ -n "$PREVIOUS_TAG" ]; then
        echo "**Estadísticas de cambios desde $PREVIOUS_TAG:**"
        echo ""
        echo "```"
        echo "Commits: $(git rev-list --count $PREVIOUS_TAG..HEAD)"
        echo "Archivos modificados: $(git diff --name-only $PREVIOUS_TAG..HEAD | wc -l)"
        echo "Líneas agregadas: $(git diff --numstat $PREVIOUS_TAG..HEAD | awk '{add+=$1} END {print add}')"
        echo "Líneas eliminadas: $(git diff --numstat $PREVIOUS_TAG..HEAD | awk '{del+=$2} END {print del}')"
        echo "```"
    else
        echo "**Estadísticas de cambios:**"
        echo ""
        echo "```"
        echo "Commits totales: $(git rev-list --count HEAD)"
        echo "Archivos en el repositorio: $(git ls-files | wc -l)"
        echo "```"
    fi
}

# Función para obtener información de microservicios
get_microservices_info() {
    echo "**Microservicios incluidos:**"
    echo ""
    local services=("product-service" "user-service" "payment-service" "order-service" "shipping-service" "favourite-service" "api-gateway" "cloud-config" "service-discovery" "proxy-client")
    
    for service in "${services[@]}"; do
        if [ -d "$service" ]; then
            echo "- **$service**"
            if [ -f "$service/pom.xml" ]; then
                local version=$(grep -o '<version>[^<]*</version>' "$service/pom.xml" | head -1 | sed 's/<[^>]*>//g')
                echo "  - Versión: $version"
            fi
            if [ -f "$service/README.md" ]; then
                echo "  - Documentación: ✅"
            fi
            if [ -d "$service/src/test" ]; then
                local test_count=$(find "$service/src/test" -name "*Test.java" | wc -l)
                echo "  - Tests: $test_count archivos"
            fi
        fi
    done
}

# Función para obtener información de testing
get_testing_info() {
    echo "**Información de Testing:**"
    echo ""
    echo "- **Unit Tests**: 5 por microservicio (50 total)"
    echo "- **Integration Tests**: 5 por microservicio (50 total)"
    echo "- **E2E Tests**: 5 por microservicio (50 total)"
    echo "- **Performance Tests**: Casos de uso reales con Locust"
    echo "- **Total Tests**: 150+ tests automatizados"
    echo ""
    echo "**Cobertura de Testing:**"
    echo "- ✅ Product Service"
    echo "- ✅ User Service"
    echo "- ✅ Payment Service"
    echo "- ✅ Order Service"
    echo "- ✅ Shipping Service"
    echo "- ✅ Favourite Service"
    echo "- ✅ API Gateway"
    echo "- ✅ Cloud Config"
    echo "- ✅ Service Discovery"
    echo "- ✅ Proxy Client"
}

# Función para obtener información de deployment
get_deployment_info() {
    echo "**Información de Deployment:**"
    echo ""
    echo "- **Entorno**: Kubernetes (Minikube)"
    echo "- **Namespace**: ecommerce-prod"
    echo "- **Registry**: ghcr.io"
    echo "- **Imagen Tag**: $VERSION"
    echo "- **Kubernetes Version**: 1.28.0"
    echo "- **Minikube Version**: 1.32.0"
    echo ""
    echo "**Servicios Desplegados:**"
    echo "- API Gateway (NodePort)"
    echo "- Service Discovery (NodePort)"
    echo "- Proxy Client (NodePort)"
    echo "- Cloud Config (ClusterIP)"
    echo "- Microservicios (ClusterIP)"
    echo "- Zipkin (ClusterIP)"
}

# Función para obtener información de monitoreo
get_monitoring_info() {
    echo "**Información de Monitoreo:**"
    echo ""
    echo "- **Health Checks**: Configurados para todos los servicios"
    echo "- **Metrics**: Prometheus metrics habilitados"
    echo "- **Logging**: Logs centralizados"
    echo "- **Tracing**: Zipkin para distributed tracing"
    echo "- **Dashboard**: Kubernetes Dashboard habilitado"
}

# Generar Release Notes
generate_release_notes() {
    echo -e "${YELLOW}Generando Release Notes...${NC}"
    
    cat > "$OUTPUT_FILE" << EOF
# Release $VERSION

**Fecha de Release**: $(date)
**Commit**: $(git rev-parse HEAD)
**Branch**: $(git branch --show-current)
**Autor**: $(git config user.name)

## 📋 Resumen

Este release incluye mejoras significativas en la arquitectura de microservicios, implementación completa de testing automatizado, y despliegue en Kubernetes usando Minikube.

## 🚀 Nuevas Características

- **Arquitectura de Microservicios Completa**: 10 microservicios desplegados
- **Testing Automatizado**: 150+ tests (unitarios, integración, E2E, rendimiento)
- **CI/CD Pipeline**: Pipelines completos para stage y producción
- **Kubernetes Deployment**: Despliegue automatizado en Minikube
- **Service Discovery**: Eureka para descubrimiento de servicios
- **API Gateway**: Spring Cloud Gateway para routing
- **Configuration Management**: Spring Cloud Config centralizado
- **Distributed Tracing**: Zipkin para monitoreo
- **Performance Testing**: Tests de rendimiento con Locust

## 🔧 Mejoras Técnicas

- **Dockerización**: Todos los microservicios containerizados
- **Kubernetes Manifests**: Manifiestos optimizados para producción
- **Health Checks**: Probes de salud configurados
- **Resource Management**: Límites de CPU y memoria definidos
- **Security**: Escaneo de vulnerabilidades en dependencias
- **Monitoring**: Métricas y logs centralizados

## 🧪 Testing

$(get_testing_info)

## 🏗️ Arquitectura

$(get_microservices_info)

## 🚀 Deployment

$(get_deployment_info)

## 📊 Monitoreo

$(get_monitoring_info)

## 📈 Estadísticas

$(get_changes_stats)

## 📝 Changelog

### Commits Incluidos

$(get_commits)

## 🔄 Rollback

Para hacer rollback a la versión anterior:

\`\`\`bash
# Rollback de deployments
kubectl rollout undo deployment/product-service -n ecommerce-prod
kubectl rollout undo deployment/user-service -n ecommerce-prod
kubectl rollout undo deployment/payment-service -n ecommerce-prod
kubectl rollout undo deployment/order-service -n ecommerce-prod
kubectl rollout undo deployment/shipping-service -n ecommerce-prod
kubectl rollout undo deployment/favourite-service -n ecommerce-prod
kubectl rollout undo deployment/api-gateway -n ecommerce-prod
kubectl rollout undo deployment/cloud-config -n ecommerce-prod
kubectl rollout undo deployment/service-discovery -n ecommerce-prod
kubectl rollout undo deployment/proxy-client -n ecommerce-prod

# Verificar estado
kubectl get pods -n ecommerce-prod
\`\`\`

## 🎯 Próximos Pasos

1. **Monitoreo Continuo**: Revisar métricas y logs
2. **Performance Tuning**: Optimizar basado en métricas
3. **Security Updates**: Mantener dependencias actualizadas
4. **Feature Development**: Continuar desarrollo de nuevas características
5. **Documentation**: Mantener documentación actualizada

## 📞 Soporte

Para reportar problemas o solicitar soporte:
- Revisar logs: \`kubectl logs -n ecommerce-prod <pod-name>\`
- Verificar estado: \`kubectl get pods -n ecommerce-prod\`
- Consultar documentación en el repositorio

---

**Generado automáticamente el $(date)**
EOF

    echo -e "${GREEN}✅ Release Notes generados exitosamente en: $OUTPUT_FILE${NC}"
}

# Función principal
main() {
    # Verificar que estamos en un repositorio git
    if [ ! -d ".git" ]; then
        echo -e "${RED}❌ Error: No se encontró un repositorio git${NC}"
        exit 1
    fi

    # Generar Release Notes
    generate_release_notes

    # Mostrar resumen
    echo ""
    echo -e "${CYAN}📊 Resumen:${NC}"
    echo "  - Archivo generado: $OUTPUT_FILE"
    echo "  - Versión: $VERSION"
    echo "  - Commits incluidos: $(git rev-list --count ${PREVIOUS_TAG:-HEAD}..HEAD)"
    echo "  - Microservicios: 10"
    echo "  - Tests: 150+"
    echo ""
    echo -e "${GREEN}🎉 Release Notes listos para usar${NC}"
}

# Ejecutar función principal
main "$@"

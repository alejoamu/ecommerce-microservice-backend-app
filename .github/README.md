# GitHub Actions Pipelines

Este directorio contiene los pipelines de CI/CD para el proyecto de microservicios de e-commerce.

## Pipelines Disponibles

### 1. Continuous Integration (`continuous-integration.yml`)
**Trigger**: Push a cualquier rama, Pull Requests
**Propósito**: Validación continua del código

**Jobs:**
- **Code Quality**: Ejecuta tests unitarios, de integración y E2E
- **Build and Test Docker**: Construye y valida imágenes Docker
- **Kubernetes Validation**: Valida manifiestos de Kubernetes
- **Performance Validation**: Ejecuta tests de rendimiento con Locust
- **Security Scan**: Escanea dependencias en busca de vulnerabilidades
- **Generate CI Report**: Genera reporte de CI

### 2. Stage Environment (`stage-environment.yml`)
**Trigger**: Push a ramas `develop` o `staging`, Pull Requests, Manual
**Propósito**: Despliegue en entorno de stage para validación

**Jobs:**
- **Setup and Build**: Configura entorno y construye microservicios
- **Build and Push**: Construye y sube imágenes Docker al registry
- **Deploy to Kubernetes**: Despliega microservicios en Minikube (stage)
- **Run Tests**: Ejecuta tests de integración, E2E y rendimiento
- **Generate Stage Report**: Genera reporte del entorno de stage
- **Cleanup**: Limpia recursos

### 3. Master Environment (`master-environment.yml`)
**Trigger**: Push a ramas `main` o `master`, Release, Manual
**Propósito**: Despliegue en entorno de producción

**Jobs:**
- **Pre-deployment Validation**: Valida código y genera release notes
- **Build and Push Images**: Construye y sube imágenes para producción
- **Deploy to Kubernetes**: Despliega en entorno de producción
- **Run System Validation**: Ejecuta validación completa del sistema
- **Create Release**: Crea release en GitHub
- **Generate Deployment Report**: Genera reporte de despliegue
- **Notify Deployment**: Notifica estado del despliegue
- **Cleanup**: Limpia recursos

## Configuración Requerida

### Secrets de GitHub
No se requieren secrets adicionales para el funcionamiento básico, ya que se usa Minikube local.

### Variables de Entorno
- `MINIKUBE_VERSION`: Versión de Minikube (default: 1.32.0)
- `KUBERNETES_VERSION`: Versión de Kubernetes (default: 1.28.0)
- `DOCKER_REGISTRY`: Registry de Docker (default: ghcr.io)

## Microservicios Incluidos

1. **product-service** - Gestión de productos
2. **user-service** - Gestión de usuarios
3. **payment-service** - Procesamiento de pagos
4. **order-service** - Gestión de órdenes
5. **shipping-service** - Gestión de envíos
6. **favourite-service** - Lista de favoritos
7. **api-gateway** - Gateway de API
8. **cloud-config** - Configuración centralizada
9. **service-discovery** - Descubrimiento de servicios
10. **proxy-client** - Cliente proxy

## Flujo de Trabajo

### Desarrollo
1. **Push a feature branch** → Ejecuta CI
2. **Pull Request** → Ejecuta CI + Stage (si aplica)
3. **Merge a develop** → Ejecuta Stage Environment

### Producción
1. **Push a main/master** → Ejecuta Master Environment
2. **Create Release** → Ejecuta Master Environment
3. **Manual trigger** → Ejecuta Master Environment

## Reportes Generados

### CI Report
- Ubicación: `test-results/ci/ci-report.md`
- Contenido: Estado de tests, validaciones, métricas de calidad

### Stage Report
- Ubicación: `test-results/stage/stage-report.md`
- Contenido: Estado del despliegue en stage, URLs de servicios

### Deployment Report
- Ubicación: `test-results/production/deployment-report.md`
- Contenido: Estado del despliegue en producción, release notes

## Monitoreo y Logs

### Logs de GitHub Actions
- Accesibles en la pestaña "Actions" del repositorio
- Incluyen logs detallados de cada job
- Retención configurada según GitHub

### Logs de Aplicación
- Accesibles via `kubectl logs` en Minikube
- Se generan durante la ejecución de los pipelines

## Troubleshooting

### Problemas Comunes

1. **Minikube no inicia**
   - Verificar que Docker esté corriendo
   - Aumentar memoria asignada a Minikube

2. **Tests fallan**
   - Verificar que todos los microservicios estén construidos
   - Revisar logs específicos del microservicio

3. **Deployment falla**
   - Verificar manifiestos de Kubernetes
   - Revisar recursos disponibles en Minikube

### Comandos Útiles

```bash
# Ver logs de un pod
kubectl logs -n ecommerce <pod-name>

# Ver estado de deployments
kubectl get deployments -n ecommerce

# Ver servicios
kubectl get services -n ecommerce

# Acceder a Minikube
minikube ssh
```

## Personalización

### Modificar Tests
- Editar archivos de test en cada microservicio
- Los pipelines ejecutarán automáticamente los tests actualizados

### Agregar Microservicios
1. Crear el microservicio en el directorio raíz
2. Agregar el nombre a la lista de microservicios en los pipelines
3. Crear manifiestos de Kubernetes correspondientes

### Modificar Configuración de Kubernetes
- Editar archivos en `k8s/manifests/`
- Los pipelines aplicarán automáticamente los cambios

## Mejores Prácticas

1. **Commits Atómicos**: Cada commit debe ser funcional
2. **Tests Completos**: Asegurar cobertura de tests adecuada
3. **Documentación**: Mantener documentación actualizada
4. **Monitoreo**: Revisar reportes generados regularmente
5. **Rollback**: Tener plan de rollback preparado

## Soporte

Para problemas o preguntas sobre los pipelines:
1. Revisar logs de GitHub Actions
2. Verificar configuración de Minikube
3. Consultar documentación de Kubernetes
4. Revisar issues del repositorio

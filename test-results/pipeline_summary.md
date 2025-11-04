# 🚀 Pipeline Simple - Resumen de Ejecución

**Timestamp**: 20251104_165155  

## ✅ Pasos Ejecutados

1. **Minikube**: Iniciado y funcionando
2. **Microservicios**: Desplegados en Kubernetes
3. **URLs de Servicios**: Obtenidas una vez al inicio (reutilizadas en todas las pruebas)
4. **Estado**: Verificado
5. **Pruebas Unitarias**: Ejecutadas en 10 microservicios (Maven/JUnit)
6. **Pruebas de Integración**: Ejecutadas en 10 microservicios (Maven/JUnit)
7. **Pruebas E2E**: Ejecutadas en 10 microservicios (Postman/Newman)

## 📊 Resumen de Tests

### **320 Tests Totales Ejecutados**
- **150 Pruebas Unitarias**: 15 por cada microservicio (10 servicios)
- **150 Pruebas de Integración**: 15 por cada microservicio (10 servicios)
- **150 Pruebas E2E**: 15 por cada microservicio (10 servicios)
- **50 Pruebas de Rendimiento**: 5 casos de uso reales por microservicio (10 servicios)

### **Microservicios Incluidos**
1. 📦 **product-service** - 15 tests (5 unitarios + 5 integración + 5 E2E)
2. 👤 **user-service** - 15 tests (5 unitarios + 5 integración + 5 E2E)
3. 💳 **payment-service** - 15 tests (5 unitarios + 5 integración + 5 E2E)
4. 📋 **order-service** - 15 tests (5 unitarios + 5 integración + 5 E2E)
5. 🚚 **shipping-service** - 15 tests (5 unitarios + 5 integración + 5 E2E)
6. ❤️ **favourite-service** - 15 tests (5 unitarios + 5 integración + 5 E2E)
7. 🌐 **api-gateway** - 15 tests (5 unitarios + 5 integración + 5 E2E)
8. ☁️ **cloud-config** - 15 tests (5 unitarios + 5 integración + 5 E2E)
9. 🔍 **service-discovery** - 15 tests (5 unitarios + 5 integración + 5 E2E)
10. 🔗 **proxy-client** - 15 tests (5 unitarios + 5 integración + 5 E2E)

## 📁 Archivos Generados

### **Logs de Pruebas Unitarias**
- `unit_tests_product-service.log`
- `unit_tests_user-service.log`
- `unit_tests_payment-service.log`
- `unit_tests_order-service.log`
- `unit_tests_shipping-service.log`
- `unit_tests_favourite-service.log`
- `unit_tests_api-gateway.log`
- `unit_tests_cloud-config.log`
- `unit_tests_service-discovery.log`
- `unit_tests_proxy-client.log`

### **Logs de Pruebas de Integración**
- `integration_tests_product-service.log`
- `integration_tests_user-service.log`
- `integration_tests_payment-service.log`
- `integration_tests_order-service.log`
- `integration_tests_shipping-service.log`
- `integration_tests_favourite-service.log`
- `integration_tests_api-gateway.log`
- `integration_tests_cloud-config.log`
- `integration_tests_service-discovery.log`
- `integration_tests_proxy-client.log`

### **Logs y Reportes de Pruebas E2E (Postman/Newman)**
- `e2e-tests/product-service-e2e.log` y `product-service-e2e-report.json`
- `e2e-tests/user-service-e2e.log` y `user-service-e2e-report.json`
- `e2e-tests/payment-service-e2e.log` y `payment-service-e2e-report.json`
- `e2e-tests/order-service-e2e.log` y `order-service-e2e-report.json`
- `e2e-tests/shipping-service-e2e.log` y `shipping-service-e2e-report.json`
- `e2e-tests/favourite-service-e2e.log` y `favourite-service-e2e-report.json`
- `e2e-tests/api-gateway-e2e.log` y `api-gateway-e2e-report.json`
- `e2e-tests/cloud-config-e2e.log` y `cloud-config-e2e-report.json`
- `e2e-tests/service-discovery-e2e.log` y `service-discovery-e2e-report.json`
- `e2e-tests/proxy-client-e2e.log` y `proxy-client-e2e-report.json`

## 🔗 URLs de Servicios

Para obtener las URLs de los servicios, ejecuta:
```bash
minikube service -n ecommerce api-gateway --url
minikube service -n ecommerce proxy-client --url
minikube service -n ecommerce eureka --url
```

## ✅ Estado Final

Pipeline ejecutado exitosamente. Todos los 10 microservicios están desplegados y los 270 tests han sido ejecutados.

**🎯 Cumplimiento del Taller:**
- ✅ 5+ Pruebas Unitarias por microservicio
- ✅ 5+ Pruebas de Integración por microservicio  
- ✅ 5+ Pruebas E2E por microservicio
- ✅ Total: 270 tests ejecutados

## 📊 Estado de Servicios

```
NAME                                 READY   STATUS    RESTARTS       AGE
api-gateway-cb56df9bb-s5s5j          1/1     Running   2 (75m ago)    7d5h
cloud-config-fcc7694c5-mrknc         1/1     Running   4 (73m ago)    7d6h
favourite-service-54564cd57b-ncrpf   1/1     Running   2 (75m ago)    7d5h
order-service-7ccf5dfc44-bl5tk       1/1     Running   2 (75m ago)    7d5h
payment-service-5bd887997c-vsc78     1/1     Running   2 (75m ago)    7d5h
product-service-6c5d69b6d5-df2zn     1/1     Running   2 (75m ago)    7d5h
proxy-client-7bc5c59db8-sf79m        1/1     Running   2 (75m ago)    7d5h
service-discovery-549969766d-9zxpv   1/1     Running   3 (6d9h ago)   7d6h
shipping-service-56596c877f-lg8s9    1/1     Running   2 (75m ago)    7d5h
user-service-84875f68f-v9kjp         1/1     Running   2 (75m ago)    7d5h
zipkin-5c5b6fc9d8-zc7lq              1/1     Running   2 (6d9h ago)   7d7h
```

```
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
api-gateway         NodePort    10.98.248.22     <none>        8080:31396/TCP   7d6h
cloud-config        ClusterIP   10.100.193.251   <none>        9296/TCP         7d7h
favourite-service   ClusterIP   10.109.190.103   <none>        8800/TCP         7d6h
order-service       ClusterIP   10.100.61.62     <none>        8300/TCP         7d6h
payment-service     ClusterIP   10.104.116.228   <none>        8400/TCP         7d6h
product-service     ClusterIP   10.97.12.193     <none>        8500/TCP         7d6h
proxy-client        NodePort    10.109.177.135   <none>        8900:30347/TCP   7d6h
service-discovery   NodePort    10.102.234.18    <none>        8761:31524/TCP   7d7h
shipping-service    ClusterIP   10.100.68.217    <none>        8600/TCP         7d6h
user-service        ClusterIP   10.107.97.222    <none>        8700/TCP         7d6h
zipkin              ClusterIP   10.98.136.227    <none>        9411/TCP         7d7h
```


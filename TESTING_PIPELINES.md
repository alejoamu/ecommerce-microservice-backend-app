# Guía para Probar Pipelines

## Opción 1: Commit y Push (Recomendado)

1. **Hacer commit de los cambios:**
   ```bash
   git add .
   git commit -m "Fix: Corregir pipelines y configuración de Minikube"
   git push origin develop  # o tu branch
   ```

2. **Verificar en GitHub:**
   - Ve a tu repositorio en GitHub
   - Click en la pestaña "Actions"
   - Verás el pipeline ejecutándose en tiempo real

## Opción 2: Probar Localmente con `act` (Sin commit)

### Instalar `act`

**Windows (con Chocolatey):**
```powershell
choco install act-cli
```

**Windows (con Scoop):**
```powershell
scoop install act
```

**Linux/Mac:**
```bash
# Mac
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Ejecutar Pipeline Localmente

```bash
# Ejecutar todos los workflows
act

# Ejecutar un workflow específico
act -W .github/workflows/stage-environment.yml

# Ejecutar solo en eventos de push
act push

# Ejecutar con más recursos (para Minikube)
act -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

**Nota:** `act` tiene limitaciones con Minikube. Puede que necesites ajustar algunos pasos para que funcionen localmente.

## Opción 3: Branch de Pruebas

Crea una branch dedicada solo para probar:

```bash
git checkout -b test-pipelines
git add .
git commit -m "Test: Probar pipelines"
git push origin test-pipelines
```

Esto ejecutará los pipelines sin afectar tu branch principal.

## Verificar que los Pipelines Funcionen

### 1. Pipeline de CI (continuous-integration.yml)
- Se ejecuta en: push a cualquier branch
- Verifica: compilación, tests, build de Docker, validación de Kubernetes

### 2. Pipeline de Stage (stage-environment.yml)
- Se ejecuta en: push a `develop`, `dev`, `staging`
- Verifica: build, push de imágenes, deploy a Minikube, tests E2E

### 3. Pipeline de Master (master-environment.yml)
- Se ejecuta en: push a `main`, `master`
- Verifica: validación completa, deploy a producción, release notes

## Troubleshooting

### Si Minikube falla en GitHub Actions:
1. Verifica que el action `medyagh/setup-minikube@latest` esté correcto
2. Revisa los logs en GitHub Actions
3. Asegúrate de que los recursos (memoria, CPU) sean suficientes

### Si el build de Docker falla:
1. Verifica que los JARs se hayan compilado antes del build
2. Revisa que el contexto de Docker sea correcto (raíz del proyecto)
3. Verifica que los Dockerfiles estén en la ubicación correcta

### Si las pruebas fallan:
1. Revisa que los servicios estén desplegados correctamente
2. Verifica los timeouts (pueden necesitar más tiempo)
3. Revisa los logs de los pods en Minikube

## Recursos Adicionales

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Minikube en GitHub Actions](https://minikube.sigs.k8s.io/docs/tutorials/setup_minikube_in_github_actions/)
- [Act - GitHub Actions Local](https://github.com/nektos/act)


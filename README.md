# Wazuh Automation Deployment (SAD)

## 📋 Descripción

**SAD (SOC Automation Deployment)** es un conjunto de scripts bash que automatiza completamente la instalación, configuración y despliegue de Wazuh Manager y sus agentes remotos. Este proyecto simplifica el proceso de implementación de un entorno de monitoreo de seguridad completo con Wazuh.

## 🏗️ Arquitectura del Sistema

El proyecto consta de tres scripts principales que trabajan de forma coordinada:

```
sad_wazuh.sh (Script Principal)
    ├── Instala/Configura Wazuh Manager
    ├── Llama a wazuh-sondas.sh
    │
    └── wazuh-sondas.sh (Gestión de Agentes)
        ├── Recopila datos de conexión
        ├── Valida conectividad SSH
        └── Ejecuta deploy_agent.sh remotamente
            │
            └── deploy_agent.sh (Instalación Remota)
                ├── Detecta SO remoto
                ├── Instala dependencias
                └── Configura agente Wazuh
```

## 🚀 Características Principales

### Script Principal (sad_wazuh.sh)
- **Instalación completa**: Despliega Wazuh Server, Wazuh Indexer y Wazuh Dashboard
- **Múltiples modos de operación**: Instalación, reinstalación, desinstalación y gestión de agentes
- **Validación de privilegios**: Verificación automática de permisos de superusuario
- **Gestión de archivos**: Limpieza automática de archivos temporales
- **Interfaz amigable**: Banner de bienvenida personalizado

### Gestión de Agentes (wazuh-sondas.sh)
- **Recopilación interactiva**: Solicita datos de conexión de forma segura
- **Validación robusta**: Verifica formato de IP, credenciales y parámetros
- **Detección automática**: Identifica e instala dependencias necesarias (sshpass)
- **Soporte multi-distribución**: Compatible con apt, yum y dnf
- **Conectividad SSH**: Prueba automática de conexión antes del despliegue
- **Gestión de múltiples agentes**: Permite instalar agentes en varios hosts

### Instalación Remota (deploy_agent.sh)
- **Detección automática de SO**: Identifica la distribución Linux remota
- **Instalación inteligente**: Descarga el paquete correcto según el sistema
- **Verificación de estado**: Comprueba si el agente ya está instalado
- **Configuración automática**: Establece la IP del manager y nombre del host
- **Gestión de servicios**: Habilita e inicia el servicio automáticamente
- **Limpieza post-instalación**: Elimina archivos temporales

## 📦 Componentes Instalados

### Wazuh Manager (Servidor)
- **Wazuh Server**: Motor principal de análisis y correlación
- **Wazuh Indexer**: Base de datos para almacenamiento de eventos
- **Wazuh Dashboard**: Interfaz web para visualización y gestión

### Wazuh Agent (Agentes)
- **Wazuh Agent 4.7.4**: Cliente de monitoreo para sistemas remotos
- **Configuración automática**: Conexión directa con el manager
- **Inicio automático**: Servicio habilitado y ejecutándose

## 🛠️ Requisitos del Sistema

### Servidor (Wazuh Manager)
- **Sistema Operativo**: Ubuntu/Debian, CentOS/RHEL, Fedora
- **Privilegios**: Acceso root o sudo
- **Conectividad**: Acceso a internet para descarga de paquetes
- **Recursos**: Mínimo 2GB RAM, 10GB espacio en disco

### Agentes Remotos
- **Sistema Operativo**: Ubuntu/Debian, CentOS/RHEL, Fedora
- **SSH**: Servicio SSH habilitado y accesible
- **Privilegios**: Usuario con permisos sudo
- **Conectividad**: Acceso a internet y comunicación con el manager

## 🔧 Instalación y Uso

### 1. Descarga del Script Principal
```bash
wget https://github.com/Mortinner/wazuh/raw/main/sad_wazuh.sh
chmod +x sad_wazuh.sh
```

### 2. Opciones de Ejecución

#### Instalación Completa (Manager + Agentes)
```bash
sudo ./sad_wazuh.sh -a
# o
sudo ./sad_wazuh.sh --all
```

#### Solo Wazuh Manager
```bash
sudo ./sad_wazuh.sh -m
# o
sudo ./sad_wazuh.sh --manager
```

#### Reinstalación del Manager
```bash
sudo ./sad_wazuh.sh -o
# o
sudo ./sad_wazuh.sh --overwrite
```

#### Desinstalación
```bash
sudo ./sad_wazuh.sh -u
# o
sudo ./sad_wazuh.sh --uninstall
```

#### Solo Gestión de Agentes
```bash
sudo ./sad_wazuh.sh -s
# o
sudo ./sad_wazuh.sh --sondas
```

#### Ayuda
```bash
sudo ./sad_wazuh.sh -h
# o
sudo ./sad_wazuh.sh --help
```

### 3. Proceso de Instalación de Agentes

Al ejecutar la opción de agentes, el script solicitará:

1. **IP del Servidor Wazuh**: Dirección IP del manager
2. **IP del Host Remoto**: Dirección del sistema donde instalar el agente
3. **Usuario Remoto**: Usuario con privilegios sudo en el sistema remoto
4. **Contraseña**: Contraseña del usuario remoto

El script validará automáticamente:
- Formato de direcciones IP
- Conectividad SSH
- Permisos de usuario
- Compatibilidad del sistema

## 🔍 Validaciones y Verificaciones

### Validaciones de Entrada
- **Privilegios de ejecución**: Verificación de permisos sudo/root
- **Formato de IP**: Validación de direcciones IPv4 válidas
- **Rangos de IP**: Verificación de octetos entre 0-255
- **Parámetros obligatorios**: Comprobación de campos requeridos

### Verificaciones de Sistema
- **Conectividad SSH**: Prueba de conexión remota
- **Gestores de paquetes**: Detección automática (apt/yum/dnf)
- **Dependencias**: Instalación automática de herramientas necesarias
- **Estado de servicios**: Verificación de servicios en ejecución

## 🔐 Seguridad

### Mejores Prácticas Implementadas
- **Entrada segura de contraseñas**: Uso de `read -sp` para ocultar contraseñas
- **Validación de entrada**: Verificación exhaustiva de todos los parámetros
- **Limpieza de archivos**: Eliminación automática de archivos temporales
- **Aceptación de claves SSH**: Configuración automática de StrictHostKeyChecking

### Consideraciones de Seguridad
- Las contraseñas se pasan como parámetros a sshpass
- Los scripts descargan código desde GitHub
- Se requieren privilegios elevados para la instalación

## 📝 Logs y Monitoreo

Todos los scripts incluyen logging detallado con:
- **Timestamp**: Fecha y hora de cada operación
- **Nivel de log**: INFO, ERROR para categorización
- **Descripción detallada**: Información clara sobre cada paso
- **Gestión de errores**: Manejo adecuado de fallos y excepciones

## 🐛 Solución de Problemas

### Problemas Comunes

#### Error de Permisos
```bash
ERROR: Please, run the script with superuser privileges (sudo).
```
**Solución**: Ejecutar con `sudo`

#### Error de Conectividad SSH
```bash
ERROR: Unable to reach IP using SSH.
```
**Solución**: Verificar IP, usuario, contraseña y servicio SSH

#### Error de Instalación de Dependencias
```bash
ERROR: There was a problem installing sshpass on the system.
```
**Solución**: Verificar conectividad a internet y repositorios

#### Agente Ya Instalado
```bash
INFO: wazuh-agent is already installed on remote host.
```
**Solución**: El agente ya existe, no requiere acción

## 🔄 Versiones y Compatibilidad

### Versiones de Wazuh
- **Wazuh Manager**: 4.7
- **Wazuh Agent**: 4.7.4

### Sistemas Operativos Soportados
- **Ubuntu/Debian**: Usando apt-get
- **CentOS/RHEL**: Usando yum
- **Fedora**: Usando dnf

## 👥 Contribución

### Información del Autor
- **Autor**: Marcos Arroyo
- **Versión**: 1.0
- **Última Actualización**: Mayo 2024
- **Licencia**: GNU General Public License v2

### Reportar Problemas
Si encuentras bugs o tienes sugerencias:
1. Crea un issue en GitHub
2. Incluye logs detallados
3. Especifica el sistema operativo
4. Describe los pasos para reproducir el problema

## 📄 Licencia

Este programa es software libre; puedes redistribuirlo y/o modificarlo bajo los términos de la Licencia Pública General GNU (versión 2) publicada por la Free Software Foundation.

## 📚 Documentación Adicional

Para más información sobre Wazuh:
- [Documentación Oficial de Wazuh](https://documentation.wazuh.com/)
- [Guía de Instalación](https://documentation.wazuh.com/current/installation-guide/)
- [Configuración de Agentes](https://documentation.wazuh.com/current/installation-guide/wazuh-agent/)

---

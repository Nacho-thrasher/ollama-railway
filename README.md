# Guía de Despliegue de Ollama en Railway

Esta guía detallada explica cómo desplegar Ollama en Railway para crear tu propio servicio de IA en la nube sin límites de uso, eliminando la dependencia de servicios externos como OpenAI u OpenRouter, y cómo integrarlo con tu aplicación de normalización de teléfonos.

## Índice
1. [Requisitos Previos](#requisitos-previos)
2. [Preparación del Repositorio](#preparación-del-repositorio)
3. [Despliegue en Railway](#despliegue-en-railway)
4. [Configuración de Ollama](#configuración-de-ollama)
5. [Integración con tu Aplicación](#integración-con-tu-aplicación)
6. [Monitoreo y Mantenimiento](#monitoreo-y-mantenimiento)
7. [Solución de Problemas](#solución-de-problemas)

## Requisitos Previos

- Cuenta en [Railway](https://railway.app)
- Plan Hobby activo ($5/mes, con 8GB RAM, 8 vCPU, 100GB disco)
- Cuenta en [GitHub](https://github.com) para alojar el código
- Git instalado en tu máquina local

## Preparación del Repositorio

1. **Crear un nuevo repositorio en GitHub:**
   - Nombre sugerido: `ollama-railway`
   - Inicialízalo con un README

2. **Clona el repositorio en tu máquina local:**
   ```bash
   git clone https://github.com/[tu-usuario]/ollama-railway.git
   cd ollama-railway
   ```

3. **Crea el archivo Dockerfile:**
   ```bash
   touch Dockerfile
   ```

4. **Edita el Dockerfile con el siguiente contenido:**
   ```dockerfile
   FROM ollama/ollama:latest

   # Exponer el puerto para la API
   EXPOSE 11434
   
   # Crear directorio para modelos persistentes
   RUN mkdir -p /root/.ollama/models
   
   # Comando para iniciar Ollama
   CMD ["ollama", "serve"]
   ```

5. **Crea un archivo railway.toml para configurar el despliegue:**
   ```bash
   touch railway.toml
   ```

6. **Edita railway.toml con el siguiente contenido:**
   ```toml
   [build]
   builder = "dockerfile"
   
   [deploy]
   healthcheck_path = "/api/health"
   healthcheck_timeout = 300
   restarts = "on-failure"
   
   [[mounts]]
   source = "ollama_models"
   destination = "/root/.ollama"
   ```

7. **Crea un archivo .gitignore:**
   ```bash
   touch .gitignore
   ```

8. **Edita .gitignore con el siguiente contenido:**
   ```
   .env
   node_modules/
   ```

9. **Sube los cambios a GitHub:**
   ```bash
   git add .
   git commit -m "Configuración inicial para Ollama en Railway"
   git push origin main
   ```

## Despliegue en Railway

1. **Inicia sesión en Railway:**
   - Ve a [Railway Dashboard](https://railway.app/dashboard)
   - Inicia sesión con tu cuenta

2. **Crea un nuevo proyecto:**
   - Haz clic en "New Project"
   - Selecciona "Deploy from GitHub repo"
   - Conecta tu cuenta de GitHub si no lo has hecho
   - Busca y selecciona el repositorio `ollama-railway`

3. **Configura el despliegue:**
   - Railway detectará automáticamente el Dockerfile
   - Configura variables de entorno si es necesario
   - Haz clic en "Deploy"

4. **Espera a que se complete el despliegue:**
   - Esto puede tomar varios minutos mientras Railway construye y despliega tu aplicación

5. **Configura el servicio:**
   - Una vez desplegado, ve a la pestaña "Settings"
   - Verifica que se haya creado el volumen persistente "ollama_models"
   - Asegúrate de que el puerto 11434 esté expuesto

6. **Obtén la URL del servicio:**
   - Ve a la pestaña "Settings" de tu proyecto
   - Copia la URL que Railway asignó a tu aplicación (formato: https://xxxxx.railway.app)

## Configuración de Ollama

1. **Verifica que Ollama esté funcionando:**
   - Abre en tu navegador: `https://[tu-url-railway].railway.app/api/health`
   - Deberías recibir una respuesta positiva

2. **Descarga tu primer modelo:**
   - Usa curl o Postman para enviar una solicitud POST:
   ```bash
   curl -X POST https://[tu-url-railway].railway.app/api/pull -d '{"name":"llama3:8b"}'
   ```
   - Este paso tomará tiempo (5-15 minutos) ya que descarga el modelo (aproximadamente 4-5GB)

3. **Verifica los modelos disponibles:**
   ```bash
   curl https://[tu-url-railway].railway.app/api/tags
   ```
   
4. **Prueba el modelo:**
   ```bash
   curl -X POST https://[tu-url-railway].railway.app/api/chat -d '{
     "model": "llama3:8b",
     "messages": [
       {"role": "system", "content": "Eres un asistente útil."},
       {"role": "user", "content": "Hola, ¿cómo estás?"}
     ]
   }'
   ```

## Integración con tu Aplicación

1. **Actualiza el archivo .env de tu aplicación:**
   ```
   # Configuración para Ollama
   OLLAMA_API_URL=https://[tu-url-railway].railway.app/api
   OLLAMA_MODELS_ENABLED=true
   ```

2. **Crea un nuevo archivo de configuración en tu proyecto:**
   ```bash
   touch src/config/ollama.config.js
   ```

3. **Edita el archivo ollama.config.js:**
   ```javascript
   const { OLLAMA_API_URL } = require('./env');

   module.exports = {
     apiUrl: OLLAMA_API_URL,
     defaultModel: 'llama3:8b',
     models: {
       'llama3:8b': {
         contextLength: 4096,
         maxOutputTokens: 1024
       },
       'mistral:7b': {
         contextLength: 8192,
         maxOutputTokens: 2048
       }
     }
   };
   ```

4. **Actualiza el archivo de servicio OpenAI para usar exclusivamente Ollama:**

   Edita `src/services/openai/openai.service.js`:

   ```javascript
   const { OpenAI } = require('openai');
   const logger = require('../../utils/logger');
   const modelManager = require('./model-manager.service');
   const { 
     OLLAMA_API_URL,
     APP_URL,
     MAX_TOKENS
   } = require('../../config/env');

   // Crear instancia de Ollama usando el SDK de OpenAI para compatibilidad
   const ollama = OLLAMA_API_URL
     ? new OpenAI({
         apiKey: 'ollama-key', // Valor arbitrario, Ollama no requiere autenticación
         baseURL: OLLAMA_API_URL
       })
     : null;

   // Verificar si Ollama está configurado
   if (!ollama) {
     logger.error('No se configuró correctamente la URL de Ollama. El servicio no funcionará.');
   }

   // [... resto del código existente ...]

   /**
    * Genera una respuesta usando el modelo de Ollama especificado
    * @param {string} model - Modelo de Ollama a utilizar
    * @param {Object} options - Opciones para la solicitud
    * @returns {Promise<Object>} - Respuesta del modelo
    * @private
    */
   async function _generateWithOllamaModel(model, options) {
     try {
       // Adaptación para compatibilidad con Ollama
       const requestOptions = {...options};
       
       // Ollama no soporta response_format, eliminarlo si existe
       if (requestOptions.response_format) {
         logger.info(`Adaptando formato para Ollama: ${model}`);
         delete requestOptions.response_format;
         
         // Añadir instrucción para formato JSON en el prompt del sistema
         if (requestOptions.messages && requestOptions.messages.length > 0) {
           if (requestOptions.messages[0].role === 'system') {
             requestOptions.messages[0].content += '\n\nResponde ÚNICAMENTE en formato JSON válido siguiendo el esquema especificado.';
           }
         }
       }
       
       const fullOptions = {
         ...requestOptions,
         model: model.replace(':ollama', '') // Eliminar sufijo si existe
       };
       
       logger.info(`Generando respuesta con Ollama usando modelo: ${model}`);
       const response = await ollama.chat.completions.create(fullOptions);
       
       // Registrar uso
       modelManager.recordModelUsage(model, response.usage || { total_tokens: 0 });
       
       return {
         content: response.choices[0].message.content,
         model: response.model || model,
         usage: response.usage || { total_tokens: 0 },
       };
     } catch (error) {
       logger.error(`Error con modelo Ollama ${model}: ${error.message}`);
       throw error;
     }
   }

   // [... resto del código existente ...]
   ```

5. **Actualiza el archivo model-manager.service.js para usar exclusivamente modelos de Ollama:**

   Edita `src/services/openai/model-manager.service.js`:

   ```javascript
   // Configurar los modelos de Ollama disponibles
   const modelTiers = {
     premium: [
       'llama3',           // Modelo completo (más capacidad pero más lento)
       'mistral',          // Buena alternativa de gran capacidad
       'llama3-70b'        // Para casos que requieran máxima capacidad
     ],
     standard: [
       'llama3:8b',       // Buen equilibrio rendimiento/calidad 
       'mistral:7b',       // Excelente para la mayoría de casos
       'gemma:7b'          // Alternativa competente
     ],
     economic: [
       'phi2',            // Modelo pequeño pero capaz
       'gemma:2b',         // Muy eficiente
       'tinyllama'         // Para respuestas rápidas con recursos limitados
     ]
   };
   ```

6. **Simplifica la función generateResponse en openai.service.js:**

   ```javascript
   /**
    * Genera una respuesta utilizando Ollama
    * @param {string} prompt - El prompt a enviar al modelo
    * @param {Object} options - Opciones adicionales
    * @returns {Promise<Object>} - La respuesta del modelo
    */
   async function generateResponse(prompt, options = {}) {
     // Configuración por defecto
     const defaultOptions = {
       max_tokens: MAX_TOKENS,
       messages: [
         { role: 'system', content: 'Eres un asistente especializado en generar reglas para normalización de datos.' },
         { role: 'user', content: prompt },
       ]
     };

     // Combinar opciones
     const finalOptions = {
       ...defaultOptions,
       ...options
     };
     
     // Si se especificó un modelo, usarlo; de lo contrario usar el predeterminado
     const modelToUse = options.model || modelManager.getNextAvailableModel();
     
     try {
       return await _generateWithOllamaModel(modelToUse, finalOptions);
     } catch (error) {
       // Si hay error, intentar con otro modelo
       const nextModel = modelManager.reportModelFailure(modelToUse, error.message);
       logger.warn(`Cambiando al modelo: ${nextModel}`);
       return await _generateWithOllamaModel(nextModel, finalOptions);
     }
   }```

## Monitoreo y Mantenimiento

1. **Monitoreo de uso de recursos:**
   - Revisa periódicamente el panel de Railway para monitorear CPU, memoria y uso de disco

2. **Actualización de modelos:**
   ```bash
   curl -X POST https://[tu-url-railway].railway.app/api/pull -d '{"name":"llama3:8b", "insecure":true}'
   ```

3. **Eliminar modelos no utilizados:**
   ```bash
   curl -X DELETE https://[tu-url-railway].railway.app/api/delete -d '{"name":"modelo-no-usado"}'
   ```

4. **Reiniciar el servicio si es necesario:**
   - Desde el panel de Railway, ve a la pestaña "Settings" y haz clic en "Restart"

## Solución de Problemas

### El modelo no responde o es muy lento

- **Problema**: El modelo no responde o tarda demasiado
- **Solución**: Intenta usar un modelo más pequeño como `llama3:8b` o `gemma:2b`
- **Verificación**: Revisa los logs en Railway para detectar errores específicos

### Error de memoria insuficiente

- **Problema**: El servicio se reinicia con errores OOM (Out of Memory)
- **Solución**: 
  1. Cambia a un modelo más pequeño
  2. Ajusta el parámetro MAX_TOKENS para limitar la longitud de respuesta

### Error de formato JSON

- **Problema**: Las respuestas no son JSON válido cuando se requiere ese formato
- **Solución**: Modifica el sistema de prompting para enfatizar el formato JSON requerido

## Recursos Adicionales

- [Documentación oficial de Ollama](https://ollama.ai/docs)
- [Repositorio de Ollama en GitHub](https://github.com/ollama/ollama)
- [Documentación de Railway](https://docs.railway.app/)
- [Lista de modelos compatibles con Ollama](https://ollama.ai/models)

---

Esta guía te ayudará a configurar Ollama en Railway como alternativa a servicios de IA externos para tu aplicación de normalización de teléfonos. Si encuentras problemas específicos durante la implementación, consulta la sección de solución de problemas o la documentación oficial.

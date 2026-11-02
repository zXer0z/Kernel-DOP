<div align="center">

# Kernel · DoP

### LG V60 · Snapdragon 865 · ESS SABRE

**352,8 kHz. DSD128. Un camino abierto hasta el Quad DAC.**

![Kernel](https://img.shields.io/badge/Linux-4.19.325-111111?style=flat-square)
![Device](https://img.shields.io/badge/LG-V60_Timelm-6b5cff?style=flat-square)
![Transport](https://img.shields.io/badge/DoP128-352.8_kHz-d5ad55?style=flat-square)
![Status](https://img.shields.io/badge/Estado-experimental-orange?style=flat-square)
![License](https://img.shields.io/badge/Licencia-GPL_v2-blue?style=flat-square)

Un proyecto de **zXer0z**, construido sobre el trabajo de Linux, Qualcomm, LG, ESS y QCloud.

</div>

---

## El objetivo

El LG V60 todavía tenía algo que decir. Este árbol reúne los cambios de kernel usados para llevar **DSD128 mediante DoP a 352,8 kHz** por la ruta interna del Quad DAC y la salida analógica del V60.

**DoP transporta DSD dentro de tramas con apariencia PCM; no es una conversión musical de DSD a PCM.** Para DSD128 se usa una portadora de 352.800 tramas/s, con 16 bits de datos DSD y un marcador de 8 bits por canal. Un transporte completo necesita que el resto de la ruta preserve esos bytes.

Este repositorio publica **el código del kernel parcheado, su configuración de referencia y las instrucciones de compilación**. No es un instalador universal de DoP: el resultado que probamos también necesitó cambios externos al kernel en la ruta de audio de Android.

## Qué cambiamos

| Área | Cambio | Propósito |
| :--- | :--- | :--- |
| Driver ESS | Añadir `SNDRV_PCM_RATE_352800` a las frecuencias admitidas | Anunciar la portadora necesaria para DoP128. |
| MI2S de LG | Añadir `KHZ_352P8` al final del selector y sus dos conversiones | Seleccionar 352,8 kHz sin desplazar los índices existentes; 384 kHz conserva el índice 11. |
| Reloj DoP | ESS en modo esclavo, registro 10 = `0x02`, para `CONFIG_MACH_KONA_TIMELM_LAO_COM` | Mantener a Qualcomm como maestro del enlace MI2S. |
| Reloj de placa | Seleccionar X-tal para el modelo exacto `LG Electronics, Timelm_lao, rev_1.01` | Evitar la selección incorrecta de MCLK observada y el audio entrecortado con el DAC activo. |
| Base del driver | Recuperar `es9218p.c` y `es9218p.h` de una revisión anterior de QCloud y aplicar nuestros ajustes | Usar la variante del driver con la que se realizaron las pruebas. |
| Compilación | Opción de CPU compatible con Clang 16; advertencias de símbolos sin usar acotadas a `es9218p.o` | Compilar este árbol con la herramienta usada en el laboratorio. |
| USB gadget | Rechazar una interfaz nula en `gether_get_ifname()` | Evitar una desreferencia nula durante consultas de configfs. |

Los ajustes de **HiFi2 forzado y DRE avanzado** proceden del driver QCloud recuperado. Se conservan con su procedencia; no se presentan como desarrollos originales de este proyecto.

## Lo que sí probamos

En un LG V60 Timelm con Android 13 y la ruta de audio adaptada:

- Arranque del kernel `4.19.325-v60-dop-lab3+`.
- Reproducción de DSF DSD128 por la salida analógica, confirmada por el usuario como **limpia y continua**.
- Portadora ALSA estéreo a **352.800 Hz, `S24_3LE`**, con backend MI2S a 352,8 kHz.
- En una captura del buffer de salida de AudioFlinger: **1.920 de 1.920 tramas** con marcadores DoP correctos y alternantes.
- **7.680 bytes de datos DSD** de ambos canales recuperados de ese buffer coincidieron con el DSF original, con **cero diferencias**.

La última comprobación cubre un fragmento digital antes de la entrega al HAL. **No es una medición eléctrica del enlace I²S ni una certificación bit-perfect de la pista completa o del DAC.** Habilitar la lógica DoP y observar bloqueo de reloj tampoco prueba, por sí solo, que el DAC esté decodificando DSD.

## Límites, sin humo

- **PCM a 384 kHz por el ESS no está validado.** Esa frecuencia ya figuraba en el árbol original; no equivale a que toda la ruta Android la acepte.
- La reproducción final validada fue **DSD128 con DoP en 24 bits a 352,8 kHz**. No se promete DSD256, DSD nativo ni soporte universal de otros formatos.
- El transporte se preparó para el **DAC interno y la salida analógica**. No se ofrece DoP sobre Bluetooth ni el altavoz del teléfono.
- El ajuste X-tal está limitado al modelo exacto de placa indicado arriba; otras variantes necesitan verificación propia.
- Pausa, reanudación y búsqueda pertenecen también al reproductor. Su validación completa no se atribuye al kernel.
- Un kernel 4.19 modificado conserva las limitaciones de su base. Este trabajo de audio no acredita mantenimiento de seguridad completo ni compatibilidad con todas las ROM.

## Qué queda fuera de este repositorio

La ruta funcional también utilizó ajustes del **HAL de audio propietario**, políticas/XML de audio y coordinación entre **Zero Music y LG Extended** para mantener temporalmente AUX durante DoP. El kernel por sí solo no aplica esos cambios.

Aquí no se incluyen el HAL modificado, aplicaciones, módulos, copias de particiones, imágenes `boot.img` con Magisk, archivos de música ni capturas privadas del teléfono. No se debe interpretar esta publicación como una licencia para redistribuir componentes propietarios.

## Compilar

Entorno de referencia: **Ubuntu 24.04 / WSL2, LLVM y Clang 16.0.6**, compilación cruzada ARM64. Se incluye la configuración completa usada en `dop/config/v60_dop_lab3.config`; KernelSU no está habilitado en esa configuración. El root del teléfono de referencia procedía de Magisk en su ramdisk, no de este código de kernel.

Instala las dependencias en Ubuntu:

```bash
sudo apt update
sudo apt install --no-install-recommends \
  build-essential git bison flex bc python3 python-is-python3 \
  libssl-dev libelf-dev libncurses-dev device-tree-compiler \
  clang-16 lld-16 llvm-16 llvm-16-tools \
  gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi
```

Después:

```bash
git clone https://github.com/zXer0z/Kernel-DOP.git
cd Kernel-DOP
JOBS=4 bash dop/build.sh
```

Resultado principal: `out-dop/arch/arm64/boot/Image`. También se compilan los DTB del árbol. El script no descarga componentes, no empaqueta un boot, no instala ni flashea nada.

La configuración corresponde a la compilación de referencia. Fechas, metadatos Git y versiones de herramientas pueden cambiar el binario resultante: no se promete una reproducción byte a byte del `Image` original. Los scripts `build.sh` y `kernel.sh` de la raíz son heredados de upstream; el flujo documentado para esta variante es **`dop/build.sh`**.

### Instalar en un dispositivo

El `Image` generado **no es una imagen de partición boot lista para fastboot**. Necesita un empaquetado específico para la ROM, con el ramdisk y DTB adecuados. Flashear un boot reemplaza también su ramdisk y puede afectar a root si no se conserva correctamente.

No se publica aquí un comando de flasheo universal. Conserva un respaldo de tu boot y un método de recuperación antes de preparar una imagen para otro dispositivo.

## Procedencia y créditos

| Componente | Procedencia |
| :--- | :--- |
| Árbol base | [aqbaloch6205/LGV60_Timelm_Qcloud_Kernel](https://github.com/aqbaloch6205/LGV60_Timelm_Qcloud_Kernel), rama `thunder-1.3-new` |
| Revisión base fijada | [`78253129915f211b0f4e8c86bea09c50111f3b4d`](https://github.com/aqbaloch6205/LGV60_Timelm_Qcloud_Kernel/commit/78253129915f211b0f4e8c86bea09c50111f3b4d) |
| Driver ESS recuperado | Rama `thunder-1.3`, revisión [`4e55e8eca6beb81f2eab88617d6e496c0f2be4c1`](https://github.com/aqbaloch6205/LGV60_Timelm_Qcloud_Kernel/commit/4e55e8eca6beb81f2eab88617d6e496c0f2be4c1) |
| Integración y pruebas del proyecto | **zXer0z** |

Gracias a los contribuidores de **Linux, Qualcomm, LG, ESS Technology, QCloud y sus proyectos de origen**. Se conservan los avisos de copyright, `CREDITS`, `MAINTAINERS`, `COPYING` y el directorio `LICENSES` originales.

La publicación empieza con una **importación identificada del árbol upstream**, seguida de los cambios locales. No reproduce todo el historial Git anterior; el historial original está disponible en el repositorio de procedencia. Consulta [la ficha de origen](dop/PROVENANCE.md).

## Licencia

El kernel se distribuye bajo **GNU GPL versión 2 únicamente**, conforme a [COPYING](COPYING) y [LICENSES/preferred/GPL-2.0](LICENSES/preferred/GPL-2.0), con la excepción de llamadas al sistema descrita en [Linux-syscall-note](LICENSES/exceptions/Linux-syscall-note). Los archivos individuales conservan sus licencias y avisos específicos, incluidas las licencias duales existentes.

Los cambios de kernel y el script añadidos por este proyecto se aportan bajo GPL-2.0; no se cambia la licencia de los componentes heredados. No hay garantía. Consulta también las [reglas de licencia del árbol](Documentation/process/license-rules.rst).

**El mérito es compartido. El código queda abierto. El V60 sigue sonando.**

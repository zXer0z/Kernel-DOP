# Procedencia de Kernel-DOP

Fecha de preparación: 2026-11-02.

## Base

- Repositorio: https://github.com/aqbaloch6205/LGV60_Timelm_Qcloud_Kernel.git
- Rama: `thunder-1.3-new`.
- Commit: `78253129915f211b0f4e8c86bea09c50111f3b4d`.
- Versión: Linux 4.19.325.
- Driver ESS recuperado de `thunder-1.3`, commit `4e55e8eca6beb81f2eab88617d6e496c0f2be4c1` del mismo repositorio.

El primer commit de esta publicación importa el árbol base identificado arriba. Se conserva el contenido original y su documentación de licencias, sin atribuir la autoría del árbol a quien realiza la importación. El historial anterior no se copia: se enlaza al upstream original.

## Cambios locales sobre la base

1. `arch/arm64/Makefile`: opción `-mcpu=cortex-a77` compatible con Clang 16.
2. `drivers/usb/gadget/function/u_ether.c`: protección frente a interfaz nula en `gether_get_ifname()`.
3. `techpack/audio/asoc/codecs/Kbuild`: advertencias de función/variable sin usar no fatales solo para `es9218p.o`.
4. `techpack/audio/asoc/codecs/es9218p.c` y `.h`: versión anterior del driver QCloud, frecuencia 352.800 Hz, ESS esclavo en DoP para la placa configurada y X-tal para el modelo exacto Timelm_lao rev_1.01.
5. `techpack/audio/asoc/kona.c`: selector LG 352,8 kHz y conversiones, sin desplazar los índices previos.

El driver recuperado incluye decisiones previas de QCloud (entre ellas HiFi2 forzado y DRE avanzado). No son cambios originales de Kernel-DOP. Los encabezados y avisos de los autores originales se mantienen.

## Material de publicación

- `dop/config/v60_dop_lab3.config`: configuración completa del directorio de compilación usado para el kernel probado.
- `dop/build.sh`: flujo de compilación documentado, sin descarga ni instalación.
- `README.md`: alcance, evidencia y limitaciones.
- Se retiran las dos automatizaciones GitHub Actions heredadas de la punta publicada para no ejecutar flujos ajenos al proceso documentado.

## Alcance de la evidencia

El kernel se probó como parte de una solución de audio que también modifica componentes externos al kernel. La reproducción de DSF DSD128 fue confirmada limpia y continua por el usuario. La captura digital comprobó un fragmento de 1.920 tramas DoP y 7.680 bytes DSD coincidentes con el archivo fuente antes de la entrega al HAL. No mide el enlace eléctrico ni acredita todas las variantes de hardware o la pista completa como bit-perfect.

Referencia pública del transporte: https://dsd-guide.com/sites/default/files/white-papers/DoP_openStandard_1v1.pdf

## Licencias

No se sustituye `COPYING`, no se eliminan avisos de autoría ni se aplica una licencia permisiva global al árbol. El kernel mantiene GPL-2.0 y los términos específicos de sus archivos. Los detalles y textos completos están en `COPYING`, `LICENSES/` y `Documentation/process/license-rules.rst`.

Esta publicación no incluye los binarios propietarios del HAL, ramdisks con Magisk, datos de usuario ni música.

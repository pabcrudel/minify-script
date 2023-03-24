# Minificación de archivos HTML, CSS y JS

Este script es una herramienta útil para minimizar y comprimir archivos HTML, CSS y JS en un proyecto web. El script utiliza paquetes de npm para realizar la tarea de minificación.

## Lista de paquetes

El script comienza definiendo una lista de paquetes a verificar e instalar. La lista se puede editar para incluir o excluir paquetes según sea necesario. Por defecto, los paquetes incluidos son:

- `uglify-js`: para minificar archivos JS
- `clean-css-cli`: para minificar archivos CSS
- `html-minifier`: para minificar archivos HTML

```sh
# Lista de paquetes a verificar e instalar
packages=("uglify-js" "clean-css-cli" "html-minifier")
```

## Verificación e instalación de paquetes

Después de definir la lista de paquetes, el script verifica si cada uno está instalado en el proyecto utilizando el comando `npm ls`. Si no se encuentra el paquete, se instala con el comando `npm install`. El parámetro `--save-dev` se utiliza para instalar los paquetes como dependencias de desarrollo. El parámetro `--silent` se utiliza para suprimir la salida del proceso de instalación.

```sh
# Iterar sobre la lista de paquetes
for package in "${packages[@]}"
do
  # Verifica si el paquete está instalado
  if ! npm ls "$package" > /dev/null; then
    echo "$package no encontrado. Instalando..."
    # Instala el paquete usando npm
    npm install "$package" --save-dev --silent
  else
    echo "$package ya está instalado."
  fi
  echo
done
```

## Creación de directorio para archivos minificados

El script crea un directorio llamado "minified" para guardar los archivos minificados. Si el directorio ya existe, se eliminan todos los archivos que contiene.

```sh
# Verifica si el directorio "minified" existe, si es asi elimina su contenido, y si no crea el directorio.
if [ ! -d minified ]; then
    mkdir -p minified
else
    rm -r minified/*
fi
```

## Minificación de archivos

El script utiliza el comando `find` para encontrar todos los archivos HTML, CSS y JS en el directorio actual y sus subdirectorios, excluyendo la carpeta "node_modules". Luego, itera a través de cada archivo encontrado y comprime su contenido usando los paquetes instalados anteriormente.

```sh
# Itera a través de los archivos HTML, CSS y JS en el directorio actual y sus subdirectorios, excluyendo la carpeta "node_modules"
find . -type f -not -path "./node_modules/*" \( -name '*.html' -o -name '*.css' -o -name '*.js' \)
```

Guarda la ubicacion del archivo original para almacenar el archivo minificado respetando el arbol de directorios original.

```sh
# Obtiene la ruta relativa del archivo para usar como la ruta de salida del archivo minificado, y la crea.
rel_path=${file#./}
min_path="minified/$rel_path"
mkdir -p $(dirname "$min_path")
```

### Archivos HTML

Si se encuentra un archivo HTML, se utiliza el paquete *html-minifier* para minimizar el archivo. El parámetro `--collapse-whitespace` se utiliza para eliminar espacios en blanco innecesarios. El parámetro `--remove-comments` se utiliza para eliminar comentarios.

```sh
# Minifica el archivo HTML y guarda el archivo minificado en el directorio "minified"
./node_modules/.bin/html-minifier "$file" -o "$min_path" --collapse-whitespace --remove-comments
```

### Archivos CSS

Si se encuentra un archivo CSS, se utiliza el paquete *clean-css-cli* para minimizar el archivo. El parámetro `--compatibility` se utiliza para asegurar que el archivo minificado sea compatible con los navegadores especificados. En este caso, se especifican los navegadores más utilizados. Puedes agregar o eliminar navegadores según sea necesario.

```sh
# Minifica el archivo CSS y guarda el archivo minificado en el directorio "minified"
./node_modules/.bin/cleancss "$file" -o "$min_path" --compatibility "ie >= 11, Edge >= 12, Firefox >= 2, Chrome >= 4, Safari >= 3.1, Opera >= 15, iOS >= 3.2"
```

### Archivos JS

Si se encuentra un archivo JS, se utiliza el paquete *uglify-js* para minimizar el archivo. Los parámetros `--compress` y `--mangle` se utilizan para comprimir y ofuscar el código del archivo.

```sh
# Minifica el archivo JS y guarda el archivo minificado en el directorio "minified"
./node_modules/.bin/uglifyjs "$file" -o "$min_path" --compress --mangle
```

## Finalización del proceso de minificación

Una vez que se han comprimido todos los archivos, el script muestra un mensaje indicando que el proceso ha finalizado.

## Ejecución del script

Para ejecutar el script, abre una terminal en el directorio raíz del proyecto y ejecuta el siguiente comando:

```sh
./minify.sh
```

Asegúrate de que el archivo tenga permisos de ejecución con el comando:

```sh
chmod +x minify.sh
```

Esto dará permiso al archivo para que se pueda ejecutar como un programa.

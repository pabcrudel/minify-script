#!/bin/bash
#
# Script que minifica los archivos .html, .css y .js y los añade en una carpeta con el nombre de "minified" respetando el arbol de directorios original.
#
# --------------------------------------------------------------------
# Author: Pablo Cru
# GitHub: https://github.com/pabcrudel
# --------------------------------------------------------------------

clear
echo

# Lista de paquetes a verificar e instalar
packages=("uglify-js" "clean-css-cli" "html-minifier")

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

# Verifica si el directorio "minified" existe, si es asi elimina su contenido, y si no crea el directorio.
if [ ! -d minified ]; then
    mkdir -p minified
else
    rm -r minified/*
fi

# Itera a través de los archivos HTML, CSS y JS en el directorio actual y sus subdirectorios, excluyendo la carpeta "node_modules"
find . -type f -not -path "./node_modules/*" \( -name '*.html' -o -name '*.css' -o -name '*.js' \) | while read file; do
  # Obtiene la ruta relativa del archivo para usar como la ruta de salida del archivo minificado, y la crea.
  rel_path=${file#./}
  min_path="minified/$rel_path"
  mkdir -p $(dirname "$min_path")

  # Muestra que archivo se esta minificando
  echo "Minificando el archivo $file..."

  # Verifica si el archivo es un archivo HTML, CSS o JS
  case "$file" in
    *.html)
      # Minifica el archivo HTML y guarda el archivo minificado en el directorio "minified"
      ./node_modules/.bin/html-minifier "$file" -o "$min_path" --collapse-whitespace --remove-comments
    ;;
    *.css)
      # Minifica el archivo CSS y guarda el archivo minificado en el directorio "minified"
      ./node_modules/.bin/cleancss "$file" -o "$min_path" --compatibility "ie >= 11, Edge >= 12, Firefox >= 2, Chrome >= 4, Safari >= 3.1, Opera >= 15, iOS >= 3.2"
    ;;
    *.js)
      mkdir -p $(dirname "$min_path")
      # Minifica el archivo JS y guarda el archivo minificado en el directorio "minified"
      ./node_modules/.bin/uglifyjs "$file" -o "$min_path" --compress --mangle
    ;;
  esac

done

echo
echo "¡Proceso de minificación completado!"
echo

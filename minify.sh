#!/bin/bash
#
# Script que minifica los archivos .html, .css y .js y los añade en una carpeta con el nombre de "minified" respetando el arbol de directorios original.
#
# --------------------------------------------------------------------
# Author: Pablo Cru
# GitHub: https://github.com/pabcrudel
# --------------------------------------------------------------------


# --------------- Funciones --------------- #

# Verificar si un paquete está instalado y, si no lo está, instalarlo
f_check_packages() {
  echo Verificando instalacion de paquetes necesarios...
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
  done
  echo
  echo
}

# Verificar el estado del directorio "minified".
# - si existe, elimina su contenido.
# - si no exite, lo crea.
f_check_output() {
  dir=minified

  echo Verificando estado del directorio $dir...
  echo
  if [ ! -d $dir ]; then
    echo "No exite." 
    echo "Creando directorio..."
    mkdir -p $dir
  elif [ ! -z "$(ls -A $dir)" ]; then
    echo "No esta vacio."
    echo "Limpiando el contenido..."
    rm -r $dir/*
  else
    echo "$dir esta vacio."
  fi
  echo
  echo
}

f_minify() {
  # Variable de control de errores.
  isOk=0

  # Captura el error del proceso de minificado y actualiza la variable de control de errores.
  f_catch_error() {
    minify_error_message=$(eval $1 2>&1)
    isOk=$?
  }

  # Muestra un final de mensaje diferente si el proceso de minificado ha sido completado o interrumpido.
  f_final_message() {
    echo "¡Proceso de minificación $1!"
  }

  echo "¡Proceso de minificación iniciado!"
  echo

  # Itera a través de los archivos HTML, CSS y JS en el directorio actual y sus subdirectorios, excluyendo la carpeta "node_modules"
  # Si algun archivo no se puede minificar el proceso sera interrumpido.
  while [ $isOk -eq 0 ] && read -d $'\0' file; do
    # Obtiene la ruta relativa del archivo para usar como la ruta de salida del archivo minificado, y la crea.
    rel_path=${file#./}
    min_path="$dir/$rel_path"
    mkdir -p "$(dirname "$min_path")"

    # Muestra que archivo se esta minificando
    echo "Minificando el archivo $file..."

    # Verifica si el archivo es un archivo HTML, CSS o JS
    case "$file" in
      *.html)
        # Minifica el archivo HTML y guarda el archivo minificado en el directorio "minified"
        f_catch_error './node_modules/.bin/html-minifier "$file" -o "$min_path" --collapse-whitespace --remove-comments'
      ;;
      *.css)
        # Minifica el archivo CSS y guarda el archivo minificado en el directorio "minified"
        f_catch_error './node_modules/.bin/cleancss "$file" -o "$min_path" --compatibility "ie >= 11, Edge >= 12, Firefox >= 2, Chrome >= 4, Safari >= 3.1, Opera >= 15, iOS >= 3.2"'
      ;;
      *.js)
        # Minifica el archivo JS y guarda el archivo minificado en el directorio "minified"
        f_catch_error './node_modules/.bin/uglifyjs "$file" -o "$min_path" --compress --mangle'
      ;;
    esac

  done < <(find . -type f -not -path "./node_modules/*" \( -name '*.html' -o -name '*.css' -o -name '*.js' \) -print0)

  echo
  if [ $isOk -eq 0 ]; then
    f_final_message completado
  else
    echo "$minify_error_message"
    echo
    f_final_message interrumpido
  fi
  echo
}


# --------------- Programa --------------- #

clear
echo

f_check_packages
f_check_output
f_minify

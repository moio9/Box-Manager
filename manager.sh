#!/bin/bash

backup=false
launcher=''

path=''

while getopts 'bl:' OPTION; do
  case "${OPTION}" in
    b)
      backup=true
      echo "backup"
      ;;
    l)
      launcher="$OPTARG"
      path="$PREFIX/glibc/opt/conf"
      echo "The value provided is $OPTARG"
      if [ "$launcher" = "mobox" ]; then 
        path="$PREFIX/glibc/opt/conf" 

      fi 
      ;;
    ?)
      echo "script usage: $(basename \$0) [-b] [-mobox] [-a somevalue]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [ "$backup" = true ]; then
  if [ "$launcher" = "mobox" ]; then 
    pth="$path" 
    mv "$pth/dynarec" "$pth/dynarec_bu"
    echo Mobox files saved
    echo $PREFIX

  fi 
fi

echo $backup
echo $launcher
echo $game

# Verifica daca a fost furnizat cel putin un argument
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <game>"
  exit 1
fi

# Acceseaza primul argument furnizat
game="$1"
script_dir="$(dirname "$(readlink -f "$0")")"
cfg="$script_dir/presents/$game.config"

if ! test -e $cfg; then
  echo "File has not been foud.
  Trying downloding..."
  cd "$script_dir/presents"
  wget "https://raw.githubusercontent.com/moio9/Box-Manager/main/database/$game.config"
  cd $script_dir
else
  echo "File is present!"
fi

mobox_dynarec(){
  while IFS= read -r line; do
     dynarec="$path/dynarec"
   
     if [[ $line =~ ^(unset|export)\ BOX64_DYNAREC_.* ]]; then
       file_suffix=$(echo "$line" | sed -E 's/^(unset|export) BOX64_DYNAREC_//')
       file_suffix=$(echo "$file_suffix" | sed -E 's/=.*//')
       output_file=$(echo "$file_suffix" | tr '[:upper:]' '[:lower:]')
        
       output_file="$path/dynarec/${output_file}.conf"

       mkdir -p $dynarec
       echo "$line" > "$output_file"
       #cat > "$output_file" << EOF "$line"  
         
       if [[ $line == " " || $line == *"#"* ]]; then
         break
       fi
     fi
   
  done < "$cfg"
  
}


mobox(){
  mobox_dynarec
}

# Verifica daca fisierul exista
if [ -e "$cfg" ]; then
  echo "File '$cfg' exist."
  dynarec="$PREFIX/glibc/opt/conf/dynarec"
  mobox
else
  echo "Fisierul '$cfg' nu exista."
fi

#!/bin/bash

prenom="Olivier"
echo "Salut $prenom !!!"

if [[ $# -eq 0 ]]; then
    echo "Usage : $0 prenom [prenom ...]"
    echo 'Erreur un prenom est requis'
    exit 1
fi

for prenom in "$@"; do
    echo "Salut $prenom !!!"
done

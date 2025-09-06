# Projet 7 – Gestion de personnel (NASM, 32 bits)

## Description
Ce projet, réalisé durant la **L3 informatique**, est un programme en **assembleur NASM (x86, 32 bits)** pour gérer une petite base de données de personnel en ligne de commande.  
Le programme propose un menu interactif permettant d'ajouter, lister, supprimer des personnes et de calculer des statistiques simples (âge moyen, personne la plus âgée/jeune).

## Fonctionnalités
- Enregistrer une nouvelle personne (nom + âge)  
- Lister toutes les personnes enregistrées  
- Supprimer une personne spécifique (par numéro)  
- Afficher la personne la plus âgée et la plus jeune  
- Afficher la liste des âges et calculer l’âge moyen  
- Quitter le programme

## Fichiers
- `Projet-7.asm` — code source en NASM (fichier principal)

## Technologies
- **Langage** : Assembleur (NASM)  
- **Architecture** : x86 32 bits  
- **Système cible** : Linux (utilise les appels système via `int 0x80`)

## Compilation & exécution

### Compiler
```bash
nasm -f elf32 Projet-7.asm -o projet.o
ld -m elf_i386 projet.o -o projet
./projet
```

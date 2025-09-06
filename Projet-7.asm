; Programme de gestion de personnel en assembleur NASM
; Architecture : 32 bits
; Auteur : Jean BAREKZAI Nihal BAZ Logan BOIX
; Date : 27/03/2025

section .data
    ; Symboles d'affichage
    pointMsg db '.', 0
    espaceMsg db ' ', 0
    newlineMsg db 10, 0

    ; Variables de gestion
    choix db 0, 0
    personneMax equ 10
    tailleNom equ 50
    taillePersonne equ tailleNom + 4 + 4
    listePersonnes times personneMax * taillePersonne db 0
    nbPersonnes dd 0

    ; Messages du menu principal
    menuMsg db 'Menu Principal:',10,'1. Enregistrer du personnel',10,'2. Lister des personnes enregistrees',10,'3. Supprimer une personne specifique',10,'4. Afficher la personne la plus agee et la plus jeune',10,"5. Afficher l'age moyen des personnes enregistrees",10,'6. Quitter le programme',10,'Entrez votre choix: ',0
    len_menuMsg equ $ - menuMsg
    
    ; Messages divers
    promptNomAge db "Entrez le nom et l'age (separés par un espace): ",0
    len_promptNomAge equ $ - promptNomAge
    promptSuppression db 'Entrez le numero de la personne a supprimer: ',0
    len_promptSuppression equ $ - promptSuppression
    listeMsg db 'Liste des personnes:',10,0
    len_listeMsg equ $ - listeMsg
    choixInvalidMsg db 'Choix invalide, veuillez essayer de nouveau.',10,0
    len_choixInvalidMsg equ $ - choixInvalidMsg
    byeMsg db 'Au revoir!',10,0
    len_byeMsg equ $ - byeMsg
    successMsg db 'Enregistrement reussi.',10,0
    len_successMsg equ $ - successMsg
    enregistrementMsg db 'Enregistrement des personnes:',10,0
    len_enregistrementMsg equ $ - enregistrementMsg
    supprimerMsg db 'Suppression de la personne:',10,0
    len_supprimerMsg equ $ - supprimerMsg
    suppressionReussieMsg db 'Personne supprimee avec succes.',10,0
    len_suppressionReussieMsg equ $ - suppressionReussieMsg
    personneInexistanteMsg db 'Cette personne n existe pas!',10,0
    len_personneInexistanteMsg equ $ - personneInexistanteMsg
    plusAgeeMsg db 'La personne la plus agee:',10,0
    len_plusAgeeMsg equ $ - plusAgeeMsg
    plusJeuneMsg db 'La personne la plus jeune:',10,0
    len_plusJeuneMsg equ $ - plusJeuneMsg
    ageMoyenMsg db 'L age moyen des personnes enregistrees est: ',0
    len_ageMoyenMsg equ $ - ageMoyenMsg

    ; Messages pour la liste des âges
    agesListMsg db 'Liste des ages: [',0
    len_agesListMsg equ $ - agesListMsg
    agesSeparator db ', ',0
    len_agesSeparator equ $ - agesSeparator
    agesEndMsg db ']',10,0
    len_agesEndMsg equ $ - agesEndMsg

    ; Buffers
    buffer times 100 db 0
    tempNum times 10 db 0

section .text
    global _start

; =============================================
; FONCTION DE CONVERSION CHAINE -> ENTIER
; Entrée : EAX = adresse de la chaîne
; Sortie : EAX = valeur entière
; =============================================
string_to_int:
    xor ebx, ebx
    xor edx, edx
.convert:
    xor ecx, ecx
    mov cl, [eax]
    inc eax
    cmp ecx, '0'
    jb .done
    cmp ecx, '9'
    ja .done
    sub ecx, '0'
    imul ebx, 10
    add ebx, ecx
    inc edx
    cmp edx, 3
    jge .done
    jmp .convert
.done:
    mov eax, ebx
    ret

; =============================================
; FONCTION DE CONVERSION ENTIER -> CHAINE
; Entrée : EAX = nombre, EDI = buffer de sortie
; =============================================
int_to_string:
    mov ebx, 10
    xor ecx, ecx
.divide:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    inc ecx
    cmp eax, 0
    jnz .divide
.reverse:
    pop eax
    mov [edi], al
    inc edi
    loop .reverse
    mov byte [edi], 0
    ret

; =============================================
; POINT D'ENTREE DU PROGRAMME
; =============================================
_start:
    jmp afficherMenu

; =============================================
; AFFICHAGE DU MENU PRINCIPAL
; =============================================
afficherMenu:
    mov eax, 4
    mov ebx, 1
    mov ecx, menuMsg
    mov edx, len_menuMsg
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, choix
    mov edx, 2
    int 0x80

    cmp byte [choix], '6'
    je fin
    cmp byte [choix], '1'
    je enregistrerPersonnel
    cmp byte [choix], '2'
    je listerPersonnes
    cmp byte [choix], '3'
    je supprimerPersonne
    cmp byte [choix], '4'
    je afficherPlusAgeeEtJeune
    cmp byte [choix], '5'
    je afficherListeAges

    jmp choixInvalide

; =============================================
; ENREGISTREMENT D'UNE NOUVELLE PERSONNE
; =============================================
enregistrerPersonnel:
    mov eax, [nbPersonnes]
    cmp eax, personneMax
    jge listePleine

    mov eax, 4
    mov ebx, 1
    mov ecx, enregistrementMsg
    mov edx, len_enregistrementMsg
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, promptNomAge
    mov edx, len_promptNomAge
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 100
    int 0x80

    mov esi, buffer
trouverEspace:
    mov al, [esi]
    inc esi
    cmp al, ' '
    je espaceTrouve
    cmp al, 10
    je entreeInvalide
    jmp trouverEspace

espaceTrouve:
    mov byte [esi-1], 0
    mov edi, [nbPersonnes]
    imul edi, taillePersonne
    add edi, listePersonnes
    
    mov [edi], dword 0
    add edi, 4
    
    mov ecx, tailleNom
    mov esi, buffer
copierNom:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jz nomCopie
    loop copierNom

nomCopie:
    mov eax, esi
    call string_to_int
    
    mov edi, [nbPersonnes]
    imul edi, taillePersonne
    add edi, listePersonnes
    add edi, 4
    add edi, tailleNom
    mov [edi], eax

    mov eax, [nbPersonnes]
    inc eax
    mov edi, [nbPersonnes]
    imul edi, taillePersonne
    add edi, listePersonnes
    mov [edi], eax

    inc dword [nbPersonnes]

    mov eax, 4
    mov ebx, 1
    mov ecx, successMsg
    mov edx, len_successMsg
    int 0x80

    jmp afficherMenu

listePleine:
    mov eax, 4
    mov ebx, 1
    mov ecx, choixInvalidMsg
    mov edx, len_choixInvalidMsg
    int 0x80
    jmp afficherMenu

entreeInvalide:
    mov eax, 4
    mov ebx, 1
    mov ecx, choixInvalidMsg
    mov edx, len_choixInvalidMsg
    int 0x80
    jmp enregistrerPersonnel

; =============================================
; LISTE TOUTES LES PERSONNES ENREGISTREES
; =============================================
listerPersonnes:
    mov eax, 4
    mov ebx, 1
    mov ecx, listeMsg
    mov edx, len_listeMsg
    int 0x80

    xor ecx, ecx
boucleListe:
    cmp ecx, [nbPersonnes]
    jge afficherMenu

    push ecx

    mov eax, ecx
    imul eax, taillePersonne
    mov esi, listePersonnes
    add esi, eax

    mov eax, [esi]
    mov edi, tempNum
    call int_to_string
    mov eax, 4
    mov ebx, 1
    mov ecx, tempNum
    mov edx, 10
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, pointMsg
    mov edx, 1
    int 0x80

    add esi, 4
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    mov edx, tailleNom
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, espaceMsg
    mov edx, 1
    int 0x80

    add esi, tailleNom
    mov eax, [esi]
    mov edi, tempNum
    call int_to_string
    mov eax, 4
    mov ebx, 1
    mov ecx, tempNum
    mov edx, 10
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newlineMsg
    mov edx, 1
    int 0x80

    pop ecx
    inc ecx
    jmp boucleListe

; =============================================
; SUPPRESSION D'UNE PERSONNE
; =============================================
supprimerPersonne:
    mov eax, 4
    mov ebx, 1
    mov ecx, supprimerMsg
    mov edx, len_supprimerMsg
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, promptSuppression
    mov edx, len_promptSuppression
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 10
    int 0x80

    mov eax, buffer
    call string_to_int
    cmp eax, 0
    jz personneInexistante
    cmp eax, [nbPersonnes]
    ja personneInexistante

    dec eax
    mov ecx, eax
    imul ecx, taillePersonne

    mov esi, listePersonnes
    add esi, ecx
    add esi, taillePersonne
    mov edi, listePersonnes
    add edi, ecx
    
    mov ecx, [nbPersonnes]
    sub ecx, eax
    dec ecx
    imul ecx, taillePersonne
    jecxz .fin_deplacement
.deplacer_octets:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop .deplacer_octets
.fin_deplacement:

    dec dword [nbPersonnes]

    mov ecx, 0
majIDs:
    cmp ecx, [nbPersonnes]
    jge suppressionFinie
    mov eax, ecx
    imul eax, taillePersonne
    mov edi, listePersonnes
    add edi, eax
    inc ecx
    mov [edi], ecx
    jmp majIDs

suppressionFinie:
    mov eax, 4
    mov ebx, 1
    mov ecx, suppressionReussieMsg
    mov edx, len_suppressionReussieMsg
    int 0x80
    jmp listerPersonnes

personneInexistante:
    mov eax, 4
    mov ebx, 1
    mov ecx, personneInexistanteMsg
    mov edx, len_personneInexistanteMsg
    int 0x80
    jmp afficherMenu

; =============================================
; AFFICHE LA PERSONNE LA PLUS AGEE ET LA PLUS JEUNE
; =============================================
afficherPlusAgeeEtJeune:
    mov ebx, -1
    mov ecx, 0
    mov edx, -1
    mov esi, 999

    xor edi, edi
boucleAge:
    cmp edi, [nbPersonnes]
    jge finBoucleAge

    mov eax, edi
    imul eax, taillePersonne
    add eax, listePersonnes
    mov eax, [eax + 4 + tailleNom]

    cmp eax, ecx
    jle pasPlusAgee
    mov ecx, eax
    mov ebx, edi
pasPlusAgee:

    cmp eax, esi
    jge pasPlusJeune
    mov esi, eax
    mov edx, edi
pasPlusJeune:

    inc edi
    jmp boucleAge

finBoucleAge:
    cmp ebx, -1
    je aucunePersonne
    cmp edx, -1
    je aucunePersonne

    push edx
    push ebx
    
    mov eax, 4
    mov ebx, 1
    mov ecx, plusAgeeMsg
    mov edx, len_plusAgeeMsg
    int 0x80
    
    pop eax
    call afficherPersonne

    mov eax, 4
    mov ebx, 1
    mov ecx, plusJeuneMsg
    mov edx, len_plusJeuneMsg
    int 0x80
    
    pop eax
    call afficherPersonne
    
    jmp afficherMenu

; =============================================
; AFFICHE LES DETAILS D'UNE PERSONNE
; Entrée : EAX = index de la personne (0-based)
; =============================================
afficherPersonne:
    imul eax, taillePersonne
    mov esi, listePersonnes
    add esi, eax

    mov eax, [esi]
    mov edi, tempNum
    call int_to_string
    mov eax, 4
    mov ebx, 1
    mov ecx, tempNum
    mov edx, 10
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, pointMsg
    mov edx, 1
    int 0x80

    add esi, 4
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    mov edx, tailleNom
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, espaceMsg
    mov edx, 1
    int 0x80

    add esi, tailleNom
    mov eax, [esi]
    mov edi, tempNum
    call int_to_string
    mov eax, 4
    mov ebx, 1
    mov ecx, tempNum
    mov edx, 10
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newlineMsg
    mov edx, 1
    int 0x80
    ret

; =============================================
; CALCULE ET AFFICHE L'AGE MOYEN
; =============================================
afficherListeAges:
    mov eax, 4
    mov ebx, 1
    mov ecx, agesListMsg      ; "Liste des ages: ["
    mov edx, len_agesListMsg  ; Toute la longueur du message
    int 0x80

    xor esi, esi             ; Compteur
.affiche_ages:
    cmp esi, [nbPersonnes]
    jge .fin_affiche

    ; Récupérer l'âge
    mov eax, esi
    imul eax, taillePersonne
    add eax, listePersonnes
    mov eax, [eax + 4 + tailleNom]

    ; Afficher l'âge
    push esi
    mov edi, tempNum
    call int_to_string
    mov eax, 4
    mov ebx, 1
    mov ecx, tempNum
    mov edx, 10
    int 0x80

    ; Afficher séparateur si pas dernier élément
    mov eax, esi
    inc eax
    cmp eax, [nbPersonnes]
    jge .pas_separateur
    
    mov eax, 4
    mov ebx, 1
    mov ecx, agesSeparator
    mov edx, len_agesSeparator
    int 0x80

.pas_separateur:
    pop esi
    inc esi
    jmp .affiche_ages

.fin_affiche:
    ; Afficher ']' + retour ligne
    mov eax, 4
    mov ebx, 1
    mov ecx, agesEndMsg
    mov edx, len_agesEndMsg
    int 0x80

afficherAgeMoyen:
    xor ebx, ebx    ; somme des âges
    xor ecx, ecx    ; nombre de personnes

    xor edi, edi
boucleMoyenne:
    cmp edi, [nbPersonnes]
    jge finBoucleMoyenne

    mov eax, edi
    imul eax, taillePersonne
    add eax, listePersonnes
    mov eax, [eax + 4 + tailleNom]

    add ebx, eax
    inc ecx

    inc edi
    jmp boucleMoyenne

finBoucleMoyenne:
    cmp ecx, 0
    jz aucunePersonne

    mov eax, ebx
    xor edx, edx
    div ecx

    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, ageMoyenMsg
    mov edx, len_ageMoyenMsg
    int 0x80
    pop eax

    mov edi, tempNum
    call int_to_string
    mov eax, 4
    mov ebx, 1
    mov ecx, tempNum
    mov edx, 10
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newlineMsg
    mov edx, 1
    int 0x80

    jmp afficherMenu

aucunePersonne:
    mov eax, 4
    mov ebx, 1
    mov ecx, choixInvalidMsg
    mov edx, len_choixInvalidMsg
    int 0x80
    jmp afficherMenu

choixInvalide:
    mov eax, 4
    mov ebx, 1
    mov ecx, choixInvalidMsg
    mov edx, len_choixInvalidMsg
    int 0x80
    jmp afficherMenu

; =============================================
; QUITTER LE PROGRAMME
; =============================================
fin:
    mov eax, 4
    mov ebx, 1
    mov ecx, byeMsg
    mov edx, len_byeMsg
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80
; multi-segment executable file template.
include "emu8086.inc"
data segment
    ; add your data here!
    
    a db 8 dup(0)
    resultat dw  0
    debut db 13,10,"Entrer Votre expression : ",13,10

    attention db 13,10,"Attention !!$" 
    nbr_chaine db 13,10,"Enterez le nombre des chiffre de votre nombre : $"
    overf db 13,10,"Le nombre doit etre comris entre -32768 et 32767 $" 
    votre_nbr db 13,10,"Le nombre que vous avez ecrit est : $"
    res db 50 dup(5)

    positive db 0 
    expression db 100 dup(0) 
    k dw 0 
    final db 100 dup(0)
    
     
    mull db 50 dup(0)
    long_exp dw 0 
    virgule dw 0
    resu dw 0   
    dix dw 10  
    signe dw 0  
   
    
   
    
    
    case dw 0
ends            


stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    jmp programme 
    
    
    
    ;*****************************************************************************************;

   evaluation1 proc near 
    xor dx,dx
    mov signe,0
    mov cx,3
    mov ax,long_exp
    inc ax
    div cx
    mov cx,ax
    mov si,0
    mov dx,0
    looop:
    mov al,mull[si]   
    mov ah,mull[si+1] 
    cmp ax,0
    jns suite2  
    neg ax
    mov mull[si],al
    mov mull[si+1],ah
    inc dx
    
suite2:
    add si,3    
    loop looop
    
    mov signe,dx
    
    mov si,0     
    mov cx,0 ; cx va contenir la virgule un chiffre apres la virgule
    mov dx,0
    mov resu,0
    mov virgule,0
    
    
    
    
 
        
    mov al,[mull+si]  ; premier operande dans ax
    inc si 
    mov ah,[mull+si] 
    mov resu,ax
 
   
boucle:
    inc si
    mov ax,si
    sub ax,long_exp ;; j'ai change al par ax
    cmp ax,0 
    je fin2
   
    
    ;inc si
    mov al,[mull+si]    ;choix  d'operation  * ou  /       
    mov ah,0                 
    
    cmp ax,42
    jne division 

    mov ax,resu           ; premier operande (resultat) dans ax   
    inc si
    mov bl,[mull+si]    ; deuxieme operande dans bx        
    inc si 
    mov bh,[mull+si] 
    mul bx
    jo warning      
    mov resu,ax  ; on garde la valeur de ax dans res 
  ; gestion de la virgule 

    mov ax,cx 
    mul bx
    div dix
   ; cmp ax,10   ; la virgule>10 
    
    add resu,ax    
    mov cx,dx
    jmp boucle


division:  
    mov ax,resu
    
    inc si
    mov bl,[mull+si]    ; deuxieme operande dans bx        
    inc si 
    mov bh,[mull+si] 
    cmp bx,0 
    je warning2   
    xor dx,dx
    div bx  
    mov resu,ax 
  ; gestion de la virgule 
    mov ax,dx 
    mul dix
    div bx ; le quotient est le premier chiffre apes la virgule  dans ax
    mov dx,ax
    
    mov ax,cx ; l'ancien virgule    
    mov cx,dx
    mov dx,0
  ; mul dix
    div bx  ; virgule divisee dans ax    
    add ax,cx 
    mov cx,ax
  ;  mov ax,cx
  ; cmp ax,10
    jmp boucle
    

warning:  
print "depassement"
warning2:
print "division impossible sur 0"
fin2:                             
     mov virgule,cx 
     mov dx,signe
     and dx,1
     cmp dx,0
     jz fin3: 
     neg resu 
     
     ;cmp ax,0
     ;jnz fin3
     neg virgule
     ;;;;;;
     
     ;;;;;
fin3:                  
     ret
 endp evaluation1 
    
    
    
    
    ;*******************************************************************************************;
  ; procedure qui affiche une case memoire a partir du n de registre et le deplacement
  
afich proc near 
  mov a,0
  mov a[1],0
  mov a[2],0
  mov a[3],0
  mov a[4],0
  mov a[5],0
  mov a[6],0
  mov a[7],0 
    
    
  print 13
  print 10
  print "Le resultat = "  
  mov bx ,virgule 
  cmp bx,0
  jns rien
  jz  zeero
  neg bx
  mov dl,'-'
  mov ah,2
  int 33 
  mov dl,'0'
  mov ah,2
  int 33 
  mov dl,'.'
  mov ah,2
  int 33 
  mov dx,bx
  add dl,48
  mov ah,2
  int 33 
  
  
  
  jmp fin4
zeero:
  mov dl,'0'
  mov ah,2
  int 33    
    
  jmp fin4  
rien:    
  push ds
  push bp  
  mov si,5
  mov bp,sp
  mov bx,bp+6
  mov ds,bp+8 
  mov ax,[bx]
  mov ds,[bp+2] ; retourner l'ancien valeur de ds
  cmp ax,0 
 
  js ngtf 
  mov a,43
  
deb:          
  mov dx,0
  mov bx,10      
  div bx  
  add dl,48
  mov si[a],dl
  dec si
  cmp ax,0
  jne deb
mov [a+6],36 
jmp fin22
ngtf:
mov a,45 
neg ax
jmp deb      
fin22:
    mov al,a
    mov a,32
    mov [a+si],al
    mov ah,9
    lea dx,a
    int 33
    
    mov dl,'.'
    mov ah,2
    int 33
    
    mov dx,virgule
    add dl,48
    mov ah,2
    int 33
    
    
    pop bp 
    pop bp 
fin4:    
    ret      
afich endp
    
    
    
    
    
    ;***********************************************************************************;
    ; procedure pour lire un entier signe sur 16 bits
 lire proc   
    
             
    lecture: 
     
 
    mov positive,0
    mov si,3
    mov dx,10 ; pour faire la multiplication par 10 

    mov bx,0 ; qui va contenir le resultat finale 
    mov cl,[res+1]
    mov al,[res+2] ; lire un caractere et l'afficher
    dec cl 
    
    cmp al,2dh   ; si c'est un moins (-) ou un chiffre on l'accepte sinon on repete la lecture
    jnz verif
    cmp cl,0  ; le cas ou l'utilisateur entre juste le signe moins
    jz remake  
    jmp do
    
  verif:   
    cmp al,2bh   ; si c'est un moins (-) ou un chiffre on l'accepte sinon on repete la lecture
    jnz go
    mov positive,1
    cmp cl,0  ; le cas ou l'utilisateur entre juste le signe moins
    jz remake  
    jmp do
    
    
    
      
  go: 
    cmp al,48   
    jb remake
    cmp al,57
    ja remake 
    
    mov positive,1 ;; le nombre est positive
    
    sub al,48   ; ona pas besion de l'exention car , un chiffre ne depasse jamais 8 bits
    cbw
    mov bx,ax

    
    do:  
    cmp cl,0
    jz verifie
    mov al,res[si] ;; lire les chiffres et l'afficher
    ; on verifie que c'est un chiffre
    cmp al,48   
    jb remake
    cmp al,57
    ja remake 
    
    sub al,48 ; on convertir le nombre d'ASCII a un chiffre
    cbw
    mov di,ax  ; on sauvgarde la valeur dans di temporairement 
    
    mov ax,bx  ;la valeur precedent dans ax  
    mov dx,10
    mul dx 
    jo overflow
    add ax,di
                                                                                                                                                                                                                                                                
    
   ;jo overflow 
   
    mov bx,ax 
    cmp bx,8000h ; 8000H un cas speciale car on accepte -32678 et on n'accepte pas 32678
    jnz continue
    cmp positive,1
    jz overflow
    jmp conversion    
 continue:
    inc si
    dec cl
               
    jmp do
    suite: 
    jmp remake
    lea dx,attention
    mov ah,9
    int 21h         
   ; jmp lecture    
     
   overflow:
    lea dx,overf
    mov ah,9
    int 21h 
    jmp remake        
   ; jmp lecture 
    
    
    
    verifie: ; on verifie que le nombre est sur 16 bits     
    
    cmp bx,32768
    ja overflow ; si le nombre strictement superieur a 32768 
    
    
    
  conversion:
    cmp positive,1
    jz fin
    neg bx
       
   fin:  
      ret  
  lire endp 
    
;******************************************************************************************;
    
    
    
    ; add your code here
    proc addition
        mov cl,0
        cmp ax,0
        js negatif
        cmp bx,0
        js normal
        mov cl,1 ; un indice pour savoir que les deux nombre sont positifs
        
        
        jmp calcul
        
            
negatif:
        cmp bx,0
        jns  normal 
        neg ax
        neg bx  
        mov cl,2 ; les deux nombres sont negatifs

calcul:        
    add ax,bx
    js over_flow
    cmp cl,1
    je fiin
    neg ax    
    jmp fiin
    
over_flow:
    print "Il ya un depacement "

normal:
        add ax,bx 
 
 fiin:           
    ret
    endp addition
    
    ;************************************;
    proc calculer 
      mov si,0
      mov di,0
      mov resu,0
      mov virgule,0
      mov signe,0
      mov resultat,0
      mov k,0
      mov long_exp,0
      mov bl,final[si]
      mov mull[di],bl
      inc si
      inc di
      mov bl,final[si]
      mov mull[di],bl
      inc si
      inc di
first:      
      mov bl,final[si]
      cmp bl,'$'
      jz okk
      cmp bl,'+'
      jz second 
      cmp bl,'-'
      jz second 
      mov mull[di],bl 
      inc di
      inc si
      
      mov bl,final[si]
      mov mull[di],bl
      inc si
      inc di
      mov bl,final[si]
      mov mull[di],bl
      inc si
      inc di
      jmp first
      
      
      
  second: 
      mov long_exp,di
      
      push si
      call evaluation1
      pop si
      ; recuperation ds donnee
      mov ax,resu ;(partie entiere)
      mov dx,virgule ;(partie de la virgule)  
      mov cl,final[si]; l'operation
      inc si
      mov di,0
      
      
      
 boocle:     
      mov bl,final[si]
      mov mull[di],bl
      inc si
      inc di
      mov bl,final[si]
      mov mull[di],bl
      inc si
      inc di
      
       
     
      mov bl,final[si]
      cmp bl,'$'
      jz suivant
      cmp bl,'-'
      jz suivant
      cmp bl,'+'
      jz suivant
      mov mull[di],bl
      inc di
      inc si
      jmp boocle
suivant:      
      push si
      push ax
      push bx
      push cx 
      push dx 
      mov long_exp,di
      call evaluation1
      pop dx
      pop cx
      pop bx
      pop ax
      pop si
      ;mov dx,virgule; la virgule dans dx
      mov bx,resu
      
      cmp cl,'+'
      jz possitive
      neg bx
      neg virgule
      
      
      
      
possitive:      
      push si
      push dx
      call addition
      pop dx
      pop si
      
      add dx,virgule
      cmp dx,9
      jng s1
      sub dx,10
      inc ax
      mov virgule,dx
      jmp goto_next      
s1:   
   
      cmp dx,-9
      jnl goto_next
      add dx,10
      dec ax
      mov virgule,dx
      
             
      
goto_next:      
      mov virgule,dx
      
      mov cl,final[si]
      
      cmp cl,'$' 
      jne ici
      mov resu,ax
      mov virgule,dx
      jmp la_fin
      
ici:      
      inc si 
      
      mov di,0       
      jmp boocle
    
okk: 
      mov long_exp,di
      call evaluation1

          
    ; un numero seulment

la_fin:  
    
    
    mov dx,virgule
    
    mov cx,resu
    cmp cx,0
    jz fin5
    cmp dx,0
    jns fin5
    add virgule,10 
    
    dec resu
    dec cx

fin5:     
    ret
    endp calculer
;****************************************************/    
; transfer l'expression de l'utulisateur a des nombre (operande operation operande ... )
    proc change

    
    



    mov cx ,0 
    mov si,3 ; I
    mov di,3 ; J
    mov cl,expression[1]
    dec cx 
    mov res[1],1
    mov al, expression[2]
    mov res[2],al  
    cmp cx,0
    jz  Finn
pour1:
    mov al,expression[si]
    
    cmp al,48   
    jb operation
    cmp al,57
    ja operation 
    mov res[di],al
    inc di
    inc res[1]
    jmp next
    
   
operation: 
    push si 
    push cx 
    call lire
     
    mov di ,k
    mov final[di],bl  ;;;;;;; 
    mov final[di+1],bh ;;;;;
    inc di 
    inc di 
    pop cx
    pop si
    mov al,expression[si]
    mov final[di],al
    inc di 
    
    mov k,di

    
    dec cx
     
    mov di ,3
    inc si
    mov res[1],1  
    mov al,expression[si]
    mov res[2],al
   
next:   
    inc si
    loop pour1 
    
    
    
    
    
    ;************;
    
Finn:    
    call lire
     
    mov di ,k
    mov final[di],bl  ;;;;;;; 
    mov final[di+1],bh ;;;;;
    mov final[di+2],'$'
    
   ;**************; 
    
    
     
    ret
    endp change


    
remake:
    print 13
    print 10
    print "il y a une erreur !"  
programme:    
    print 13
    print 10  
    print "Entrer votre expression : "
    print 13
    print 10
     
    mov expression,98
    mov ah,10 
    lea dx,expression
    int 33
    
    call change 
    call calculer    
    mov case,cx
    push ds
    lea bx,case
    push bx
    call  afich
    print 13
    print 10
    print "Tapez ECHAP pour sortir ou autre touche pour une autre expression ! "
    print 13
    print 10       
    mov ah, 1
    int 21h
    
    cmp al,27
    jnz programme
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.

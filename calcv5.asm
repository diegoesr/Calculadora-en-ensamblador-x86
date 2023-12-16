title "EyPC 2023-II Grupo 2 Proyecto - Base"
	.model small
	.386
	.stack 64
;Macros
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm
;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 
;inicializa_ds - Inicializa el valor del registro DS
inicializa_ds 	macro
	mov ax,@data
	mov ds,ax
endm
;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm
;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm
;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm
;imprime_caracter_color - Imprime un caracter de cierto color en pantalla especificado por 'caracter' y 'color'. Los colores disponibles están en la lista a continuacion;
; Colores:
; 00h: Negro
; 01h: Azul
; 02h: Verde
; 03h: Cyan
; 04h: Rojo
; 05h: Magenta
; 06h: Cafe
; 07h: Gris Claro
; 08h: Gris Oscuro
; 09h: Azul Claro
; 0Ah: Verde Claro
; 0Bh: Cyan Claro
; 0Ch: Rojo Claro
; 0Dh: Magenta Claro
; 0Eh: Amarillo
; 0Fh: Blanco
; utiliza int 10h opcion 09h
imprime_caracter_color macro caracter,bg_color,color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;DL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,bg_color         ;BL (4 bits mas significativos) = color de fondo del caracter
    xor bl,color 	    	;BL (4 bits menos significativos) = color del caracter
    
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm
;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm
;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm
	.data
;Constantes de colores de modo de video
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h

digitos		equ		4

num1 		db 		digitos dup(0) 		;primer numero, en cada localidad guarda 1 digito, puede ser hasta 4 digitos
num2 		db 		digitos dup(0)		;segundo numero, en cada localidad guarda 1 digito, puede ser hasta 4 digitos
num1h		dw		0
num2h		dw		0
resultado	dw		0,0 			;resultado es un arreglo de 2 datos tipo word
									;el primer dato [resultado] puede guardar el contenido del resultado para la suma, resta, cociente de division o residuo de division
									;el segundo dato [resultado+2], en conjunto con [resultado] pueden almacenar la multiplicacion de dos numeros de 16 bits
conta1 		dw 		0
conta2 		dw 		0
operador 	db 		0
num_boton 	db 		0
num_impr 	db 		0
id_base		db		0

;Auxiliares para calculo de digitos de un numero decimal de hasta 5 digitos
diezmil		dw		10000d
mil			dw		1000d
cien 		dw 		100d
diez		dw		10d
;Auxiliar para calculo de coordenadas del mouse
ocho		db 		8
;Cuando el driver del mouse no esta disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'

;MARCO PRINCIPAL DE LA INTERFAZ GRAFICA
;Caracteres del marco superior
;columnas		000,	001		002		003		004		005		006		007		008		009		010		011		012		013		014		015		016		017		018		019		020		021		022		023		024		025		026		027		028		029		030		031		032		033		034		035		036		037		038		039		040		041		042		043		044		045		046		047		048		049		050		051		052		053		054		055		056		057		058		059		060		061		062		063		064		065		066		067		068		069		070		071		072		073		074		075		076		077		078		079
marco_sup	db	201,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	'C',	'A',	'L',	'C',	'U',	'L',	'A',	'D',	'O',	'R',	'A',	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	'[',	'X',	']',	187
;Caracter del marco lateral
marco_lat	db	186
;Caracteres del marco inferior
marco_inf	db	200,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	188

;MARCO DE LA CALCULADORA
;Caracteres del marco superior
;					000,	001		002		003		004		005		006		007		008		009		010		011		012		013		014		015		016		017		018		019		020		021		022		023		024		025		026		027		028		029		030		031		032		033		034		035		036		037		038		039		040		041		042		043		044		045		046		047		048		049
marco_sup_cal	db	201,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	187
;Caracter del marco lateral
marco_lat_cal	db	186
;Caracter del marco de cruce superior
marco_csup_cal	db	203
;Caracter del marco de cruce inferior
marco_cinf_cal	db	202
;Caracter del marco de cruce izquierdo
marco_cizq_cal	db	204
;Caracter del marco de cruce derecho
marco_cder_cal	db	185
;Caracteres del marco inferior
marco_inf_cal	db	200,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	205,	188
;Caracter del marco horizontal interno
marco_hint_cal	db	205
;Caracter del marco vertical interno
marco_vint_cal	db	186

;MARCO DE BOTON
;Caracteres del marco superior
;					000,	001		002		003		004
marco_sup_bot	db	218,	196,	196,	196,	191
;Caracter del marco lateral
marco_lat_bot	db	179
;Caracteres del marco inferior
marco_inf_bot	db	192,	196,	196,	196,	217

;Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
boton_caracter 	            db 		0
boton_renglon 	            db 		0
boton_columna 	            db 		0
boton_color		            db 		0
boton_caracter_color		db 		0

;Variables tipo byte auxiliares cuando se manejan renglones y columnas dentro de la pantalla
ren_aux 		db 		0
col_aux			db 		0

	.code
inicio:
	inicializa_ds
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se ejecutan las siguientes instrucciones
	lea dx,[no_mouse]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'
imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call MARCO_UI 			;procedimiento que dibuja marco de la interfaz
	call CALCULADORA_UI 	;procedimiento que dibuja la calculadora dentro de la interfaz
	muestra_cursor_mouse 	;hace visible el cursor del mouse
;Revisar que el boton izquierdo del mouse no este presionado
;Si el boton no esta suelto no continua
mouse_no_clic:
	lee_mouse
	test bx,0001h
	jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
	
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)
	

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je botonX
	;Si el mouse fue presionado antes del renglon 7
	;no hay nada que revisar
	cmp dx,7
	jb mouse_no_clic
	;Si el mouse fue presionado despues del renglon 21
	;no hay nada que revisar
	cmp dx,21
	jg mouse_no_clic
	;Si el mouse fue presionado antes de la columna 17
	;no hay nada que revisar
	cmp cx,17
	jb mouse_no_clic
	;Si el mouse fue presionado en la columna 29
	;no hay nada que revisar
	cmp cx,29
	je mouse_no_clic
	;Si el mouse fue presionado en la columna 
	;no hay nada que revisar
	cmp cx,35
	je mouse_no_clic
	;Si el mouse fue presionado en la columna 40
	;no hay nada que revisar
	cmp cx,41
	je mouse_no_clic
	;Si el mouse fue presionado despues de la columna 62
	;no hay nada que revisar
	cmp cx,62
	jg mouse_no_clic

	;Si el mouse fue presionado antes de la columna 21 y despues de la 17
	;es posible se haya presionado en un boton de base numerica
	cmp cx,21
	jbe botones_base_num

	;Si el mouse fue presionado antes de la columna 24 y despues de la 21
	;se presiono en un espacio vacio
	cmp cx,24
	jb jmp_mouse_no_clic

	;Si el mouse fue presionado antes o dentro de la columna 28 y despues de la 24
	;revisar si fue dentro de un boton
	;Botones entre columnas 24 y 28: '7', '4', '1', '0'
	cmp cx,28
	jbe botones_7_4_1_0

	;Si el mouse fue presionado antes o dentro de la columna 34 y despues de la 30
	;revisar si fue dentro de un boton
	;Botones entre columnas 30 y 34: '8', '5', '1', 'A'
	cmp cx,34
	jbe botones_8_5_2_A

	;Si el mouse fue presionado antes o dentro de la columna 40 y despues de la 36
	;revisar si fue dentro de un boton
	;Botones entre columnas 36 y 40: '9', '6', '3', 'B'
	cmp cx,41
	jbe botones_9_6_3_B

	;Si el mouse fue presionado antes o dentro de la columna 46 y despues de la 42
	;revisar si fue dentro de un boton
	;Botones entre columnas 42 y 46: 'F', 'E', 'D', 'C'
	cmp cx,46
	jbe botones_F_E_D_C

	;Si el mouse fue presionado antes o dentro de la columna 55 y despues de la 51
	;revisar si fue dentro de un boton
	;Botones entre columnas 42 y 55: '+', '*', '%'
	cmp cx,55
	jbe botones_Suma_Multilicacion_Residuo

	;Si el mouse fue presionado antes o dentro de la columna 62 y despues de la 58
	;revisar si fue dentro de un boton
	;Botones entre columnas 42 y 62: '+', '*', '%'
	cmp cx,62
	jbe botones_Resta_Cociente_Igual
jmp_mouse_no_clic:
	jmp mouse_no_clic

botones_base_num:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'Dec'
	cmp dx,9
	jbe botonDecimal

	;corresponde con boton 'Hex'
	cmp dx,13
	jbe botonHexadecimal

	;corresponde con boton 'Bin'
	cmp dx,17
	jbe botonBinario

	;corresponde con boton 'AC'
	cmp dx,21
	jbe botonAC


botones_7_4_1_0:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '7'
	cmp dx,9
	jbe boton7

	;renglon 12 es espacio vacio
	cmp dx,10
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '4'
	cmp dx,13
	jbe boton4

	;renglon 16 es espacio vacio
	cmp dx,14
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '1'
	cmp dx,17
	jbe boton1

	;renglon 20 es espacio vacio
	cmp dx,18
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '0'
	cmp dx,21
	jbe boton0

	;Si no es ninguno de los anteriores
	jmp mouse_no_clic
botones_8_5_2_A:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '8'
	cmp dx,9
	jbe boton8

	;renglon 12 es espacio vacio
	cmp dx,10
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '5'
	cmp dx,13
	jbe boton5

	;renglon 16 es espacio vacio
	cmp dx,14
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '2'
	cmp dx,17
	jbe boton2

	;renglon 20 es espacio vacio
	cmp dx,18
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'A'
	cmp dx,21
	jbe botonA

	;Si no es ninguno de los anteriores
	jmp mouse_no_clic

botones_9_6_3_B:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '9'
	cmp dx,9
	jbe boton9

	;renglon 12 es espacio vacio
	cmp dx,10
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '6'
	cmp dx,13
	jbe boton6

	;renglon 16 es espacio vacio
	cmp dx,14
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton '3'
	cmp dx,17
	jbe boton3

	;renglon 20 es espacio vacio
	cmp dx,18
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'B'
	cmp dx,21
	jbe botonB

	;Si no es ninguno de los anteriores
	jmp mouse_no_clic

botones_F_E_D_C:
	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'F'
	cmp dx,9
	jbe botonF

	;renglon 12 es espacio vacio
	cmp dx,10
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'E'
	cmp dx,13
	jbe botonE

	;renglon 16 es espacio vacio
	cmp dx,14
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'D'
	cmp dx,17
	jbe botonD

	;renglon 20 es espacio vacio
	cmp dx,18
	je mouse_no_clic

	;Revisar si el renglon en donde fue presionado el mouse
	;corresponde con boton 'C'
	cmp dx,21
	jbe botonC

	;Si no es ninguno de los anteriores
	jmp mouse_no_clic

botones_Suma_Multilicacion_Residuo:
	;Botón Suma
	cmp dx,9
	jb mouse_no_clic
	cmp dx,11
	jbe botonSuma

	;Botón Multiplicación
	cmp dx,12
	je mouse_no_clic
	cmp dx,15
	jbe botonMult

	;Botón Residuo
	cmp dx,16
	je mouse_no_clic
	cmp dx,19
	jbe botonDivR
botones_Resta_Cociente_Igual:
	;Botón Suma
	cmp dx,9
	jb mouse_no_clic
	cmp dx,11
	jbe botonResta

	;Botón Multiplicación
	cmp dx,12
	je mouse_no_clic
	cmp dx,15
	jbe botonDivC

	;Botón Residuo
	cmp dx,16
	je mouse_no_clic
	cmp dx,19
	jbe botonIgual
;Dependiendo la posicion del mouse
;se salta a la seccion correspondiente
botonX:
	jmp botonX_1
botonDecimal:
	mov id_base,0				
	call LIMPIA_PANTALLA_CALC
	call SELECT_Decimal
	jmp mouse_no_clic
botonHexadecimal:
	mov id_base,1				
	call LIMPIA_PANTALLA_CALC
	call SELECT_Hexadecimal
	jmp mouse_no_clic
botonBinario:
	mov id_base,2				
	call LIMPIA_PANTALLA_CALC
	call SELECT_Binario
	jmp mouse_no_clic
botonAC:
	xor BX,BX
			mov num1h,0
		mov num2h,0
	call LIMPIA_PANTALLA_CALC
	jmp mouse_no_clic	
;Logica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 79
botonX_1:
	cmp cx,76
	jge botonX_2
	jmp mouse_no_clic
botonX_2:
	cmp cx,78
	jbe botonX_3
	jmp mouse_no_clic
botonX_3:
	;Se cumplieron todas las condiciones
	jmp salir

;Logica para revisar si el mouse fue presionado en '1'
;boton '1' se encuentra entre renglones 15 y 17,
;y entre columnas 24 y 28
imprimirSimbolos:
	boton0:
		;Se cumplieron todas las condiciones
		mov num_boton,0d
		jmp jmp_lee_oper1		 ;Salto a 'jmp_lee_oper1' para procesar el numero

	boton1:
		;Se cumplieron todas las condiciones
		mov num_boton,1d
		jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	boton2:
		;Se cumplieron todas las condiciones
		mov num_boton,2d
		jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	boton3:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,3d
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	boton4:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,4d
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	boton5:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,5d
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero


	boton6:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,6d
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero


	boton7:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,7d
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero


	boton8:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,8d
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero


	boton9:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,9d
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	botonA:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,0Ah
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	botonB:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,0Bh
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	botonC:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,0Ch
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	botonD:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,0Dh
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	botonE:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,0Eh
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	botonF:
	 	;Se cumplieron todas las condiciones
	 	mov num_boton,0Fh
	 	jmp jmp_lee_oper1 		;Salto a 'jmp_lee_oper1' para procesar el numero

	botonSuma:
		mov operador,02Bh		;O2Bh = '+'
		jmp print_operador		;Salto a 'print_operador' imprimir simbolo	

	botonResta:
		mov operador,02Dh	 	;O2Dh = '-'
		jmp print_operador		;Salto a 'print_operador' imprimir simbolo	

	botonMult:
		mov operador,02Ah		;O2Ah = '*'
		jmp print_operador		;Salto a 'print_operador' imprimir simbolo	

	botonDivC:
		mov operador,02Fh		;02Fh = '/' 
		jmp print_operador		;Salto a 'print_operador' imprimir simbolo	

	botonDivR:
		mov operador,025h		;025h = '%' 
		jmp print_operador		;Salto a 'print_operador' imprimir simbolo	

	botonIgual:
		;mov operador,03Dh		;03Dh = '='
		jmp print_igual		;Salto a 'print_operador' imprimir simbolo	

;Salto auxiliar para hacer un salto más largo
jmp_lee_oper1:
	jmp lee_oper1

;Logica para revisar si el mouse fue presionado en C
;boton C se encuentra entre renglones 18 y 20,
;y entre columnas 24 y 28
;boton0_1:
	;Agregar la logica para verificar el boton 
	;y limpiar la pantalla de la calculadora
	
	;jmp jmp_lee_oper1

print_igual:
	call NUM2P
	
	cmp operador, '+'
	je Suma

	cmp operador, '-'
	je Restar

	cmp operador, '*'
	je Mult

	cmp operador, '/'
	je DivC

	cmp operador, '%' 
	je DivR

	Restar:
		cmp id_base, 0
		je RestaDec
		cmp id_base, 1
		je RestaHex
		cmp id_base, 2
		je RestaBin

		RestaDec:
			xor ax,ax
			xor bx,bx
			mov bx, num1h
			mov ax, num2h
			sbb bx, ax
			jmp imprimirResultado
		RestaHex:
			jmp imprimirResultado
		RestaBin:
			jmp imprimirResultado
	Suma:
		cmp id_base, 0
		je SumaDec
		cmp id_base, 1
		je SumaHex
		cmp id_base, 2
		je SumaBin
		SumaDec:
			xor ax,ax
			xor bx,bx
			mov bx, num1h
			mov ax, num2h
			adc bx, ax
			jmp imprimirResultado
		SumaHex:
			xor ax,ax
			xor bx,bx
			mov bx, num1h
			mov ax, num2h
			adc bx, ax
			add bx,37h
			jmp imprimirResultado
		SumaBin:
			xor ax,ax
			xor bx,bx
			mov bx, num1h
			mov ax, num2h
			or bx, ax
			jmp imprimirResultado


	Mult:
		cmp id_base, 0
		je MultDec
		je MultHex
		cmp id_base, 2
		je MultBin
		MultDec:
			xor ax,ax
			xor bx,bx
			mov ax, num1h
			mov bx, num2h
			mul bx
			;mov bx, dx
			;call IMPRIME_BX
			mov bx, ax
			jmp imprimirResultado
		MultHex:
			jmp imprimirResultado
		MultBin:
			jmp imprimirResultado
	DivC:
		cmp id_base, 0
		je DivCDec
		cmp id_base, 1
		je DivCHex
		cmp id_base, 2
		je DivCBin
		DivCDec:
			xor ax,ax
			xor bx,bx
			mov ax, num1h
			mov bx, num2h
			div bx
			mov bx,ax
			jmp imprimirResultado
		DivCHex:
			jmp imprimirResultado
		DivCBin:
			jmp imprimirResultado
	DivR:
		cmp id_base, 0
		je DivRDec
		cmp id_base, 1
		je DivRHex
		cmp id_base, 2
		je DivRBin
		DivRDec:
			xor ax,ax
			xor bx,bx
			mov ax, num1h
			mov bx, num2h
			div bx
			mov bx,dx
			jmp imprimirResultado
		DivRHex:
			jmp imprimirResultado
		DivRBin:
			jmp imprimirResultado

	imprimirResultado:
		call IMPRIME_BX
		jmp no_lee_num

print_operador:

	posiciona_cursor 4,52d
	imprime_caracter_color operador,bgNegro,cBlanco
	call NUM1P
	jmp no_lee_num


lee_oper1:
	cmp [operador],0	;compara el valor del operador que puede ser 0, '+', '-', '*', '/', '%'
	jne lee_oper2 		;Si el comparador es diferente de 0, entonces lee el segundo numero
	cmp [conta1],4 		;compara si el contador para num1 llego al maximo
	jae no_lee_num 		;si conta1 es mayor o igual a 4, entonces se ha alcanzado el numero de digitos
						;y no hace nada

	cmp num_boton,0		;comprueba si el num_botn es 0	
	je case_0			;Si salta a case_0
	jne base_cmp		;NO es salta a base_cmp

case_0:	
	cmp conta1,0		;compara si conta1 es 0
	je no_lee_num		;SI es igual no agrega mas 0's a pantalla
	
base_cmp:
	cmp id_base,1		;Si id_base = 1 (hex)
	je agregar_num_arr	;Imprime todos los numeros

	cmp id_base,2		;si id_base = 2 (bin)
	je case_id_bin1		;salta a case_id_2S

	cmp id_base,0		;si id_base = 0 (Dec)
	je case_id_dec1		;salta a case_id_0 

case_id_dec1:
	cmp num_boton,9		;compara numero seleccionado con 9
	jg no_lee_num		;si es mayor no leas numero
	jle agregar_num_arr	;si es menor o igual, agrega numero

case_id_bin1:
	cmp num_boton,1		;compara numero seleccionado con 1
	jg no_lee_num		;si es mayor NO leas		
	jle agregar_num_arr	;si es menor o igual, se agrega


agregar_num_arr:
	mov al,num_boton	;valor del boton presionado en AL
	mov di,[conta1] 	;copia el valor de conta1 en registro indice DI
	mov [num1+di],al 	;num1 es un arreglo de tipo byte
						;se guarda el valor del boton presionado en el arreglo
	inc [conta1] 		;incrementa conta1 por numero correctamente leido
	
	xor di,di 			;limpia DI para utilizarlo
	mov cx,[conta1] 	;prepara CX para loop de acuerdo al numero de digitos introducidos
	mov [ren_aux],3 	;variable ren_aux para hacer operaciones en pantalla 
						;ren_aux se mantiene fijo a lo largo del siguiente loop
imprime_num1:
	push cx 				;guarda el valor de CX en la pila
	mov [col_aux],58d 		;variable col_aux para hacer operaciones en pantalla 
							;para recorrer la pantalla al imprimir el numero
	sub [col_aux],cl 		;Para calcular la columna en donde comienza a imprimir en pantalla de acuerdo a CX
	posiciona_cursor [ren_aux],[col_aux] 	;Posiciona el cursor en pantalla usando ren_aux y col_aux
	mov cl,[num1+di] 		;copia el digito en CL
	add cl,30h				;Pasa valor ASCII
	cmp cl,39h				;Compara si CL con a 39h
	jbe print_char			;Salta a print_char si es menor o igual a 39h
	add cl,7				;Suma 7 para transformar ASCII HEX
	
print_char:
	imprime_caracter_color cl,bgNegro,cBlanco	;Imprime caracter en CL, color blanco
	;guardar digito
	inc di 					;incrementa DI para recorrer el arreglo num1
	pop cx 					;recupera el valor de CX al inicio del loop
	loop imprime_num1 		

	jmp mouse_no_clic

lee_oper2:
	cmp [conta2],4 		;compara si el contador para num2 llego al maximo
	jae no_lee_num 		;si conta2 es mayor o igual a 4, entonces se ha alcanzado el numero de digitos
						;y no hace nada
	cmp num_boton,0		;prueba si el num_botn es 0	
	je case_02			;si es 0 salta a case_0
	jne base_cmp2		;Si no es salta a base_cmp

case_02:	
	cmp conta2,0		;compara si conta1 es 0
	je no_lee_num		;si es igual no agrega mas 0's a pantalla
	
base_cmp2:
	cmp id_base,1		;Si id_base = 1 (hex)
	je agregar_num_arr2	;Imprime todos los numeros

	cmp id_base,2		;si id_base = 2 (bin)
	je case_id_bin2		;salta a case_id_2

	cmp id_base,0	;si id_base = 0 (Dec)
	je case_id_dec2		;salta a case_id_0 

case_id_dec2:
	cmp num_boton,9		;compara numero seleccionado con 9
	jg no_lee_num		;si es mayor no leas numero
	jle agregar_num_arr2	;si es menor o igual, agrega numero

case_id_bin2:
	cmp num_boton,1		;compara numero seleccionado con 1
	jg no_lee_num		;si es mayor, no leas		
	jle agregar_num_arr2	;si es menor o igual, agrega


agregar_num_arr2:
	mov al,num_boton	;valor del boton presionado en AL
	mov di,[conta2] 	;copia el valor de conta1 en registro indice DI
	mov [num2+di],al 	;num2 es un arreglo de tipo byte
						;se utiliza di para acceder el elemento di-esimo del arreglo num1
						;se guarda el valor del boton presionado en el arreglo
	inc [conta2] 		;incrementa conta1 por numero correctamente leido
	
	;Se imprime el numero del arreglo num1 de acuerdo a conta1
	xor di,di 			;limpia DI para utilizarlo
	mov cx,[conta2] 	;prepara CX para loop de acuerdo al numero de digitos introducidos
	mov [ren_aux],4 	;variable ren_aux para hacer operaciones en pantalla 
						;ren_aux se mantiene fijo a lo largo del siguiente loop
imprime_num2:
	push cx 				;guarda el valor de CX en la pila
	mov [col_aux],58d 		;variable col_aux para hacer operaciones en pantalla 
							;para recorrer la pantalla al imprimir el numero
	sub [col_aux],cl 		;Para calcular la columna en donde comienza a imprimir en pantalla de acuerdo a CX
	posiciona_cursor [ren_aux],[col_aux] 	;Posiciona el cursor en pantalla usando ren_aux y col_aux
	mov cl,[num2+di] 		;copia el digito en CL
	add cl,30h				;Pasa valor ASCII
	cmp cl,39h				;Compara si CL con a 39h
	jbe print_char2			;Salta a print_char si es menor o igual a 39h
	add cl,7				;Suma 7 para transformar ASCII HEX
	
print_char2:
	imprime_caracter_color cl,bgNegro,cBlanco	;Imprime caracter en CL, color blanco
	inc di 					;incrementa DI para recorrer el arreglo num1
	pop cx 					;recupera el valor de CX al inicio del loop
	loop imprime_num2 		

	jmp mouse_no_clic					


no_lee_num:
	jmp mouse_no_clic

;Si no se encontró el driver del mouse, muestra un mensaje y debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:
 	clear
	mov ax,4C00h
	int 21h

NUM1P proc

	cmp num1h,0
	jne exitproc1

	cmp id_base,0
	je num1_decimal

	cmp id_base,1
	je num1_hexadecimal

	cmp id_base,2
	je num1_binario

	num1_decimal:
		xor ax,ax
		mov al,[num1+3]
		mov bx, 1000d
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1+2]
		mov bx, 100d
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1+1]
		mov bx, 10d
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1]
		mov bx, 1d
		mul bx
		add num1h,ax

		jmp exitproc1

	num1_hexadecimal:
		xor ax,ax
		mov al,[num1+3]
		mov bx, 1000h
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1+2]
		mov bx, 100h
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1+1]
		mov bx, 10h
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1]
		mov bx, 1
		mul bx
		add num1h,ax

		jmp exitproc1

	num1_binario:
		xor ax,ax
		mov al,[num1+3]
		mov bx, 8d
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1+2]
		mov bx, 4d
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1+1]
		mov bx, 2d
		mul bx
		add num1h,ax

		xor ax,ax
		mov al,[num1]
		mov bx, 1d
		mul bx
		add num1h,ax

	exitproc1:

	ret
	endp 

NUM2P proc

	cmp num2h,0
	jne exitproc2

	cmp id_base,0
	je num2_decimal

	cmp id_base,1
	je num2_hexadecimal

	cmp id_base,2
	je num2_binario

	num2_decimal:
		xor ax,ax
		mov al,[num2+3]
		mov bx, 1000d
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2+2]
		mov bx, 100d
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2+1]
		mov bx, 10d
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2]
		mov bx, 1d
		mul bx
		add num2h,ax

		jmp exitproc2

	num2_hexadecimal:
		xor ax,ax
		mov al,[num2+3]
		mov bx, 1000h
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2+2]
		mov bx, 100h
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2+1]
		mov bx, 10h
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2]
		mov bx, 1
		mul bx
		add num2h,ax

		jmp exitproc2

	num2_binario:
		xor ax,ax
		mov al,[num2+3]
		mov bx, 8d
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2+2]
		mov bx, 4d
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2+1]
		mov bx, 2d
		mul bx
		add num2h,ax

		xor ax,ax
		mov al,[num2]
		mov bx, 1d
		mul bx
		add num2h,ax

	exitproc2:

	ret
	endp  


	;procedimiento MARCO_UI
	;no requiere parametros de entrada
	;Dibuja el marco de la interfaz de usuario del programa 
	MARCO_UI proc
		xor di,di
		mov cx,80d
		mov [col_aux],0
		marcos_horizontales:
		push cx
		;Imprime marco superior
		posiciona_cursor 0,[col_aux]
		cmp [marco_sup+di],'X'
		je cerrar
		superior:
		imprime_caracter_color [marco_sup+di],bgNegro,cBlanco
		jmp inferior
		cerrar:
		imprime_caracter_color [marco_sup+di],bgNegro,cRojoClaro
		inferior:
		;Imprime marco inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color [marco_inf+di],bgNegro,cBlanco
		inc [col_aux]
		inc di
		pop cx
		loop marcos_horizontales
		
		;Imprime marcos laterales
		xor di,di
		mov cx,23		;cx = 23d = 17h. Prepara registro CX para loop. 
						;para imprimir los marcos laterales en pantalla, entre el segundo y el penúltimo renglones
		mov [ren_aux],0
		marcos_verticales:
		push cx
		inc [ren_aux]
		posiciona_cursor [ren_aux],0
		imprime_caracter_color [marco_lat],bgNegro,cBlanco
		posiciona_cursor [ren_aux],79
		imprime_caracter_color [marco_lat],bgNegro,cBlanco
		pop cx
		loop marcos_verticales
		ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador

	;procedimiento CALCULADORA_UI
	;no requiere parametros de entrada
	;Dibuja el marco de la calculador en la interfaz de usuario del programa 
	CALCULADORA_UI proc
		xor di,di
		mov cx,50d
		mov [col_aux],15d
		marcos_hor_cal:
		push cx
		;Imprime marco superior
		posiciona_cursor 1,[col_aux]
		imprime_caracter_color [marco_sup_cal+di],bgNegro,cCyanClaro
		;Imprime marco inferior
		posiciona_cursor 23,[col_aux]
		imprime_caracter_color [marco_inf_cal+di],bgNegro,cCyanClaro
		inc [col_aux]
		inc di
		pop cx
		loop marcos_hor_cal
		
		;Imprime marcos laterales
		xor di,di
		mov cx,21d		;cx = 20d. Prepara registro CX para loop. 
						;para imprimir los marcos laterales en pantalla, entre el segundo y el penúltimo renglones
		mov [ren_aux],1
		marcos_ver_cal:
		push cx
		inc [ren_aux]
		posiciona_cursor [ren_aux],15
		imprime_caracter_color [marco_lat_cal],bgNegro,cCyanClaro
		posiciona_cursor [ren_aux],64
		imprime_caracter_color [marco_lat_cal],bgNegro,cCyanClaro
		pop cx
		loop marcos_ver_cal

		;Imprime marco horizontal interno
		mov cx,48
		mov [col_aux],16d
		marco_hor_interno_cal:
		push cx
		posiciona_cursor 6,[col_aux]
		imprime_caracter_color [marco_hint_cal],bgNegro,cCyanClaro
		inc [col_aux]
		pop cx
		loop marco_hor_interno_cal

		;Imprime marco vertical interno
		mov cx,16d
		mov [ren_aux],7
		marco_ver_interno_cal:
		push cx
		posiciona_cursor [ren_aux],49
		imprime_caracter_color [marco_vint_cal],bgNegro,cCyanClaro
		inc [ren_aux]
		pop cx
		loop marco_ver_interno_cal

		;Imprime intersecciones
		marco_intersecciones:
		;interseccion izquierda
		posiciona_cursor 6,15
		imprime_caracter_color [marco_cizq_cal],bgNegro,cCyanClaro
		;interseccion derecha
		posiciona_cursor 6,64
		imprime_caracter_color [marco_cder_cal],bgNegro,cCyanClaro
		;interseccion superior
		posiciona_cursor 6,49
		imprime_caracter_color [marco_csup_cal],bgNegro,cCyanClaro
		;interseccion inferior
		posiciona_cursor 23,49
		imprime_caracter_color [marco_cinf_cal],bgNegro,cCyanClaro

		;Imprimir botones
		;Imprime Boton 0
		mov [boton_columna],24
		mov [boton_renglon],19
		mov [boton_color],bgMagenta
        mov [boton_caracter_color],cBlanco
		mov [boton_caracter],'0'
		call IMPRIME_BOTON

		;Imprime Boton 1
		mov [boton_columna],24
		mov [boton_renglon],15
		mov [boton_color],bgMagenta
        mov [boton_caracter_color],cBlanco
		mov [boton_caracter],'1'
		call IMPRIME_BOTON

		;Imprime Boton 2
		mov [boton_columna],30
		mov [boton_renglon],15
		mov [boton_color],bgGrisClaro
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'2'
		call IMPRIME_BOTON

		;Imprime Boton 3
		mov [boton_columna],36
		mov [boton_renglon],15
		mov [boton_color],bgGrisClaro
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'3'
		call IMPRIME_BOTON

		;Imprime Boton 4
		mov [boton_columna],24
		mov [boton_renglon],11
		mov [boton_color],bgGrisClaro
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'4'
		call IMPRIME_BOTON

		;Imprime Boton 5
		mov [boton_columna],30
		mov [boton_renglon],11
		mov [boton_color],bgGrisClaro
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'5'
		call IMPRIME_BOTON

		;Imprime Boton 6
		mov [boton_columna],36
		mov [boton_renglon],11
		mov [boton_color],bgGrisClaro
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'6'
		call IMPRIME_BOTON

		;Imprime Boton 7
		mov [boton_columna],24
		mov [boton_renglon],7
		mov [boton_color],bgGrisClaro
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'7'
		call IMPRIME_BOTON

		;Imprime Boton 8
		mov [boton_columna],30
		mov [boton_renglon],7
		mov [boton_color],bgGrisClaro
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'8'
		call IMPRIME_BOTON

		;Imprime Boton 9
		mov [boton_columna],36
		mov [boton_renglon],7
		mov [boton_color],bgGrisClaro
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'9'
		call IMPRIME_BOTON

		;Imprime Boton A
		mov [boton_columna],30
		mov [boton_renglon],19
		mov [boton_color],bgVerde
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'A'
		call IMPRIME_BOTON

		;Imprime Boton B
		mov [boton_columna],36
		mov [boton_renglon],19
		mov [boton_color],bgVerde
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'B'
		call IMPRIME_BOTON

		;Imprime Boton C
		mov [boton_columna],42
		mov [boton_renglon],19
		mov [boton_color],bgVerde
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'C'
		call IMPRIME_BOTON

		;Imprime Boton D
		mov [boton_columna],42
		mov [boton_renglon],15
		mov [boton_color],bgVerde
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'D'
		call IMPRIME_BOTON

		;Imprime Boton E
		mov [boton_columna],42
		mov [boton_renglon],11
		mov [boton_color],bgVerde
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'E'
		call IMPRIME_BOTON

        ;Imprime Boton F
		mov [boton_columna],42
		mov [boton_renglon],7
		mov [boton_color],bgVerde
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'F'
		call IMPRIME_BOTON

		;Imprime Boton +
		mov [boton_columna],51
		mov [boton_renglon],9
		mov [boton_color],bgAmarillo
        mov [boton_caracter_color],cRojo
		mov [boton_caracter],'+'
		call IMPRIME_BOTON

		;Imprime Boton -
		mov [boton_columna],58
		mov [boton_renglon],9
		mov [boton_color],bgAmarillo
        mov [boton_caracter_color],cRojo
		mov [boton_caracter],'-'
		call IMPRIME_BOTON

		;Imprime Boton *
		mov [boton_columna],51
		mov [boton_renglon],13
		mov [boton_color],bgAmarillo
        mov [boton_caracter_color],cRojo
		mov [boton_caracter],'*'
		call IMPRIME_BOTON

		;Imprime Boton /
		mov [boton_columna],58
		mov [boton_renglon],13
		mov [boton_color],bgAmarillo
        mov [boton_caracter_color],cRojo
		mov [boton_caracter],'/'
		call IMPRIME_BOTON

		;Imprime Boton %
		mov [boton_columna],51
		mov [boton_renglon],17
		mov [boton_color],bgAmarillo
        mov [boton_caracter_color],cRojo
		mov [boton_caracter],'%'
		call IMPRIME_BOTON

		;Imprime Boton =
		mov [boton_columna],58
		mov [boton_renglon],17
		mov [boton_color],bgRojo
        mov [boton_caracter_color],cNegro
		mov [boton_caracter],'='
		call IMPRIME_BOTON

        ;Imprime Boton Dec
		mov [boton_columna],17
		mov [boton_renglon],7
		mov [boton_color],bgAzulClaro
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'D',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'c',[boton_color],[boton_caracter_color]

        ;Imprime Boton Hex
		mov [boton_columna],17
		mov [boton_renglon],11
		mov [boton_color],bgAzul
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'H',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'x',[boton_color],[boton_caracter_color]

        ;Imprime Boton Bin
		mov [boton_columna],17
		mov [boton_renglon],15
		mov [boton_color],bgAzul
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'B',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'i',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'n',[boton_color],[boton_caracter_color]
        
		;Imprime Boton Limpiar
		mov [boton_columna],17
		mov [boton_renglon],19
		mov [boton_color],bgRojo
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'A',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'C',[boton_color],[boton_caracter_color]

		;Imprime un '0' inicial en la calculadora
		posiciona_cursor 3,57d
		imprime_caracter_color '0',bgNegro,cBlanco
		ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador

    ;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;background de botón
		mov bh,[boton_color]	 	;Color del botón
        xor bh,[boton_caracter_color]	 	;Color del botón
		;Posicion superior izquierda de donde comienza el boton
        mov ch,[boton_renglon]
		mov cl,[boton_columna]
        ;Posicion inferior derecha de donde termina el boton
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,4
		mov ax,0600h 		    ;AH=06h (scroll up window) AL=00h (borrar)
		int 10h                 ;int 10h opción 06h. Establece el color de fondo en pantalla, con los atributos dados, 
                                ;especificando CX: esquina superior izquierda CH: renglon, CL: columna y 
                                ;DX: esquina inferior derecha, DH: renglon y DL: columna
		;Mover al centro de la posición actual para imprimir el caracter
        mov [col_aux],dl
		mov [ren_aux],dh
		sub [col_aux],2
		sub [ren_aux],1
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],[boton_color],[boton_caracter_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento IMPRIME_BOTON para el ensamblador

	;procedimiento IMPRIME_BX
	;Imprime un numero entero decimal guardado en BX
	;Se pasa un numero a traves del registro BX que se va a imprimir con 4 o 5 digitos
	;Si BX es menor a 10000, imprime 4 digitos, si no imprime 5 digitos
	;Antes de llamar el procedimiento, se requiere definir la posicion en pantalla
	;a partir de la cual comienza la impresion del numero con ayuda de las variables [ren_aux] y [col_aux]
	;[ren_aux] para el renglon (entre 0 y 24)
	;[col_aux] para la columna (entre 0 y 79)
	IMPRIME_BX	proc 
		;Antes de comenzar, se guarda un respaldo de los registros
		; CX, DX, AX en la pila
		;Al terminar el procedimiento, se recuperan estos valores
		push cx
		push dx
		push ax
		;Calcula digito de decenas de millar
		mov cx,bx
		cmp bx,10d
		jb imprime_1_digs
		cmp bx,100d
		jb imprime_2_digs
		cmp bx,1000d
		jb imprime_3_digs
		
		cmp bx,10000d

		jb imprime_4_digs

		mov ax,bx 				;pasa el valor de BX a AX para division de 16 bits
		xor dx,dx 				;limpia registro DX, para extender AX a 32 bits
		div [diezmil]			;Division de 16 bits => AX=cociente, DX=residuo
								;El cociente contendrá el valor del dígito que puede ser entre 0 y 9. 
								;Por lo tanto, AX=000Xh => AH=00h y AL=0Xh, donde X es un dígito entre 0 y 9
								;Asumimos que el digito ya esta en AL
								;El residuo se utilizara para los siguientes digitos
		mov cx,dx 				;Guardamos el residuo anterior en un registro disponible para almacenarlo temporalmente
								;debido a que modificaremos DX antes de usar ese residuo
		;Imprime el digito decenas de millar 
		add al,30h				;Pasa el digito en AL a su valor ASCII
		mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
		push cx
		mov [ren_aux], 5
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [num_impr],bgNegro,cBlanco	
		pop cx
		inc [col_aux] 			;Recorre a la siguiente columna para imprimir el siguiente digito

		imprime_4_digs:
		;Calcula digito de unidades de millar
		
		mov ax,cx 				;Recuperamos el residuo de la division anterior y preparamos AX para hacer division
		xor dx,dx 				;limpia registro DX, para extender AX a 32 bits
		div [mil]				;Division de 16 bits => AX=cociente, DX=residuo
								;El cociente contendrá el valor del dígito que puede ser entre 0 y 9. 
								;Por lo tanto, AX=000Xh => AH=00h y AL=0Xh, donde X es un dígito entre 0 y 9
								;Asumimos que el digito ya esta en AL
								;El residuo se utilizara para los siguientes digitos
		mov cx,dx 				;Guardamos el residuo anterior en un registro disponible para almacenarlo temporalmente
								;debido a que modificaremos DX antes de usar ese residuo
		;Imprime el digito unidades de millar
		add al,30h				;Pasa el digito en AL a su valor ASCII
		mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
		push cx
		mov [ren_aux], 5
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [num_impr],bgNegro,cBlanco		
		pop cx
		inc [col_aux] 			;Recorre a la siguiente columna para imprimir el siguiente digito
		imprime_3_digs:
		;Calcula digito de centenas
		
		mov ax,cx 				;Recuperamos el residuo de la division anterior y preparamos AX para hacer division
		xor dx,dx 				;limpia registro DX, para extender AX a 32 bits
		div [cien]				;Division de 16 bits => AX=cociente, DX=residuo
								;El cociente contendrá el valor del dígito que puede ser entre 0 y 9. 
								;Por lo tanto, AX=000Xh => AH=00h y AL=0Xh, donde X es un dígito entre 0 y 9
	

								;Asumimos que el digito ya esta en AL
								;El residuo se utilizara para los siguientes digitos
		mov cx,dx 				;Guardamos el residuo anterior en un registro disponible para almacenarlo temporalmente
								;debido a que modificaremos DX antes de usar ese residuo
		;Imprime el digito de centenas
		add al,30h				;Pasa el digito en AL a su valor ASCII
		mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
		push cx
		mov [ren_aux], 5
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [num_impr],bgNegro,cBlanco
		pop cx
		inc [col_aux] 			;Recorre a la siguiente columna para imprimir el siguiente digito
		imprime_2_digs:		
		;Calcula digito de decenas
		
		mov ax,cx 				;Recuperamos el residuo de la division anterior y preparamos AX para hacer division
		xor dx,dx 				;limpia registro DX, para extender AX a 32 bits
		div [diez]				;Division de 16 bits => AX=cociente, DX=residuo
								;El cociente contendrá el valor del dígito que puede ser entre 0 y 9. 
								;Por lo tanto, AX=000Xh => AH=00h y AL=0Xh, donde X es un dígito entre 0 y 9
								;Asumimos que el digito ya esta en AL
								;El residuo se utilizara para los siguientes digitos
		mov cx,dx 				;Guardamos el residuo anterior en un registro disponible para almacenarlo temporalmente
								;debido a que modificaremos DX antes de usar ese residuo
		;Imprime el digito decenas
		add al,30h				;Pasa el digito en AL a su valor ASCII
		mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
		push cx
		mov [ren_aux], 5
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [num_impr],bgNegro,cBlanco		
		pop cx
		inc [col_aux]
		imprime_1_digs:
		;Calcula digito de unidades
		mov ax,cx 				;Recuperamos el residuo de la division anterior
								;Para este caso, el residuo debe ser un número entre 0 y 9
								;al hacer AX = CX, el residuo debe estar entre 0000h y 0009h
								;=> AX = 000Xh -> AH=00h y AL=0Xh
		;Imprime el digito de unidades
		add al,30h				;Pasa el digito en AL a su valor ASCII
		mov [num_impr],al 		;Pasa el digito a una variable de memoria ya que AL se modifica en las siguientes macros
		push cx
		mov [ren_aux], 5
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [num_impr],bgNegro,cBlanco

		;Se recuperan los valores de los registros CX, AX, y DX almacenados en la pila
		pop ax
		pop dx
		pop cx
		ret 					;intruccion ret para regresar de llamada a procedimiento
	endp

	;procedimiento LIMPIA_PANTALLA_CALC
	;no requiere parametros de entrada
	;"Borra" el contenido de lo que se encuentra en la pantalla de la calculadora
	LIMPIA_PANTALLA_CALC proc
		mov cx,4d
		limpia_num1_y_num2:
		push cx
		mov [col_aux],58d
		sub [col_aux],cl
		posiciona_cursor 3,[col_aux]
		imprime_caracter_color ' ',bgNegro,cNegro
		posiciona_cursor 4,[col_aux]
		imprime_caracter_color ' ',bgNegro,cNegro
		pop cx
		loop limpia_num1_y_num2

		limpia_operador:
		posiciona_cursor 4,52d
		imprime_caracter_color ' ',bgNegro,cNegro

		mov cx,10d
		limpia_resultado:
		push cx
		mov [col_aux],64d
		sub [col_aux],cl
		posiciona_cursor 5,[col_aux]
		imprime_caracter_color ' ',bgNegro,cNegro
		pop cx
		loop limpia_resultado

		posiciona_cursor 3,57d
		imprime_caracter_color '0',bgNegro,cBlanco

		;Reinicia valores de variables utilizadas
		mov [conta1],0
		mov [conta2],0
		mov [operador],0
		mov [num_boton],0
		mov [num1h],0
		mov [num2h],0
		xor BX,BX

		ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador

	SELECT_Decimal proc

	 ;Imprime Boton Decimal
	 	mov [boton_columna],17
		mov [boton_renglon],7
		mov [boton_color],bgAzulClaro
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'D',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'c',[boton_color],[boton_caracter_color]

        ;Imprime Boton Hexadecimal
		mov [boton_columna],17
		mov [boton_renglon],11
		mov [boton_color],bgAzul
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'H',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'x',[boton_color],[boton_caracter_color]

        ;Imprime Boton Binario
		mov [boton_columna],17
		mov [boton_renglon],15
		mov [boton_color],bgAzul
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'B',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'i',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'n',[boton_color],[boton_caracter_color]

		ret
	endp	

	SELECT_Hexadecimal proc

	 ;Imprime Boton Decimal
		mov [boton_columna],17
		mov [boton_renglon],7
		mov [boton_color],bgAzul
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'D',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'c',[boton_color],[boton_caracter_color]

        ;Imprime Boton Hexadecimal
		mov [boton_columna],17
		mov [boton_renglon],11
		mov [boton_color],bgAzulClaro
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'H',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'x',[boton_color],[boton_caracter_color]

        ;Imprime Boton Binario
		mov [boton_columna],17
		mov [boton_renglon],15
		mov [boton_color],bgAzul
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'B',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'i',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'n',[boton_color],[boton_caracter_color]

		ret
	endp

	SELECT_Binario proc

	 ;Imprime Boton Decimal
		mov [boton_columna],17
		mov [boton_renglon],7
		mov [boton_color],bgAzul
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'D',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'c',[boton_color],[boton_caracter_color]

        ;Imprime Boton Hexadecimal
		mov [boton_columna],17
		mov [boton_renglon],11
		mov [boton_color],bgAzul
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'H',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'e',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'x',[boton_color],[boton_caracter_color]

        ;Imprime Boton Binario
		mov [boton_columna],17
		mov [boton_renglon],15
		mov [boton_color],bgAzulClaro
        mov [boton_caracter_color],cBlanco
		call IMPRIME_BOTON
        inc [boton_columna]
        inc [boton_renglon]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'B',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'i',[boton_color],[boton_caracter_color]
        inc [boton_columna]
        posiciona_cursor [boton_renglon],[boton_columna]
		imprime_caracter_color 'n',[boton_color],[boton_caracter_color]

		ret
	endp

end inicio
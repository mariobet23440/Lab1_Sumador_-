/*
CONTADOR DE 4 BITS (CON ANTIRREBOTE)
Creado el 6/02/2025 a las 23:00
Autor: Mario Betancourt (23440)
Descripción: El programa implementa un contador de 4 bits con el microcontrolador ATMega328P
usando dos entradas en PORTB y cuatro salidas en PORTD.
*/

// Encabezado
.include "M328PDEF.inc"
.cseg
.org    0x0000

// Configurar la pila
LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16

SETUP:
	// Activación de pines de entrada en el puerto B
	LDI		R16, 0x00
	OUT		DDRB, R16
	LDI     R16, 0xFF
    OUT     PORTB, R16  // Habilitar pull-ups en puerto B

	// Usaremos el bit 0 de PORTB para el pushbutton de decremento y el bit 1 para el pushbutton de incremento
	// Al activar los pullups operamos con una lógica directa/inversa (???)

	// Activación de pines de salida en el puerto D
	LDI		R16, 0xFF
	OUT		DDRD, R16
	LDI     R16, 0x00
    OUT     PORTD, R16  // Apagar todos los bits de salida del puerto D
	
	// Usaremos el GPR R16 para almacenar el valor del contador 1
	// Usaremos el GPR R20 para almacenar el valor del contador 2
	LDI     R20, 0x00


MAINLOOP:
	// Ejecutar incremento y decremento de contadores
	CALL	CONTADOR1
	CALL	CONTADOR2

	// Una vez que se haya regresado, debemos unir los bits de R16 y R20
	// Para colocar los bits de R16 como los últimos bits de PORTD y los bits de R20 como los primeros
	// debemos desplazar los bits de R20 4 bits a la izquierda

	// Afortunadamente ya existe una función precisamente para eso
	SWAP	R20 // Con esto intercambiamos los nibbles de R20

	// Ahora unimos las dos cosas
	OR		R16, R20

	// Finalmente las sacamos en PORTD
	OUT		PORTD, R16


	// Repetir todo
	RJMP MAINLOOP

CONTADOR1:
	// Guardamos el valor de PORTB en R17 (Aquí van las dos entradas)
	IN		R17, PORTB

	// Cambio de flujo - Decremento
	SBRC	R17, 0
	CALL	DELAY_SETUP
	SBRC	R17, 0 
	DEC		R16

	// Cambio de flujo - Incremento
	SBRC	R17, 1
	CALL	DELAY_SETUP
	SBRC	R17, 1
	INC		R16

	// Truncar resultado a sólo cuatro bits
	ANDI	R16, 0x0F

	// Mostrar el resultado en PORTD
	// OUT		PORTD, R16

	// Regresar a MAINLOOP
	RET

CONTADOR2:
	// Para este contador usaremos los bits 2 y 3 de PORTB
	// El bit 2 servirá para decrementar el valor del contador
	// El bit 3 se usará para incrementar el valor del contador

	// Guardamos el valor de PORTB en R17 (Aquí van las dos entradas)
	IN		R17, PORTB

	// Cambio de flujo - Decremento
	SBRC	R17, 2
	CALL	DELAY_SETUP
	SBRC	R17, 2 
	DEC		R20

	// Cambio de flujo - Incremento
	SBRC	R17, 3
	CALL	DELAY_SETUP
	SBRC	R17, 3
	INC		R20

	// Truncar resultado a sólo cuatro bits
	ANDI	R20, 0x0F

	// Desplazar los 4 bits hacia la izquierda


	// Mostrar el resultado en PORTD
	// OUT		PORTD, R20
	// Podemos ver que el registro R20

	// Regresar a MAINLOOP
	RET

// Establecer registro de contador
DELAY_SETUP:
	LDI		R19, 0x01			// Cambiar a 0xFF
	CALL	SUBRUTINA_CONTEO1	// Entrar a una subrutina de conteo
	RET

SUBRUTINA_CONTEO1:
	// Contar hacia abajo desde 255 hasta 0 y después regresar a conteo
	DEC		R19
	CPI		R19, 0X00
	BRNE	SUBRUTINA_CONTEO1
	RET
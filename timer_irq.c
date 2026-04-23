#include "MKL25Z4.h"
#include <stdio.h>

// Variables globales volátiles
volatile uint16_t adc_values[3] = {0, 0, 0};
volatile uint8_t canal_actual = 0;
volatile uint8_t datos_listos = 0;
const uint8_t canales_fisicos[3] = {8, 9, 12}; // PTB0, PTB1, PTB2

// --- Inicialización de UART0 (9600 baud @ 48MHz) ---
void Init_UART0(void) {
    SIM->SCGC4 |= SIM_SCGC4_UART0_MASK;
    SIM->SCGC5 |= SIM_SCGC5_PORTA_MASK;
    SIM->SOPT2 |= SIM_SOPT2_UART0SRC(1); 
    PORTA->PCR[1] = PORT_PCR_MUX(2); 
    PORTA->PCR[2] = PORT_PCR_MUX(2); 
    UART0->C2 &= ~(UART0_C2_TE_MASK | UART0_C2_RE_MASK);
    uint16_t sbr = 312; 
    UART0->BDH = (sbr >> 8) & UART0_BDH_SBR_MASK;
    UART0->BDL = sbr & UART0_BDL_SBR_MASK;
    UART0->C2 |= (UART0_C2_TE_MASK | UART0_C2_RE_MASK);
}

void UART0_PutString(char* s) {
    while(*s) {
        while(!(UART0->S1 & UART0_S1_TDRE_MASK));
        UART0->D = *s++;
    }
}

// --- Inicialización de ADC0 con Interrupciones ---
void Init_ADC0(void) {
    SIM->SCGC6 |= SIM_SCGC6_ADC0_MASK;
    SIM->SCGC5 |= SIM_SCGC5_PORTB_MASK;
    // Configurar pines como analógicos
    PORTB->PCR[0] &= ~PORT_PCR_MUX_MASK;
    PORTB->PCR[1] &= ~PORT_PCR_MUX_MASK;
    PORTB->PCR[2] &= ~PORT_PCR_MUX_MASK;
    // 12 bits, Bus clock / 2
    ADC0->CFG1 = ADC_CFG1_ADICLK(1) | ADC_CFG1_MODE(1) | ADC_CFG1_ADIV(1);
    ADC0->SC1[0] = ADC_SC1_ADCH(31); // Deshabilitado inicialmente
    NVIC_EnableIRQ(ADC0_IRQn);
}

// --- Inicialización de TPM0 para 100ms exactos ---
void Init_TPM0_100ms(void) {
    SIM->SCGC6 |= SIM_SCGC6_TPM0_MASK;
    SIM->SOPT2 |= SIM_SOPT2_TPMSRC(1); // Reloj 48MHz
    
    TPM0->CNT = 0; 
    // Cálculo: (100ms * 48MHz / 128) - 1 = 37499
    TPM0->MOD = 37499; 
    
    // LPTPM increments, Prescaler 128, Timer Overflow Interrupt Enable
    TPM0->SC = TPM_SC_CMOD(1) | TPM_SC_PS(7) | TPM_SC_TOIE_MASK;
    
    NVIC_EnableIRQ(TPM0_IRQn);
}

// --- Manejadores de Interrupción (ISRs) ---

void TPM0_IRQHandler(void) {
    TPM0->SC |= TPM_SC_TOF_MASK; // Limpiar bandera TOF
    
    // Disparar la primera conversión analógica
    canal_actual = 0;
    ADC0->SC1[0] = ADC_SC1_AIEN_MASK | (canales_fisicos[canal_actual] & ADC_SC1_ADCH_MASK);
}

void ADC0_IRQHandler(void) {
    adc_values[canal_actual] = ADC0->R[0]; // Guarda dato y limpia COCO
    canal_actual++;

    if (canal_actual < 3) {
        // Disparar siguiente canal
        ADC0->SC1[0] = ADC_SC1_AIEN_MASK | (canales_fisicos[canal_actual] & ADC_SC1_ADCH_MASK);
    } else {
        datos_listos = 1; // Avisar al main que terminó el barrido
    }
}

int main(void) {
    char msg[64];
    
    __disable_irq();
    Init_UART0();
    Init_ADC0();
    Init_TPM0_100ms();
    __enable_irq();

    UART0_PutString("Sistema de monitoreo 100ms activo.\r\n");

    while (1) {
        if (datos_listos) {
            // Imprimir los 3 valores obtenidos
            sprintf(msg, "CH8:%04d | CH9:%04d | CH12:%04d\r\n", 
                    adc_values[0], adc_values[1], adc_values[2]);
            UART0_PutString(msg);
            
            datos_listos = 0; // Resetear bandera
        }
        
        __WFI(); // Dormir hasta el siguiente tick de 100ms
    }
}
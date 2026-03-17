/*
 * motor.c
 *
 *  Created on: Mar 17, 2026
 *      Author: tomo-
 */
/*
 * motor.c
 */
#include "motor.h"

void Motor_Init(Motor *m, TIM_HandleTypeDef *htim, uint32_t ch1, uint32_t ch2) {
    m->htim   = htim;
    m->ch_in1 = ch1;
    m->ch_in2 = ch2;
    HAL_TIM_PWM_Start(htim, ch1);
    HAL_TIM_PWM_Start(htim, ch2);
}

void Motor_Set(Motor *m, int speed) {
    if (speed >  999) speed =  999;
    if (speed < -999) speed = -999;

    if (speed >= 0) {
        __HAL_TIM_SET_COMPARE(m->htim, m->ch_in1, speed);
        __HAL_TIM_SET_COMPARE(m->htim, m->ch_in2, 0);
    } else {
        __HAL_TIM_SET_COMPARE(m->htim, m->ch_in1, 0);
        __HAL_TIM_SET_COMPARE(m->htim, m->ch_in2, -speed);
    }
}

void Motor_Stop(Motor *m) {
    __HAL_TIM_SET_COMPARE(m->htim, m->ch_in1, 0);
    __HAL_TIM_SET_COMPARE(m->htim, m->ch_in2, 0);
}

void Motor_Brake(Motor *m) {
    __HAL_TIM_SET_COMPARE(m->htim, m->ch_in1, 999);
    __HAL_TIM_SET_COMPARE(m->htim, m->ch_in2, 999);
}


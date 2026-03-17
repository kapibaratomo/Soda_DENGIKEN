/*
 * motor.h
 *
 *  Created on: Mar 17, 2026
 *      Author: tomo-
 */

#ifndef MOTOR_H
#define MOTOR_H

#include "stm32f4xx_hal.h"

typedef struct {
    TIM_HandleTypeDef *htim;
    uint32_t ch_in1;
    uint32_t ch_in2;
} Motor;

void Motor_Init(Motor *m, TIM_HandleTypeDef *htim, uint32_t ch1, uint32_t ch2);
void Motor_Set(Motor *m, int speed);  // speed: -999〜999
void Motor_Stop(Motor *m);
void Motor_Brake(Motor *m);

#endif

/*
 * Name: app_escon.xc
 * Author: John
 * Created on: 24/06/2013
 * Description:
 */

#include <xs1.h>
#include "basic_utils.h"

out port speed = XS1_PORT_1A;
out port direction = XS1_PORT_1B;

void main(){
	direction <: 1;
	pwm_output(speed, 50, 1000, 5000);
}

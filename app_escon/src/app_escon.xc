/*
 * Name: app_escon.xc
 * Author: John
 * Created on: 24/06/2013
 * Description:
 */

/*#include <platform.h>
out port bled = XS1_PORT_4C;

int main(){
	bled <: 0b0001;
	while (1){}
	return 0;
}*/

#include <platform.h>
#include <print.h>
#include "basic_utils.h"

out port left_speed = XS1_PORT_1A;
out port left_direction_CW = XS1_PORT_1B;
out port left_direction_CCW = XS1_PORT_1C;

out port right_speed = XS1_PORT_1D;
out port right_direction_CW = XS1_PORT_1E;
out port right_direction_CCW = XS1_PORT_1F;

out port CMP = XS1_PORT_1H;

int main(){
	/*left_direction_CW <: 1;
	right_direction_CW <: 1;
	pwm_output(left_speed, 40, 100, 10000);*/

	while(1)
	{
		log(CMP, debug, "Main", "Ohai!");
	}
	return 0;
}

/*
 * Name: basic_utils.h
 * Author: John
 * Created on: 24/06/2013
 * Description:
 */

#ifndef BASIC_UTILS_H_
#define BASIC_UTILS_H_

enum LOG_LEVEL
{
	debug,
	info,
	warning,
	error,
	severe,
	fatal
};

void pwm_output(out port output, int duty, int frequency, int period);
void wait(int ms);
void uart_tx(out port TXD, int byte, int baudrate);
void uart_tx_string(out port TXD, char data[], int baudrate);
int get_string_size(char string_pointer[]);
void reverse_string(char string_pointer[]);
int string_to_int(char str[]);
void int_to_string(int integer, char string_pointer[]);
void log(out port TX, enum LOG_LEVEL level, char tag[], char data[]);


#endif /* BASIC_UTILS_H_ */

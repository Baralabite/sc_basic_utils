/*
 * Name: basic_utils.xc
 * Author: John
 * Created on: 22/06/2013
 * Description: File including
 *   basic utilities, such as wait().
 */

#include <platform.h>
#include <print.h>
#include "stdio.h"

const int BRATE = 19200;

/*
 * Timing
 * Time Unit Conversion
 * String Handling
 * Basic Bitbanging
 * Type Conversions
 * Logging
 * Util
 */

//==========[ Timing ]==========//
/*
 * Contains basic timing functions
 * such as waits.
 */

const int CLOCK_FREQUENCY = 100000000;

/**
 * Name: wait
 * Parameters:
 *   - int ms: Milliseconds
 * Returns: void
 * Description: Waits X milliseconds
*/
void wait(int ms)
{
	timer tmr;
	unsigned int count;
	tmr :> count;
	count += CLOCK_FREQUENCY/(1000/ms);
	tmr when timerafter (count) :> void;
	return;
}

/**
 * Name: waitMicro
 * Parameters:
 *   - int us: Microseconds
 * Returns: void
 * Description: Waits X microseconds
*/
void waitMicro(int us)
{
	timer tmr;
	unsigned int count;
	tmr :> count;
	count += CLOCK_FREQUENCY/(1000000/us);
	tmr when timerafter (count) :> void;
	return;
}

/**
 * Name: get_clock_frequency
 * Returns: int, clock frequency
*/
int get_clock_frequency()
{
	return CLOCK_FREQUENCY;
}

/**
 * Name: calculate_bit_time
 * Parameters:
 *   - int baudrate: Baudrate
 * Returns: int, bit time
 * Description: Returns the bit
 *   time for a specific baudrate
 *   considering the current clock frequency.
 */
int calculate_bit_time(int baudrate)
{
	return get_clock_frequency() / baudrate;
}

//==========[ Time Unit Conversion ]==========//
/** Block Documentation
 * Name: Time Conversions
 * Parameters:
 *   - int <unit>: Time to be converted
 * Returns: int, converted time unit
 * Description: Converts time from one unit to another
 * Glossary:
 *  - CC: Clock Cycles
 *  - US: Microseconds
 *  - MS: Microseconds
 *  -  S: Seconds
 *  -  M: Minutes
*/

int cc_to_us(int clock_cycles)
{
	return clock_cycles/100;
}

int us_to_cc(int us)
{
	return us*100;
}

int us_to_ms(int us)
{
	return us/1000;
}

int ms_to_us(int ms)
{
	return ms*1000;
}

int ms_to_s(int ms)
{
	return ms/1000;
}

int s_to_ms(int s)
{
	return s*1000;
}

int s_to_m(int s)
{
	return s/60;
}

int m_to_s(int m)
{
	return m*60;
}

//==========[ String Handling ]==========//

/**
 * Name: clear_string
 * Parameters:
 *   - char[] string_pointer - Pointer of
 *       string to clear
 * Description: Clears the inputted string,
 * aka changes it to all null characters
*/
void clear_string(char string_pointer[])
{
	int i = 0;
	while(string_pointer[i] != '\0')
	{
		string_pointer[i] = '\0';
		i++;
	}
}

/**
 * Name: get_string_size
 * Parameters:
 *   - char[] string_pointer - String to find size of
 * Returns: int
 * Description: Returns the size of the inputted
 * string, aka, the number of bytes before it hits
 * a null character.
*/
int get_string_size(char string_pointer[])
{
	int cnt = 0;
	while(string_pointer[cnt] != 0)
	{
		cnt++;
	}
	return cnt;
}

/**
 * Name: append_string
 * Parameters:
 *   - char[] first - First string to append
 *   - char[] second - Second string to append
 *   - char[] result - Result of the first two
 *       added together
 * Description: Appends one string to another
*/
void append_string(char first[], char second[], char result[])
{
	//int size = get_string_size(first)+get_string_size(second);
	sprintf(result, "%s%s", first, second);
	//snprintf - TODO: Test this
}

/**
 * Name: clone_string
 * Parameters:
 *   - char[] input - Input string
 *   - char[] output - Output string
 * Description: clones one char array
 * to another
*/
void clone_string(char input[], char output[])
{
	clear_string(output);
	for(int x = 0; x<get_string_size(input); x++)
	{
		output[x] = input[x];
	}
}

/**
 * Name: reverse_string
 * Parameters:
 *   - char[[] string_pointer - Pointer to string
 * Description: Reverses string: "G'day" -> "yad'G"
*/
void reverse_string(char string_pointer[])
{
	int len = get_string_size(string_pointer);
	char tmp[10];
	clone_string(string_pointer, tmp);
	clear_string(string_pointer);
	for(int x=len; x>0; x--)
	{
		string_pointer[len-x] = tmp[x-1];
	}
}

//==========[ Basic Bitbanging ]===========//
/*
 * In this section, I have some basic
 * functions for UART, I2C, and PWM
 * comms.
 */

/**
 * Name: uart_tx
 * Parameters:
 *   - out port TXD: Port to transmit on
 *   - int byte: Byte to transmit
 *   - int baudrate; Baudrate to send at
 * Description: Transmits a byte using the UART
 *   protocol
*/
void uart_tx(out port TXD, int byte, int baudrate)
{
	int bit_time = calculate_bit_time(baudrate);
	unsigned time;
	timer t;
	t :> time;

	/* Output Start Bit */
	TXD <:0;
	time += bit_time;
	t when timerafter(time) :> void;

	/* Output Byte */
	for (int i=0; i<8; i++)
	{
		TXD <: >> byte;
		time += bit_time;
		t when timerafter(time) :> void;
	}

	/* Output Stop Bit */
	TXD <: 1;
	time += bit_time;
	t when timerafter(time) :> void;
}

/**
 * Name: uart_tx_string
 * Parameters:
 *   - out port TXD: Port to transmit on
 *   - char[] data: Bytes to transmit
 *   - int baudrate; Baudrate to send at
 * Description: Transmits a char arrayusing
 *   the UART protocol
*/
void uart_tx_string(out port TXD, char data[], int baudrate)
{
	int bit_time = calculate_bit_time(baudrate);
	unsigned time;
	timer t;
	int length = get_string_size(data);
	t :> time;

	for (int x=0; x<length; x++)
	{
		int byte = data[x];
		/* Output Start Bit */
		TXD <:0;
		time += bit_time;
		t when timerafter(time) :> void;

		/* Output Byte */
		for (int i=0; i<8; i++)
		{
			TXD <: >> byte;
			time += bit_time;
			t when timerafter(time) :> void;
		}

		/* Output Stop Bit */
		TXD <: 1;
		time += bit_time;
		t when timerafter(time) :> void;
	}
}

/**
 * Name: uart_rx
 * Parameters:
 *   - in port RXD: Port to recieve on
 *   - int baudrate; Baudrate to recieve at
 * Returns: int, byte recieved
 * Description: Recieves a byte using the UART
 *   protocol
*/
int uart_rx(in port RXD, int baudrate)
{
	int bit_time = calculate_bit_time(baudrate);
	unsigned byte, time;
	timer t;

	/* Wait for start bit */
	RXD when pinseq(0) :> void;
	t :> time;
	time += bit_time/2;

	/* Input data bits */
	for (int i=0; i<8; i++)
	{
		time += bit_time;
		t when timerafter(time) :> void;
		RXD :> >> byte;
	}

	/* Input stop bit */
	time += bit_time;
	t when timerafter(time) :> void;
	RXD :> void;

	byte = byte >> 24;
	return byte;
}

/**
 * Name: pwm_output
 * Parameters:
 *   - out port output: Pin in which to output the PWM
 *   - int duty: Duty Cycle, expressed as percentage
 *   - int frequency: Frequency to PWM at, expressed in Hz
 *   - int period: Time to PWM for in ms
 * Description: PWMs a pin for a duration
 */
void pwm_output(out port output, int duty, int frequency, int period)
{
	int cycle_length = 1000000 / frequency;
	int duty_pulse_length = cycle_length / (100.0/duty);
	for (int x = 0; x < 100000000000000; x++)
	{
		output <: 1;
		waitMicro(duty_pulse_length);
		output <: 0;
		waitMicro(cycle_length-duty_pulse_length);
	}
}

//TODO: get_pwm_duty_cycle
//TODO: get_pwm_frequency
//TODO: get_average_voltage

//TODO: Insert I2C output
//TODO: Insert I2C input

//==========[ Type Conversions ]==========//

/**
 * Name: int_to_string
 * Parameters:
 *   - int integer - Integer to be converted
 *   - char[] string_pointer - String for
 *       int to be put into
 * Description: Converts int to str
*/
void int_to_string(int integer, char string_pointer[])
{
	sprintf(string_pointer, "%d", integer);
}

/**
 * Name: str_to_int
 * Parameters:
 *   - char[] str - String to be converted
 * Returns: int
 * Description: String to integer
*/
int string_to_int(char str[])
{
	int output = 0;
	int count = 1;
	const int ascii_zero = 48;
	int string_size = get_string_size(str);
	reverse_string(str);

	for(int x=0; x<string_size; x++)
	{
		int ascii = (int)str[x];
		int i = ascii-ascii_zero;
		output = output + count*i;
		if (count == 1)
		{
			count = 10;
		}
		else
		{
			count = count * 10;
		}
	}
	return output;
}

//==========[ Logging ]==========//

enum LOG_LEVEL
{
	debug,
	info,
	warning,
	error,
	severe,
	fatal
} LOG_LEVEL;

//TODO: Create Communicator "class"
void log(out port TX, enum LOG_LEVEL level, char tag[], char data[])
{
	char result[256];
	char tmp[256];
	if (level==debug)
	{
		append_string("[DEBUG][", tag, result);
		append_string(result, "] ", tmp);
		clear_string(result);
		append_string(tmp, data, result);
		uart_tx_string(TX, result, BRATE);
		uart_tx(TX, 13, BRATE);
	}
	else if(level==info)
	{
		printstrln("Info time!");
	}
	else if(level==warning)
	{

	}
	else if(level==error)
	{
		printstrln("Error time!");
	}
	else if(level==severe)
	{

	}
	else if(level==fatal)
	{

	}
}

//==========[ Util ]==========//

void reset_chip()
{
	unsigned x;
	read_sswitch_reg(get_core_id(), 6, x);
	write_sswitch_reg(get_core_id(), 6, x);
}

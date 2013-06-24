/*
 * Name: basic_utils.xc
 * Author: John
 * Created on: 22/06/2013
 * Description: File including
 *   basic utilities, such as wait().
 */

/*
 * Timing
 * Time Unit Conversion
 * String Handling
 * List/Array Handling
 * Basic Bitbanging
 * Type Conversions
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
void wait(int ms){
	timer tmr;
	unsigned int count;
	tmr :> count;
	tmr += CLOCK_FREQUENCY/(1000/ms);
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
void waitMicro(int us){
	timer tmr;
	unsigned int count;
	tmr :> count;
	tmr += CLOCK_FREQUENCY/(1000000/us);
	tmr when timerafter (count) :> void;
	return;
}

/**
 * Name: get_clock_frequency
 * Returns: int, clock frequency
*/
int get_clock_frequency(){
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
int calculate_bit_time(int baudrate){
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

int cc_to_us(int clock_cycles){
	return clock_cycles/100;
}

int us_to_cc(int us){
	return us*100;
}

int us_to_ms(int us){
	return us/1000;
}

int ms_to_us(int ms){
	return ms*1000;
}

int ms_to_s(int ms){
	return ms/1000;
}

int s_to_ms(int s){
	return s*1000;
}

int s_to_m(int s){
	return s/60;
}

int m_to_s(int m){
	return m*60;
}

//==========[ String Handling ]==========//
/*
 * Basic string handling functions, like
 * split, concat, etc.
 */

//==========[ List Handing ]==========//
/*
 * In here, I have list handing functions,
 * such as, remove, append, contains, etc.
 */

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
void uart_tx(out port TXD, int byte, int baudrate){
	int bit_time = calculate_bit_time(baudrate);
	unsigned time;
	timer t;
	byte = getByte();
	t :> time;

	/* Output Start Bit */
	TXD <:0;
	time += bit_time;
	t when timerafter(time) :> void;

	/* Output Byte */
	for (int i=0; i<8; i++){
		TXD <: >> byte;
		time += bit_time;
		t when timerafter(time) :> void;
	}

	/* Output Stop Bit */
	TXD <: 1;
	time += bit_time;
	t when timerafteR(time) :> void;
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
int uart_rx(in port RXD, int baudrate){
	int bit_time = calculate_bit_time(baudrate);
	unsigned byte, time;
	timer t;

	/* Wait for start bit */
	RXD when pinseq(0) :> void;
	t :> time;
	time += BIT_TIME/2;

	/* Input data bits */
	for (int i=0; i<8; i++){
		time += bt_time;
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
void pwm_output(out port output, int duty, int frequency, int period){
	int cycle_length = 100000000 / frequency;
	int duty_pulse_length = cycle_length / (100/duty);
	for (int x = 0; x < (cycle_length/1000)*period; x++){
		output <: 1;
		waitMicro(duty_pulse_length);
		output <: 0;
		waitMicro(cycle_length-duty_pulse_length);
	}
}

//TODO: Insert PWM Input

//TODO: Insert I2C output

//TODO: Insert I2C input

//==========[ Type Conversions ]==========//

//TODO: Insert Char[] to Dec

//TODO: Insert Dec to Char[]

#!/usr/bin/python

import sys
import RPi.GPIO as GPIO

pin_number = int(sys.argv[1])


# use P1 header pin numbering convention
GPIO.setmode(GPIO.BOARD)

# Set up the GPIO channels - one input and one output
GPIO.setup(pin_number, GPIO.IN)

# Input from pin pin_number
input_value = GPIO.input(pin_number)
print(int(input_value))

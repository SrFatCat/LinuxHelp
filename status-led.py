#!/bin/python3

import time, tempfile, os
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BOARD)
GPIO.setup(15, GPIO.OUT)

p = GPIO.PWM(15, 100)  # channel=12 frequency=50Hz
p.start(100)
#try:
isLED = False
isOk = True 
timeToCheck = time.time()
try:
    while True:
        if (time.time()-timeToCheck) >= 600:
            try:
                with tempfile.NamedTemporaryFile( delete = False) as tmp:
                    tmp.write(b"123")
                    tmp.close()
                with open(tmp.name) as tmp:
                    t = tmp.read()    
                    isOk = (t == "123")
                os.unlink(tmp.name)        
            except:
                isOk=False            
            timeToCheck = time.time()
        if isOk:
            if isLED:
                p.ChangeDutyCycle(100)
                time.sleep(3)
            else:
                p.ChangeDutyCycle(85)
                time.sleep(0.15)
            isLED = not isLED
        else:
            p.ChangeDutyCycle(100)
except KeyboardInterrupt:
    pass
p.stop()
GPIO.cleanup()

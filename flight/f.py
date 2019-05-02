#!/usr/bin/env python3

import time
'''
a-start = 0
a-cruise = 5000
a-max = 7000
s-start = 0
s-min = 90
s-cruise = 200
s-max = 250
p-start = 0
p-max = 100
'''
heading = 0 # north
desired_heading = 120 # east south east
altitude = 0 # sea level
departure_altitide = 3500
cleared_altitude = 8000
climb_rate_fpm = 1500
turn_rate_degrees_per_second = 5
nm = 6076
start_time = time.time()
actual_speed = 20
desired_speed = 250
speed_increase = 20
sleep = 1
a = 0

def climb (altitude, cleared_altitude):
    if altitude <= cleared_altitude:
        fps = (climb_rate_fpm/60)
        print("Climb Feet Per Second: ", fps)
        altitude = altitude + fps
    return altitude


while a < 30:
    a= a + 1
    print (a)

    if actual_speed < desired_speed:
        actual_speed = actual_speed + speed_increase
    if actual_speed > 100:
        altitude = climb(altitude, cleared_altitude)
        print("Current Altitude: ", altitude)
    '''if actual_speed > 100:
        if altitude > departure_altitude:
            turn_to_desired_heading'''


    elapsed_time = time.time() - start_time
    distance = actual_speed * elapsed_time
    distance_nm = distance/nm
    miles_per_minute = actual_speed/60

    print("Actual Speed: ", actual_speed)
    print("Distance Traveled (feet) : ", distance)
    print("Distance Traveled (nautical miles): ", distance_nm)
    print("Flight Time: ", elapsed_time)
    print("Miles Per Minute: ", miles_per_minute)

    seconds = time.time()
    '''print("Seconds since epoch =", seconds)'''
    time.sleep(sleep)

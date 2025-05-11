

# References

- [Adafruit Ultimate GPS Breakout](https://forums.freebsd.org/threads/how-to-gpsd-on-pi4.97674/)
- [Linux/FreeBSD + DTS overlay](https://mywushublog.com/2020/04/stratum-1-raspberry-pi-time-server/)
- [Comparison of NTP implementations](https://chrony-project.org/comparison.html)
-

# LEA-M8T - $29

- u-blox LEA-M8T on Huawei WD22UGRC module
- [eBay listing](https://www.ebay.com/itm/134243322249)
- Pins: 1 ANT 3V3, 2 3V3/VCC, 3 TXD, 4 NC, 5 RXD, 6 TP1/1PPS, 7 NC TP2, 8 GND
  
```sh
sysctl hw.usb.ucom.pps_mode=1
```

## Ideal for timing:

- u-blox with precise timing: NEO, ZED, LEA, or ends with T (see below)

- Easy to use w/PPS:
  - Uputronics GPS/RTC board for Pi (u-blox M8Q)
  - Adafruit Ultimate GPS HAT wRTC (MTK 3339)
    - [How to: gpsd on pi4 (freebsd)](https://forums.freebsd.org/threads/how-to-gpsd-on-pi4.97674/)
  - Navisys GR-801W (u-blox + Prolific Logic PL23203)

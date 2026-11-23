# Stock firmware dump (BIQU Magician, Smoothieware)

Captured 2026-11-22 over /dev/ttyUSB0 (CP210x) at **115200 baud**, jumper off, touchscreen unplugged. Read-only queries only (`version`, `M115`, `M503`, `M119`, `config-get`). Nothing was moved or heated.

## Firmware

- Smoothieware build `~11myvar2`, Apr 11 2018 10:18:36, MCU LPC1768, 100 MHz. UART0 baud 115200.
- `M503` begins `; No config override`: these are the built-in values. `M115` returns only `ok`.

## Pin map (from `config-get`)

Smoothie pin syntax: `!` inverts, `^` pull-up. Klipper equivalents in the last column are **inferences to verify on the printer**, not facts.

| Function | Smoothie | Klipper guess |
|---|---|---|
| Tower A (alpha / X, front-left) step / dir / en | `2.0` / `0.5!` / `0.4` | `P2.0` / `!P0.5` / `!P0.4` |
| Tower B (beta / Y, front-right) step / dir / en | `2.1` / `0.11!` / `0.10` | `P2.1` / `!P0.11` / `!P0.10` |
| Tower C (gamma / Z, back) step / dir / en | `2.2` / `0.20!` / `0.19` | `P2.2` / `!P0.20` / `!P0.19` |
| Extruder step / dir / en | `2.3` / `0.22!` / `0.21` | `P2.3` / `!P0.22` / `!P0.21` |
| Endstops A / B / C (max, home upward) | `1.25^` / `1.27^` / `1.29^` | `^P1.25` / `^P1.27` / `^P1.29` |
| Hotend heater | `2.7` | `P2.7` |
| Hotend thermistor | `0.24`, `EPCOS100K` | `P0.24`, `EPCOS 100K B57560G104F` |
| Fan output (**all three fans**, M106/M107, PWM) | `2.4` | `P2.4` |
| Probe | `1.28!^` | `^!P1.28` (no switch fitted) |

Notes on the inferences:
- Smoothie's `en_pin` without `!` drives the pin low to enable, so Klipper probably needs `!`. Direction is the same idea; the real check is `FORCE_MOVE` on each tower.
- `M119` read all three endstops as `0` at rest, so triggered is probably high. Confirm with `QUERY_ENDSTOPS` while pressing each switch.
- There is no bed heater or bed thermistor (`temperature_control.bed` not in config).
- Driver currents read 0.8 A in the config, but the stepper drivers are soldered and the LPC doesn't set them, so it doesn't matter for Klipper.

## Motion and geometry

- Steps/mm: X/Y/Z 100, E 395. Delta: arm length 146.03, radius 61.7, max Z 150, trims 0/0/0.
- Homing: all three `home_to_max`, fast 100 mm/s, slow 20 mm/s, retract 5 mm.
- Acceleration 3000, junction deviation 0.05, max feedrate 120 mm/s, default feed 2400 mm/min.
- Hotend PID: P22.2 I1.08 D114. Extruder retract S3 F2700.
- Probe offsets: `M565 X0 Y0 Z-0.1`.

## Raw output

```
# raw dump 2026-11-22 20:41:49 port=/dev/ttyUSB0 baud=115200
## boot banner
Smoothie Running @100MHz
Build version: ~11myvar2, Build date: Apr 11 2018 10:18:36, MCU: LPC1768, System Clock: 100MHz
5 axis
NOTE: One extruder configured and enabled
NOTE: 1 extruders enabled out of 1
Watchdog enabled for 10.000000 seconds
## version
Build version: ~11myvar2, Build date: Apr 11 2018 10:18:36, MCU: LPC1768, System Clock: 100MHz
5 axis
## M115
ok
## M503
; No config override
;Steps per unit:
M92 X100.00000 Y100.00000 Z100.00000
;Acceleration mm/sec^2:
M204 S3000.00000
;X- Junction Deviation, Z- Z junction deviation, S - Minimum Planner speed mm/sec:
M205 X0.05000 Z-1.00000 S0.00000
;Max cartesian feedrates in mm/sec:
M203 X120.00000 Y120.00000 Z120.00000
;Max actuator feedrates in mm/sec:
M203.1 X120.00000 Y120.00000 Z120.00000
;Optional arm solution specific settings:
M665 L146.0300 R61.7000
;WCS settings
G54
;Home offset (mm):
M206 X0.00 Y0.00 Z0.00
;Trim (mm):
M666 X0.000 Y0.000 Z0.000
;Max Z
M665 Z150.000
;E Steps per mm:
M92 E395.0000 P57988
;E Filament diameter:
M200 D0.0000 P57988
;E retract length, feedrate:
M207 S3.0000 F2700.0000 Z0.0000 Q6000.0000 P57988
;E retract recover length, feedrate:
M208 S0.0000 F480.0000 P57988
;E acceleration mm/sec²:
M204 E500.0000 P57988
;E max feed rate mm/sec:
M203 E80.0000 P57988
;PID settings:
M301 S0 P22.2000 I1.0800 D114.0000 X255.0000 Y255
;Max temperature setting:
M143 S0 P300.0000
;Probe feedrates Slow/fast(K)/Return (mm/sec) max_z (mm) height (mm):
M670 S15.00 K50.00 R0.00 Z150.00 H10.00
;Probe points:
M557 P0 X0.00000 Y40.00000
M557 P1 X35.00000 Y-20.00000
M557 P2 X-35.00000 Y-20.00000
;Probe offsets:
M565 X0.00000 Y0.00000 Z-0.10000

ok
## M119
X_max:0 Y_max:0 Z_max:0 pins- (X)P1.25:0 (Y)P1.27:0 (Z)P1.29:0  Probe: 0
ok
## config-get
> config-get alpha_step_pin
  cached: alpha_step_pin is set to 2.0
> config-get alpha_dir_pin
  cached: alpha_dir_pin is set to 0.5!
> config-get alpha_en_pin
  cached: alpha_en_pin is set to 0.4
> config-get alpha_steps_per_mm
  cached: alpha_steps_per_mm is set to 100
> config-get beta_step_pin
  cached: beta_step_pin is set to 2.1
> config-get beta_dir_pin
  cached: beta_dir_pin is set to 0.11!
> config-get beta_en_pin
  cached: beta_en_pin is set to 0.10
> config-get beta_steps_per_mm
  cached: beta_steps_per_mm is set to 100
> config-get gamma_step_pin
  cached: gamma_step_pin is set to 2.2
> config-get gamma_dir_pin
  cached: gamma_dir_pin is set to 0.20!
> config-get gamma_en_pin
  cached: gamma_en_pin is set to 0.19
> config-get gamma_steps_per_mm
  cached: gamma_steps_per_mm is set to 100
> config-get delta_step_pin
  cached: delta_step_pin is not in config
> config-get delta_dir_pin
  cached: delta_dir_pin is not in config
> config-get delta_en_pin
  cached: delta_en_pin is not in config
> config-get delta_steps_per_mm
  cached: delta_steps_per_mm is not in config
> config-get alpha_min_endstop
  cached: alpha_min_endstop is not in config
> config-get alpha_max_endstop
  cached: alpha_max_endstop is set to 1.25^
> config-get alpha_homing_direction
  cached: alpha_homing_direction is set to home_to_max
> config-get alpha_fast_homing_rate_mm_s
  cached: alpha_fast_homing_rate_mm_s is set to 100
> config-get alpha_slow_homing_rate_mm_s
  cached: alpha_slow_homing_rate_mm_s is set to 20
> config-get alpha_homing_retract_mm
  cached: alpha_homing_retract_mm is set to 5
> config-get alpha_max_rate_mm_s
  cached: alpha_max_rate_mm_s is not in config
> config-get alpha_current
  cached: alpha_current is set to 0.8
> config-get beta_min_endstop
  cached: beta_min_endstop is not in config
> config-get beta_max_endstop
  cached: beta_max_endstop is set to 1.27^
> config-get beta_homing_direction
  cached: beta_homing_direction is set to home_to_max
> config-get beta_fast_homing_rate_mm_s
  cached: beta_fast_homing_rate_mm_s is set to 100
> config-get beta_slow_homing_rate_mm_s
  cached: beta_slow_homing_rate_mm_s is set to 20
> config-get beta_homing_retract_mm
  cached: beta_homing_retract_mm is set to 5
> config-get beta_max_rate_mm_s
  cached: beta_max_rate_mm_s is not in config
> config-get beta_current
  cached: beta_current is set to 0.8
> config-get gamma_min_endstop
  cached: gamma_min_endstop is not in config
> config-get gamma_max_endstop
  cached: gamma_max_endstop is set to 1.29^
> config-get gamma_homing_direction
  cached: gamma_homing_direction is set to home_to_max
> config-get gamma_fast_homing_rate_mm_s
  cached: gamma_fast_homing_rate_mm_s is set to 100
> config-get gamma_slow_homing_rate_mm_s
  cached: gamma_slow_homing_rate_mm_s is set to 20
> config-get gamma_homing_retract_mm
  cached: gamma_homing_retract_mm is set to 5
> config-get gamma_max_rate_mm_s
  cached: gamma_max_rate_mm_s is not in config
> config-get gamma_current
  cached: gamma_current is set to 0.8
> config-get arm_length
  cached: arm_length is set to 146.03
> config-get arm_radius
  cached: arm_radius is set to 61.70
> config-get delta_current
  cached: delta_current is set to 0.8
> config-get default_feed_rate
  cached: default_feed_rate is set to 2400
> config-get acceleration
  cached: acceleration is set to 3000
> config-get junction_deviation
  cached: junction_deviation is set to 0.05
> config-get planner_queue_size
  cached: planner_queue_size is not in config
> config-get microseconds_per_step_pulse
  cached: microseconds_per_step_pulse is not in config
> config-get base_stepping_frequency
  cached: base_stepping_frequency is not in config
> config-get alpha_max_travel
  cached: alpha_max_travel is set to 1000
> config-get gamma_max_travel
  cached: gamma_max_travel is set to 1000
> config-get temperature_control.hotend.enable
  cached: temperature_control.hotend.enable is set to true
> config-get temperature_control.hotend.thermistor_pin
  cached: temperature_control.hotend.thermistor_pin is set to 0.24
> config-get temperature_control.hotend.heater_pin
  cached: temperature_control.hotend.heater_pin is set to 2.7
> config-get temperature_control.hotend.thermistor
  cached: temperature_control.hotend.thermistor is set to EPCOS100K
> config-get temperature_control.hotend.designator
  cached: temperature_control.hotend.designator is set to T
> config-get temperature_control.hotend.set_m_code
  cached: temperature_control.hotend.set_m_code is set to 104
> config-get temperature_control.hotend.p_factor
  cached: temperature_control.hotend.p_factor is set to 22.2
> config-get temperature_control.hotend.i_factor
  cached: temperature_control.hotend.i_factor is set to 1.08
> config-get temperature_control.hotend.d_factor
  cached: temperature_control.hotend.d_factor is set to 114
> config-get temperature_control.hotend.max_temp
  cached: temperature_control.hotend.max_temp is not in config
> config-get temperature_control.hotend.max_pwm
  cached: temperature_control.hotend.max_pwm is not in config
> config-get temperature_control.hotend.pwm_frequency
  cached: temperature_control.hotend.pwm_frequency is not in config
> config-get temperature_control.bed.enable
  cached: temperature_control.bed.enable is not in config
> config-get temperature_control.bed.thermistor_pin
  cached: temperature_control.bed.thermistor_pin is not in config
> config-get temperature_control.bed.heater_pin
  cached: temperature_control.bed.heater_pin is not in config
> config-get switch.fan.enable
  cached: switch.fan.enable is set to true
> config-get switch.fan.input_on_command
  cached: switch.fan.input_on_command is set to M106
> config-get switch.fan.input_off_command
  cached: switch.fan.input_off_command is set to M107
> config-get switch.fan.output_pin
  cached: switch.fan.output_pin is set to 2.4
> config-get switch.fan.output_type
  cached: switch.fan.output_type is set to pwm
> config-get switch.fan.max_pwm
  cached: switch.fan.max_pwm is set to 255
> config-get switch.misc.enable
  cached: switch.misc.enable is not in config
> config-get switch.misc.output_pin
  cached: switch.misc.output_pin is not in config
> config-get zprobe.enable
  cached: zprobe.enable is set to true
> config-get zprobe.probe_pin
  cached: zprobe.probe_pin is set to 1.28!^
> config-get zprobe.slow_feedrate
  cached: zprobe.slow_feedrate is set to 15
> config-get endstops.enable
  cached: endstops.enable is not in config
> config-get extruder.hotend.enable
  cached: extruder.hotend.enable is set to true
> config-get extruder.hotend.steps_per_mm
  cached: extruder.hotend.steps_per_mm is set to 395
> config-get extruder.hotend.step_pin
  cached: extruder.hotend.step_pin is set to 2.3
> config-get extruder.hotend.dir_pin
  cached: extruder.hotend.dir_pin is set to 0.22!
> config-get extruder.hotend.en_pin
  cached: extruder.hotend.en_pin is set to 0.21
> config-get panel.enable
  cached: panel.enable is not in config
> config-get uart0.baud_rate
  cached: uart0.baud_rate is set to 115200
> config-get second_usb_serial_enable
  cached: second_usb_serial_enable is not in config
> config-get leds_disable
  cached: leds_disable is not in config
> config-get kill_button_enable
  cached: kill_button_enable is not in config
> config-get play_led_disable
  cached: play_led_disable is not in config
> config-get msd_disable
  cached: msd_disable is not in config
> config-get main_button_enable
  cached: main_button_enable is not in config
```

; This file is part of the repo rhythmic-sync-osc-csound (Rhythmic Synchronization of Events based on OSC Data from an External Source)
; @author: Øyvind Brandtsegg
; @contact: obrandts@gmail.com
; @license: GPL
<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>

<CsInstruments>
sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

gihandle OSCinit 9999 ; set the network port number where we will receive OSC data from Python

; play melody with note data from Python
; Rhythmic synchronization is ensured by using a master clock (timeinsts), and scheduling events with the appropriate delay
instr 31
  ivoice = p4 ; use separate voice numbers for polyphonic operation
  iamp = p5 ; basic amplitude
  ibasenote = p6 ; the base note number (melody intervals are calculated based on this pitch)
  itempo_bpm = p7 ; the tempo in beats per minute
  itempo_bps = itempo_bpm/60 ; calculate tempo as beats per second
  itempofactor = p8 ; adjust the tempo in relation to the bpm (for example x2, x4, etc)
  itempo = itempo_bps*itempofactor ; calculate the real tempo we will be using

  ; initialize variables that will be used in the communication with Python
  kindex init 0 ; the index counts the events generated for this voice
  kdelta_time init 0 ; delta time is the relative time until the next event (in seconds)
  knext_event_time init 0 ; absolute time for next event (seconds)
  kduration init 1 ; the duration for the next event
  knote init 0 ; the note nummber for the next event
  ktime timeinsts ; read the system clock (time since start ofthis instrument)
  ievent_trig_lag_time = .1 ; we add some latency to allow for OSC communication jitter

  ; request data from Python
  kget_event = (ktime > knext_event_time) ? 1 : 0 ; if current time is greater than the time for the next event, then activate
  if kget_event > 0 then
    OSCsend kindex+1, "127.0.0.1",9901, "/csound_send", "iifi",ivoice, kindex, itempo, ibasenote ; send OSC request to Python, get data for next event
  endif
  
  ; receive data from Python
  Saddress sprintf "/csound_receive_voice%i", ivoice ; we will use separate OSC address for each voice, so we need to format the string with the voice number
  nextmsg: 
  kmessage OSClisten gihandle, Saddress, "ifff",  kindex, kdelta_time, knote, kduration ; receive OSC data from Python, the data for the next event

  ; process data from Python to make Csound instrument events
  if kmessage == 0 goto done
    kevent_time_delay = (knext_event_time-ktime) + ievent_trig_lag_time ; calculate the delay that will enable accurate sync for this event
    if (kevent_time_delay < 0) then ; if the delay is less than zero, something is wrong, so we will want to be warned
      Swarning sprintfk "Warning : event overflow in voice %i at time %f", ivoice, ktime ; format the warning text string
      puts Swarning, ktime ; print warning string
      kevent_time_delay = 0
    endif
    event "i", 51, kevent_time_delay, kduration, iamp, knote ; trigger the instrument event based on the data we got from Python
    knext_event_time += kdelta_time ; update the next event time, ready for the next event
    kgoto nextmsg ; jump back to the OSC listen line, to see if there are more messages waiting in the network buffer
  done: 
endin

; sine tone instr 
instr 51
  iamp = ampdbfs(p4)
  inote = p5
  aenv madsr 0.001, 0.2, 0.2, 0.01
  a1 poscil aenv*iamp, cpsmidinn(inote)
  outs a1, a1
endin


</CsInstruments>
<CsScore>
;  start  dur  voice   amp    base    tempo   tempofactor 
i31 0     30   1       -12     60      60      1
i31 2     28   2       -12     48      60      4
i31 3     26   3       -22     84      60      6
i31 16    14   4       -22     96      60      8

f0 31
e
</CsScore>
</CsoundSynthesizer>

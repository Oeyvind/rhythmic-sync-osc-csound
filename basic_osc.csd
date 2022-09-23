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
instr 31
  iamp = p4 ; basic amplitude
  ibasenote = p5 ; the base note number 
  itempo_bpm = p6 ; the tempo in beats per minute
  ifreq = itempo_bpm/60 ; frequency of the metronome
  idur = (1/ifreq)*0.5 ; duration of the note events

  ; initialize variables that will be used in the communication with Python
  kindex init 0
  knote init 0 ; note (pitch) data coming from Python

  ; request data from Python
  ktrig metro ifreq
  if ktrig > 0 then
    OSCsend kindex+1, "127.0.0.1",9901, "/csound_send", "ii", kindex, ibasenote
    kindex += 1
  endif

  ; receive and process data from Python
  nextmsg: 
  kmessage OSClisten gihandle, "csound_receive", "f", knote ; receive OSC data from Python, the data for the next event
  if kmessage == 0 goto done
    event "i", 51, 0, idur, iamp, knote ; trigger the instrument event based on the data we got from Python
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
;  start  dur  amp   basenote  tempo 
i31 0     10   -9    60        60
i31 10    10   -9    60        240

e
</CsScore>
</CsoundSynthesizer>

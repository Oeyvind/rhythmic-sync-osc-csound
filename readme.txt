Csound and Python scripts Rhythmic Synchronization of Events based on OSC Data from an External Source
Accompanying code for the paper with the same name.
Øyvind Brandtsegg - 2022, obrandts@gmail.com

The file osc_io.py is just a module for OSC setup  used by the other scripts. It is not intended to be run as main, even if no harm will come from doing so.

Intended usage:

Csound will run the timing and audio synthesis, while Python provides the data for each event generated. Csound and Python communicates via Open Sound Control. To run, open two terminal windows (yes, two).
In the first one, run
python precise_timing.py
In the second one, run
csound precise_timing.csd

The first process now runs a Python OSC server waiting for calls from Csound, asking for the data for the next event. When data is returned from Python, Csound will generate the event. The delta time until the next event is part of the event data, so Csound will then wait until it is time to ask Python for the next event data.

Even if it is possible to combine Csound and Python processes rather freely (as the data interface is compatible), I have made some variations that are intended to be used together. For example the basic_osc.csd Csound script is intended to be used with the basic_osc.py Python script, similarly with serial_composition.csd/serial_composition.py and serial_vst.csd/serial_vst.py.

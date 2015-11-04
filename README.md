## DNMKIT

[![Build Status](https://travis-ci.org/jsbean/DNMKit.svg)](https://travis-ci.org/jsbean/DNMKit)

Work-in-progress.

Underlying framework for **DNM (Dynamic Notation for Music)**.

It includes several subframeworks:

* **DNMUtility**: Basic helper functions and variables
* **DNMModel**: Model of music
* **DNMView**: Graphical representation of the musical model
* **DNMUI**: Interaction elements
* **DNMJSON**: Wrapper for [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) with DNM-specific funcionality (on the way)
* **DNMAudio**: Wrapper for [The Amazing Audio Engine](https://github.com/TheAmazingAudioEngine/TheAmazingAudioEngine) to provide:
    * Sample-accurate timing of events in playback scenarios
    * Audio playback of pitches
    * and so on
* **DNMOSC** Wrapper for [F53OSC](https://github.com/Figure53/F53OSC) to connect to:
    * pd / Max/MSP
    * Supercollider
    * QLab
    * and so on
* **DNMConverter**: Parsers and generators for various formats 
    * Currently only for DNMShorthand text input, later for:
        * JSON
        * MusicXML
        * Abjad
        * Bach
        * OpenMusic
        * PWGL
        * and so on




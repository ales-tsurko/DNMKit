## DNMKIT

[![Build Status](https://travis-ci.org/jsbean/DNMKit.svg)](https://travis-ci.org/jsbean/DNMKit)

Underlying framework for **DNM (Dynamic Notation for Music)**.

It includes several subframeworks:

* **DNMUtility**: Basic helper functions and variables
* **DNMModel**: Model of music
* **DNMView**: Graphical representation of the musical model
* **DNMUI**: Interaction elements
* **DNMJSON**: Wrapper for [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) with DNM-specific funcionality
* **DNMAudio**: Wrapper for [The Amazing Audio Engine](https://github.com/TheAmazingAudioEngine/TheAmazingAudioEngine) to provide:
    * Sample-accurate timing of events in playback scenarios
    * Audio playback of pitches
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




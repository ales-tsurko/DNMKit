## DNMKIT

[![Build Status](https://travis-ci.org/jsbean/DNMKit.svg)](https://travis-ci.org/jsbean/DNMKit)

Work-in-progress.

iPad based music notation renderer.


#### Create a file

Use filename extension: ```.dnm``` 

Save anywhere in project (to be retrieved from ```NSBundle.mainBundle()```)

#### Text Input Format

* **Declare Performers** (humans doing things) with:    
    * Performer identifier (string, I've been using two uppercase letters)
    * ```1...n``` pairs of Instrument identifiers and InstrumentType
        * Instrument identifier (string, I've been using two lowercase letters)


#### Projects

* **DNMMODEL**: iOS / OSX framework that includes:
    * Model of music
    * Parser for DNMShorthand
    * [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) for JSON i/o
    

* **DNM_iOS**: iOS application for graphical representation of music

* **DNM Text Editor**: Simple text editor with text highlighting specific to DNMShorthand


#!/usr/bin/env python

from generators.Generator import Generator
import Command
import os
from os import path
import controllersConfig
import batoceraFiles
import codecs
import configparser
from utils.logger import get_logger

eslog = get_logger(__name__)

class mGBAGenerator(Generator):

    def generate(self, system, rom, playersControllers, guns, gameResolution):
        # Set up paths & files
        gbaMultiFiles = []
        romBasename = path.basename(rom)
        romTitle = path.splitext(romBasename)[0]
        savePath = f'{batoceraFiles.SAVES}/mgba'
        cheatPath = '/userdata/cheats/mgba'
        cheatFile = f'{cheatPath}/{romTitle}.cht'
        configPath = f'{batoceraFiles.CONF}/mgba'
        iniFile = f'{configPath}/mgba.ini'
        qtFile = f'{configPath}/qt.ini'

        # Populate BIOS (optional)
        biosList = {}
        for bios in [ 'gb', 'gbc', 'sgb', 'gba' ]
            if path.exists(f'{batoceraFiles.BIOS}/{bios}_bios.bin'):
                biosList[bios] = f'{batoceraFiles.BIOS}/{bios}_bios.bin'
            else:
                biosList[bios] = ''

        # Verify paths
        if not os.path.exists(savePath):
            os.mkdir(savePath)
        if not os.path.exists(cheatPath):
            os.mkdir(cheatPath)
        if not os.path.exists(configPath):
            os.makedirs(configPath)
        
        # Multi or single player?
        if system.name in [ 'gbamulti', 'gbc2players', 'gb2players' ]:
            if system.isOptSet('playerCount'):
                playerCount = system.config['playerCount']
            else:
                if system.name == 'gbamulti':
                    playerCount = 4
                else:
                    playerCount = 2
        else:
            playerCount = 1

        # We don't want more players than controllers (ie auto start 4 player games in 2-3 player depending on connected controllers)
        # Drop to single instance mode if only 1 controller is connected.
        if playerCount > len(playersControllers):
            playerCount = len(playersControllers)

        # Fill in the file list if it's in multiplayer using the same cartridge
        if playerCount > 1 and len(gbaMultiFiles == 0):
            gbaMultiFiles = [ rom ]

        for player in range(1, playerCount + 1):
            if player == 1:
                createIniFile(iniFile, playersControllers, player, savePath. biosList)
            else:
                createIniFile(f'{iniFile}-p{str(player)}', playersControllers, player, savePath. biosList)

        # TO-DO:
        # Ini file (single player)
        # Ini file(s) (multi player)
        # Multi launch

        if playerCount > 1:
            # Insert multi player launch code here. Tag in return command or add a script to batocera-scripts.
        else:
            # Set up command line
            commandArray  = [ '/usr/bin/mgba', rom ]
            commandArray += [ '-f' ]
            commandArray += [ '-c', cheatFile ]
            return Command.Command(array=commandArray, \
                env={ "XDG_CONFIG_HOME":batoceraFiles.CONF, \
                "XDG_DATA_HOME":batoceraFiles.SAVES, \
                "QT_QPA_PLATFORM":"xcb"})

    def getMouseMode(self, config):
        # Debugging - we want the mouse enabled until I get ini settings done.
        # After, only enable when e-Reader is active.
        return True

def createIniFile(iniFile, playersControllers, playerNum, savePath, biosList):
    mgbaConfig = configparser.RawConfigParser(strict=False)
    mgbaConfig.optionxform=str             # Add Case Sensitive comportement
    if os.path.exists(iniFile):
        os.remove(iniFile)          # Force removing qt-config.ini
        mgbaConfig.read(iniFile)


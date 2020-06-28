#!/bin/bash
#
# Uses bash_ini_parser by rudimeier.
#
# https://github.com/rudimeier/bash_ini_parser
#
source	"read_ini.sh"



##################################################################
# Colour constants.
##################################################################

# Reset
Colour_Off='\033[0m'      # Text Reset

# Regular Colours
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White



##################################################################
# Utility functions.
##################################################################

# Usage:	_exit_error	Exit_Code	Message_To_display
#
_exit_error() {
	local	_EXIT_CODE

	_EXIT_CODE="$1"

	shift

	echo -e "${BWhite}${On_Red}[ FATAL ]   ${FUNCNAME[1]} : Line ${BASH_LINENO[0]} : Exit ${_EXIT_CODE} - ${*}${Colour_Off}"

	exit "${_EXIT_CODE}"
}



_display_ok() {
	echo -e "${Black}${On_Green}[ OK ]${Colour_Off}"
}



# Prompts the user to enter Yes or No and returns 1 if YES else 0 if NO.
#
# Usage: _get_yes_no <Optional prompt>
#
_get_yes_no() {
	local	_PROMPT
	local	_RESPONSE

	if [ "$1" ]; then
		_PROMPT="$1"
	else
		_PROMPT="Are you sure"
	fi

	_PROMPT="${_PROMPT} [y/n] ?"

	# Loop forever until the user enters a valid response (Y/N or Yes/No).
	while true; do
		read -r -p "$(echo -e "${BWhite}${_PROMPT}${Colour_Off}") " _RESPONSE

		case "${_RESPONSE}" in
			[Yy][Ee][Ss]|[Yy])	# Yes or Y (case-insensitive)
				return 1
				;;
			[Nn][Oo]|[Nn])		# No or N (case-insensitive)
				return 0
				;;
			*)			# Anything else including a blank is invalid
				;;
		esac
	done
}



##################################################################
# Check for the web server root command line argument.
##################################################################

if [ 1 -ne "$#" ]; then
	_exit_error 1 "\nMust have the location of the radio recorder web root.\n\teg   ${0} /home/pi/RadioRecorder"
fi



##################################################################
# Check to see if we can find the web server files.
##################################################################

readonly	RADIORECORDER_DIR="${1}"

# If the directory does not exist.
if [[ ! -d "${RADIORECORDER_DIR}" ]]; then
	_exit_error 2 "Cannot find directory: ${RADIORECORDER_DIR}"
fi



##################################################################
#
##################################################################

# For some reason '_get_yes_no()' changes the working directory.
# In fact, any function call will changes the working directory.
# WHY? WHY? WHY? WHY? WHY?
#
# This is a hack...
pushd "." > /dev/null				# Save the current directory on the stack and change to "."

# Returns 1 if YES else 0 if NO.
_get_yes_no "Import moOde radio stations"

RV="${?}"

# This is a hack...
popd > /dev/null				# Restore the save directory from the stack.

if [[ 0 -eq "${RV}" ]]; then
	# No
	echo -e "${BYellow}Aborted...${Colour_Off}"

	exit 3
fi

echo ""
echo "-------------------------------------------------------------------------------------------------"
echo ""



##################################################################
# Read '/etc/mpd.conf' and look at what 'music_directory' points to.
##################################################################

echo "Looking in '/etc/mpd.conf' for the music directory."

# Usually /var/lib/mpd/music
MPD_MUSIC_DIR=""

# Read the file in row mode and extract each line.
while IFS= read -r LINE; do
	# music_directory	"/var/lib/mpd/music"
	_KEY=${LINE% *}
	_VALUE=${LINE##* }

	if [ "${_KEY}" == "music_directory" ]; then
		# Remove the " character from the start and end of the value token.
		_VALUE=${_VALUE#\"}
		_VALUE=${_VALUE%\"}

		# Returns: /var/lib/mpd/music
		MPD_MUSIC_DIR="${_VALUE}"

		echo "Got: ${MPD_MUSIC_DIR}"

		break
	fi
done < "/etc/mpd.conf"

if [[ -z "${MPD_MUSIC_DIR}" ]]; then
	_exit_error 4 "Cannot find 'music_directory' entry in '/etc/mpd.conf'"
fi

# If the directory does not exist.
if [[ ! -d "${MPD_MUSIC_DIR}" ]]; then
	_exit_error 5 "Cannot find directory: ${MPD_MUSIC_DIR}"
fi

_display_ok



##################################################################
# Import moOdes radio stations.
##################################################################

readonly	RADIO_STREAMS="${RADIORECORDER_DIR}/res/streams.txt"

# Ensure we can write to the file.
chmod 755 "${RADIO_STREAMS}"

echo "// Lines with starting '//' are not interpreted
Lines without a semicolon will be ignored, too
//Therefore empty lines can be used to get a better overview in this file
// IMPORTANT: Don't use streams using windows media format ('mms://', 'wma', ...)
// because underlying streamripper can not handle windows media formats.
// Radiorecorder will not check for this. Illegal streams will cause an error
// at the sheduled starttime. This error will not be displayed in any Radiorecorder log
// or on the web interface!
// it is also possible to add streamripper parameter to a specific station

for STATION in "${MPD_MUSIC_DIR}/RADIO/"*.pls; do
	echo "Importing: ${STATION}"		# Zen FM.pls

	# /var/lib/mpd/music/RADIO/Zen\ FM.pls
	#
	# [playlist]
	# File1=http://lb.zenfm.be/zenfm.mp3
	# Title1=Zen FM
	# NumberOfEntries=1
	# Length1=-1
	# Version=2

	read_ini "${STATION}" playlist

	# echo "number of sections: ${INI__NUMSECTIONS}"

	# INI__playlist__File1=http://lb.zenfm.be/zenfm.mp3
	# INI__playlist__Length1=-1
	# INI__playlist__Length2=-1
	# INI__playlist__NumberOfEntries=1
	# INI__playlist__Title1='Zen FM'
	# INI__playlist__Version=2

	if [ -n "$INI__playlist__Title1" ]; then
		if [ -n "$INI__playlist__File1" ]; then
			echo "Title: $INI__playlist__Title1"
			echo "Stream: $INI__playlist__File1"
			echo ""

			# Places the recording in the 'Recordings' directory as '${INI__playlist__Title1"} - 2020_06_26_22_11_00.mp3'.
			echo "${INI__playlist__Title1} - One track;${INI__playlist__File1};-u \"FreeAmp/2.x\" -A -a \"%S - %d\" -k 0 -o always" >> "${RADIO_STREAMS}"

			echo "${INI__playlist__Title1} - Rip tracks;${INI__playlist__File1};-u \"FreeAmp/2.x\" -D \"%A - %T\" -k 0 -o always" >> "${RADIO_STREAMS}"
		fi
	fi
done

chmod 755 "${RADIO_STREAMS}"

_display_ok

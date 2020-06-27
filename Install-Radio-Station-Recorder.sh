#!/bin/bash
#
# Install the radio staion recorder software for 'moOde'.
#
##################################################################
##################################################################
##################################################################
#
# Do not change anything from here on.
#
##################################################################
##################################################################
##################################################################
#
# (c) 2020 - TheMetalHead - https://github.com/TheMetalHead/moOde-radio-station-recorder
#
# TheMetalHead/moOde-CD-Rip-and-Play is licensed under the GNU General Public License v3.0
#
# Permissions of this strong copyleft license are conditioned on making available complete
# source code of licensed works and modifications, which include larger works using a
# licensed work, under the same license. Copyright and license notices must be preserved.
# Contributors provide an express grant of patent rights.
#
# A copy of the license can be found in: LICENSE
#
#
# Permissions:
#	Commercial use
#	Modification
#	Distribution
#	Patent use
#	Private use
#
# Limitations:
#	Liability
#	Warranty
#
# Conditions:
#	License and copyright notice
#	State changes
#	Disclose source
#	Same license

##################################################################
# Work out this files name, path and config pathname.
##################################################################

# Returns full path and name of this script.
# /home/pi/Src/RadioRecorder/Install-Radio-Station-Recorder.sh
readonly	FULLPATHNAME=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo "$0")

# The directory where this script resides.
# /home/pi/Src/RadioRecorder
readonly	DIRECTORY=$(dirname "${FULLPATHNAME}")

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

# This is used to suppress all text output.
#
# Returns 0 on success else 1 on error.
#
_cd_func() {
	# If argument supplied.
	if [[ -n "${1}" ]]; then
		# Suppress all text output.
		cd "${1}" 2>&1 && return 0
	fi

	return 1
}



_display_ok() {
	echo -e "${Black}${On_Green}[ OK ]${Colour_Off}"
}



# Usage:	_exit_error	Exit_Code	Message_To_display
#
_exit_error() {
	local	_EXIT_CODE

	_EXIT_CODE="$1"

	shift

	echo -e "${BWhite}${On_Red}[ FATAL ]   ${FUNCNAME[1]} : Line ${BASH_LINENO[0]} : Exit ${_EXIT_CODE} - ${*}${Colour_Off}"

	exit "${_EXIT_CODE}"
}



# Tests for a non zero result code and outputs to the log file and exits.
# It outputs the function name, line number, message and command result code.
#
# Usage:	_check_command_and_exit_if_error	Last_Result_Code	Exit_Code	Message_To_Display
#
_check_command_and_exit_if_error() {
	local	_LAST_RESULT

	_LAST_RESULT="$1"

	if [ 0 -ne "${_LAST_RESULT}" ]; then
		local	_EXIT_CODE

		_EXIT_CODE="$2"

		shift
		shift

		echo -e "${BWhite}${On_Red}[ FATAL ]   ${FUNCNAME[1]} : Line ${BASH_LINENO[0]} : Exit ${_EXIT_CODE} - Command returned error code: ${_LAST_RESULT} - ${*}${Colour_Off}"

		exit "${_EXIT_CODE}"
	fi
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
##################################################################
##################################################################
#
# The start of the installation program.
#
##################################################################
##################################################################
##################################################################

# Ensure we are root. If not, restart it.
#
if [[ 0 != "$EUID" ]]; then
	# Restart the script as root.
	sudo "$0" "$@"

	exit "${?}"
fi

# We are root.



HILITE="${BCyan}"

echo ""
echo -e "Install the cd ripper software from files in this directory for use with ${HILITE}'moOde'${Colour_Off}."

if [ ! -f "/var/www/command/moode.php" ]; then
	echo ""
	echo -e "${BYellow}This is not a 'moOde' installation.${Colour_Off}"
	echo ""
	echo -e "${BYellow}Aborted...${Colour_Off}"

	exit 6
fi



# Save our current directory.
OLD_DIR=$(pwd)

# Change to the directory where this script is located.
_cd_func "${DIRECTORY}"

# This should never happen.
_check_command_and_exit_if_error "${?}" 7 "Cannot change directory to: ${DIRECTORY}"



##################################################################
# Output some details.
##################################################################

if [[ "${*}" ]]; then
	echo "args -> ${*}"

	_exit_error 8 "Arguments are not required: ${*}"
fi

echo ""
echo "Ensure that the configuration file is correct for your requirements."
echo ""
echo -e "Reading the configuration file: ${HILITE}${DIRECTORY}/${CDRIP_CONFIG}${Colour_Off}"
echo ""
echo -e "Found CDROM drive:       ${HILITE}${CDROM}${Colour_Off}"
echo ""
echo -e "Music home path:         ${HILITE}${MUSIC_HOME_PATH}${Colour_Off}"		# Do not add any trailing slashes. Full path
echo -e "Ripped music dir:        ${HILITE}${RIPPED_MUSIC_DIR}${Colour_Off}"		# Do not add any leading/trailing slashes
echo -e "Ripped music sub dir:    ${HILITE}${MUSIC_SUB_DIR}${Colour_Off}"
echo ""
echo -e "Owner:                   ${HILITE}${RIPPED_MUSIC_OWNER}${Colour_Off}"		# WARNING: The owner existance is not checked
echo -e "Saved playlist name:     ${HILITE}${DEFAULT_SAVED_USER_PLAYLIST}${DEFAULT_SAVED_USER_PLAYLIST_EXTENSION}${Colour_Off}"
echo -e "Default volume:          ${HILITE}${DEFAULT_VOLUME}${Colour_Off}"		# Default 'moOde' volume
echo -e "Library name in 'moOde': ${HILITE}${LIBRARY_TAG}${Colour_Off}"
echo ""
echo -e "Music storage path:      ${HILITE}${MUSIC_HOME_PATH}/${RIPPED_MUSIC_DIR}/${MUSIC_SUB_DIR}${Colour_Off}"

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
_get_yes_no "Continue"

RV="${?}"

# This is a hack...
popd > /dev/null				# Restore the save directory from the stack.

if [[ 0 -eq "${RV}" ]]; then
	# No
	echo -e "${BYellow}Aborted...${Colour_Off}"

	exit 10
fi

echo ""
echo "-------------------------------------------------------------------------------------------------"



##################################################################
# Install the required programs.
##################################################################

echo "Checking for the required programs."

MISSING_PROGRAMS=()

for CMD in "streamripper" "at"
do
	# Check if the command exists and is executable.
	CMD_TO_CHECK=$(command -v "${CMD}")

	# If the command is not found, add it to the missing list to install later on.
	if [ -z "${CMD_TO_CHECK}" ]; then
			MISSING_PROGRAMS+=("${CMD}")
		fi
	fi
done

if [[ -n "${MISSING_PROGRAMS[*]}" ]]; then
	echo "The following programs need to be installed: ${MISSING_PROGRAMS[*]}"
	echo "Updating the package repository."

	apt update

	_check_command_and_exit_if_error "${?}" 15 "Apt package repository update failed."

	echo "Installing the missing programs."

	apt install "${MISSING_PROGRAMS[@]}"

	_check_command_and_exit_if_error "${?}" 16 "Installation of missing programs failed."
fi

_display_ok



##################################################################
# Read '/etc/mpd.conf' and look at what 'music_directory' points to.
##################################################################

echo "Looking in '/etc/mpd.conf' for the music directory."

MPD_MUSIC_DIR=""

# Read the file in row mode and extract each line.
while IFS= read -r LINE; do
	#  music_directory      "/var/lib/mpd/music"
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
	_exit_error 17 "Cannot find 'music_directory' entry in '/etc/mpd.conf'"
fi

# If the directory does not exist.
if [[ ! -d "${MPD_MUSIC_DIR}" ]]; then
	_exit_error 18 "Cannot find directory: ${MPD_MUSIC_DIR}"
fi

_display_ok



##################################################################
# Create the web server directory if required.
##################################################################

# /home/pi/Music-CD
RADIORECORDER_DIR="RadioRecorder"

WEB_SERVER_DIR="${MUSIC_HOME_PATH}/${RADIORECORDER_DIR}"

echo "Checking for the web server directory: ${WEB_SERVER_DIR}"

# If the directory does not exist.
if [[ ! -d "${WEB_SERVER_DIR}" ]]; then
	echo "Creating the web server directory: ${WEB_SERVER_DIR}"

	mkdir "${WEB_SERVER_DIR}"

	_check_command_and_exit_if_error "${?}" 19 "Cannot make directory: ${WEB_SERVER_DIR}"

	chown "${RIPPED_MUSIC_OWNER}" "${WEB_SERVER_DIR}"

	_check_command_and_exit_if_error "${?}" 20 "Cannot change owner for: ${WEB_SERVER_DIR}"

	# If the directory still does not exist.
	if [[ ! -d "${WEB_SERVER_DIR}" ]]; then
		_exit_error 25 "Cannot find directory: ${WEB_SERVER_DIR}"
	fi
fi

_display_ok



##################################################################
# Create a symbolic link to the mount point directory.
##################################################################

# /var/lib/mpd/music
echo "Changing directory to: ${MPD_MUSIC_DIR}"

# cd "${MPD_MUSIC_DIR}"
_cd_func "${MPD_MUSIC_DIR}"

_check_command_and_exit_if_error "${?}" 32 "Cannot change directory to: ${MPD_MUSIC_DIR}"

echo "Checking for link: ${LIBRARY_TAG} to: ${MNT_CD}"

# /mnt/${MUSIC_MNT_SOURCE}
# /mnt/CD
#
# If the symbolic link does not exist.
#if [[ ! -h "${LIBRARY_TAG}" ]]; then
if [[ ! -L "${LIBRARY_TAG}" ]]; then
	echo "Creating link: '${LIBRARY_TAG}' to: '${MNT_CD}'"

	ln -s "${MNT_CD}" "${LIBRARY_TAG}"

	_check_command_and_exit_if_error "${?}" 33 "Cannot create link to: ${MNT_CD}"
fi

_display_ok



##################################################################
# Check for access to the music directory.
##################################################################

# If the directory where the ripped CD files will be stored cannot be accessed.

# /var/lib/mpd/music/CD
RIPPING_DIR="${MPD_MUSIC_DIR}/${LIBRARY_TAG}"

echo "Checking for: ${RIPPING_DIR}"

# /var/lib/mpd/music/CD
if [[ ! -d "${RIPPING_DIR}" ]]; then
	_exit_error 34 "Cannot find directory: ${RIPPING_DIR}"
fi

_display_ok



##################################################################
# Tell mpd about the new cd music directory.
##################################################################

echo "Updating mpd with the new music directory: ${LIBRARY_TAG}"
echo ""

mpc update

_check_command_and_exit_if_error "${?}" 44 "Cannot get mpd to update the music directory: ${LIBRARY_TAG}"



##################################################################
# All done.
##################################################################

echo ""
echo -e "${Black}${On_Green}SUCCESS:${Colour_Off} CD ripper/player for ${HILITE}'moOde'${Colour_Off} installed ok."
echo -e "${HILITE}'moOde'${Colour_Off} can be accessed on ip address: ${HILITE}$(hostname -I)${Colour_Off}"

exit 0








##################################################################


Make a directory for the radio recorder in the pi home directory.

	mkdir RadioRecorder

	cd RadioRecorder

Download the files:

	wget https://sourceforge.net/projects/radiorecwebgui/files/latest/download -O RadioRecorder.tar.gz

Extract:
	tar -x -f RadioRecorder.tar.gz

Remove the downloaded file:
	rm RadioRecorder.tar.gz

Get the full working directory of the radio recorder and note this for the next step:

	pwd

Configure the radio recorder:

	nano res/settings.php

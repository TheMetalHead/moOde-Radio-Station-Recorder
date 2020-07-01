#!/bin/bash
#
# Install the radio staion recorder software for 'moOde'.
#
# Usage:      Install-Radio-Station-Recorder.sh   Web-server-root-directory   Web-server-port   Recordings-Storage-Root-Directory   Recordings-Directory
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
# (c) 2020 - TheMetalHead - https://github.com/TheMetalHead/moOde-Radio-Station-Recorder
#
# TheMetalHead/moOde-Radio-Station-Recorder is licensed under the GNU General Public License v3.0
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

# Returns the full path and name of this script.
# /home/pi/Src/moOde-Radio-Station-Recorder/Install-Radio-Station-Recorder.sh
readonly	FULLPATHNAME=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo "$0")

# The directory where this script resides.
# /home/pi/Src/moOde-Radio-Station-Recorder
readonly	DIRECTORY=$(dirname "${FULLPATHNAME}")

readonly	RADIO_RECORDER_DIR="RadioRecorder"

readonly	WEB_SERVER_IP=$(hostname -I)

readonly	OWNER="pi:pi"

readonly	DOWNLOAD_RADIO_REC_WEB_GUI="https://sourceforge.net/projects/radiorecwebgui/files/latest/download"

##################################################################
# Colour constants.
##################################################################

# Reset
readonly	Colour_Off='\033[0m'      # Text Reset

# Regular Colours
readonly	Black='\033[0;30m'        # Black
readonly	Red='\033[0;31m'          # Red
readonly	Green='\033[0;32m'        # Green
readonly	Yellow='\033[0;33m'       # Yellow
readonly	Blue='\033[0;34m'         # Blue
readonly	Purple='\033[0;35m'       # Purple
readonly	Cyan='\033[0;36m'         # Cyan
readonly	White='\033[0;37m'        # White

# Bold
readonly	BBlack='\033[1;30m'       # Black
readonly	BRed='\033[1;31m'         # Red
readonly	BGreen='\033[1;32m'       # Green
readonly	BYellow='\033[1;33m'      # Yellow
readonly	BBlue='\033[1;34m'        # Blue
readonly	BPurple='\033[1;35m'      # Purple
readonly	BCyan='\033[1;36m'        # Cyan
readonly	BWhite='\033[1;37m'       # White

# Underline
readonly	UBlack='\033[4;30m'       # Black
readonly	URed='\033[4;31m'         # Red
readonly	UGreen='\033[4;32m'       # Green
readonly	UYellow='\033[4;33m'      # Yellow
readonly	UBlue='\033[4;34m'        # Blue
readonly	UPurple='\033[4;35m'      # Purple
readonly	UCyan='\033[4;36m'        # Cyan
readonly	UWhite='\033[4;37m'       # White

# Background
readonly	On_Black='\033[40m'       # Black
readonly	On_Red='\033[41m'         # Red
readonly	On_Green='\033[42m'       # Green
readonly	On_Yellow='\033[43m'      # Yellow
readonly	On_Blue='\033[44m'        # Blue
readonly	On_Purple='\033[45m'      # Purple
readonly	On_Cyan='\033[46m'        # Cyan
readonly	On_White='\033[47m'       # White

# High Intensity
readonly	IBlack='\033[0;90m'       # Black
readonly	IRed='\033[0;91m'         # Red
readonly	IGreen='\033[0;92m'       # Green
readonly	IYellow='\033[0;93m'      # Yellow
readonly	IBlue='\033[0;94m'        # Blue
readonly	IPurple='\033[0;95m'      # Purple
readonly	ICyan='\033[0;96m'        # Cyan
readonly	IWhite='\033[0;97m'       # White

# Bold High Intensity
readonly	BIBlack='\033[1;90m'      # Black
readonly	BIRed='\033[1;91m'        # Red
readonly	BIGreen='\033[1;92m'      # Green
readonly	BIYellow='\033[1;93m'     # Yellow
readonly	BIBlue='\033[1;94m'       # Blue
readonly	BIPurple='\033[1;95m'     # Purple
readonly	BICyan='\033[1;96m'       # Cyan
readonly	BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
readonly	On_IBlack='\033[0;100m'   # Black
readonly	On_IRed='\033[0;101m'     # Red
readonly	On_IGreen='\033[0;102m'   # Green
readonly	On_IYellow='\033[0;103m'  # Yellow
readonly	On_IBlue='\033[0;104m'    # Blue
readonly	On_IPurple='\033[0;105m'  # Purple
readonly	On_ICyan='\033[0;106m'    # Cyan
readonly	On_IWhite='\033[0;107m'   # White

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



_remove_last_slash() {
	 echo "${1%/}"
}



# Remove leading and trailing spaces.
_trim_space() {
	echo $*
}



_exit_trap() {
#	cd "${OLD_DIR}"
	_cd_func "${OLD_DIR}"
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
echo -e "Install the radio station recording software for use with ${HILITE}'moOde'${Colour_Off}."

if [ ! -f "/var/www/command/moode.php" ]; then
	echo ""
	echo -e "${BYellow}This is not a 'moOde' installation.${Colour_Off}"
	echo ""
	echo -e "${BYellow}Aborted...${Colour_Off}"

	exit 1
fi



# Save our current directory.
OLD_DIR=$(pwd)

# Change to the directory where this script is located.
_cd_func "${DIRECTORY}"

# This should never happen.
_check_command_and_exit_if_error "${?}" 2 "Cannot change directory to: ${DIRECTORY}"



##################################################################
# Check for the command line arguments.
##################################################################

_IP=$(_trim_space "${WEB_SERVER_IP}")

if [ 4 -ne "$#" ]; then
	_exit_error 3 "
You must enter exactly 4 command line arguments:

Usage:\t\t${0}   Full-Path-To-Web-Server-Root-Directory   Web-Server-Port   Full-Path-To-Recordings-Storage-Root-Directory   Recordings-Directory

Example:\t${0} \"/home/pi\" 8088 \"/media/DA1A-71FE/Music\" \"Recordings\"

This will create the web server at      : /home/pi/${RADIO_RECORDER_DIR}
The recordings will be stored at        : /media/DA1A-71FE/Music/Recordings
The radio station scheduler accessed at : ${_IP}:8088"
fi



##################################################################
# Grab the command line arguments. There is no error checking.
##################################################################

WEB_SERVER_ROOT_DIR=$( _remove_last_slash "${1}" )
WEB_SERVER_PORT="$2"
RECORDINGS_STORAGE_ROOT_DIR=$( _remove_last_slash "${3}" )
RECORDINGS_DIR=$( _remove_last_slash "${4}" )



##################################################################
# Output some details for the user to manually check.
##################################################################

readonly	RADIO_RECORDER_WEB_SITE_DIR="${WEB_SERVER_ROOT_DIR}/${RADIO_RECORDER_DIR}"

echo ""
echo -e "Recordings storage directory:       ${HILITE}${RECORDINGS_STORAGE_ROOT_DIR}/${RECORDINGS_DIR}${Colour_Off}"
echo ""
echo -e "Radio scheduler web site directory: ${HILITE}${RADIO_RECORDER_WEB_SITE_DIR}${Colour_Off}"
echo ""
echo -e "Web server port:                    ${HILITE}${WEB_SERVER_PORT}${Colour_Off}"
echo ""
echo -e "Owner:                              ${HILITE}${OWNER}${Colour_Off}"	# WARNING: The owner existance is not checked
echo ""
echo -e "Library name in 'moOde':            ${HILITE}${RECORDINGS_DIR}${Colour_Off}"
echo ""



##################################################################
# Allow a change of mind.
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

	exit 4
fi

echo ""
echo "-------------------------------------------------------------------------------------------------"
echo ""



##################################################################
# Install our traps.
##################################################################

trap	_exit_trap	EXIT ERR SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM



##################################################################
# We can only have one instance of the php web server.
##################################################################

RC_LOCAL_FILE="/etc/rc.local"

echo "Checking if the php web server is installed in: '${RC_LOCAL_FILE}'"

grep -q "/usr/bin/php" "${RC_LOCAL_FILE}"

RV="${?}"

# 0 = Found.
# 1 = Not found.

if [ 0 -eq ${RV} ]; then
	# The php web server is already being used. Ensure the port used is the same.
	grep -q "/usr/bin/php\ -q\ -S\ ${_IP}:${WEB_SERVER_PORT}\ -t" "${RC_LOCAL_FILE}"

	RV="${?}"

	# 0 = Found.
	# 1 = Not found.

	if [ 0 -ne ${RV} ]; then
		_exit_error 5 "The php web server is already being used in: '${RC_LOCAL_FILE}' but the port is different from ours: '${WEB_SERVER_PORT}'"
	fi
else
	# The php web server is not being used so check if the port is free.
	echo "Checking if the web server port is free."

	nc -z "${_IP}" "${WEB_SERVER_PORT}" > /dev/null

	RV="${?}"

	# 0 = Not free.
	# 1 = Free.

	if [ 0 -eq ${RV} ]; then
		_exit_error 6 "The web server port (${WEB_SERVER_PORT}) is already being used: '${RC_LOCAL_FILE}'"
	fi
fi

_display_ok



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
done

if [[ -n "${MISSING_PROGRAMS[*]}" ]]; then
	echo "The following programs need to be installed: ${MISSING_PROGRAMS[*]}"
	echo "Updating the package repository."

	apt update

	_check_command_and_exit_if_error "${?}" 7 "Apt package repository update failed."

	echo "Installing the missing programs."

	apt install "${MISSING_PROGRAMS[@]}"

	_check_command_and_exit_if_error "${?}" 8 "Installation of missing programs failed."
fi

_display_ok



##################################################################
# Read '/etc/mpd.conf' and look at what 'music_directory' points to.
##################################################################

echo "Looking in '/etc/mpd.conf' for the music directory."

# Usually /var/lib/mpd/music
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
	_exit_error 9 "Cannot find 'music_directory' entry in '/etc/mpd.conf'"
fi

# If the directory does not exist.
if [[ ! -d "${MPD_MUSIC_DIR}" ]]; then
	_exit_error 10 "Cannot find directory: ${MPD_MUSIC_DIR}"
fi

_display_ok



##################################################################
# Create the web server directory if required.
##################################################################

echo "Checking for the web server directory: ${RADIO_RECORDER_WEB_SITE_DIR}"

# If the directory does not exist.
if [[ ! -d "${RADIO_RECORDER_WEB_SITE_DIR}" ]]; then
	echo "Creating the web server directory: ${RADIO_RECORDER_WEB_SITE_DIR}"

	mkdir "${RADIO_RECORDER_WEB_SITE_DIR}"

	_check_command_and_exit_if_error "${?}" 11 "Cannot make directory: ${RADIO_RECORDER_WEB_SITE_DIR}"

	# If the directory still does not exist.
	if [[ ! -d "${RADIO_RECORDER_WEB_SITE_DIR}" ]]; then
		_exit_error 12 "Cannot find directory: ${RADIO_RECORDER_WEB_SITE_DIR}"
	fi
fi

_display_ok



##################################################################
# Download and install the radio recorder web server files.
# WARNING: This will overwrite any existing radio recorder web server files.
##################################################################

echo "Changing directory to: ${RADIO_RECORDER_WEB_SITE_DIR}"

# cd "${RADIO_RECORDER_WEB_SITE_DIR}"
_cd_func "${RADIO_RECORDER_WEB_SITE_DIR}"

_check_command_and_exit_if_error "${?}" 13 "Cannot change directory to: ${RADIO_RECORDER_WEB_SITE_DIR}"

echo "Downloading the radio recorder gui file from: ${DOWNLOAD_RADIO_REC_WEB_GUI}"

wget "${DOWNLOAD_RADIO_REC_WEB_GUI}" -O "RadioRecorder.tar.gz"

_check_command_and_exit_if_error "${?}" 14 "Cannot download the file: ${DOWNLOAD_RADIO_REC_WEB_GUI}"

echo "Extracting the files:"

tar -x -f RadioRecorder.tar.gz

_check_command_and_exit_if_error "${?}" 15 "Cannot extract the file: RadioRecorder.tar.gz"

# Remove the downloaded file.

rm RadioRecorder.tar.gz

_display_ok



##################################################################
# Create the radio recorder settings file.
# WARNING: This will overwrite any existing radio recorder settings file.
##################################################################

echo "Creating the radio recorder settings file: '${RADIO_RECORDER_WEB_SITE_DIR}/res/settings.php'"

echo "<?php

class Settings {

  public static \$siteRoot = '${RADIO_RECORDER_WEB_SITE_DIR}';
  public static \$recordedFilesDestination = '${RECORDINGS_STORAGE_ROOT_DIR}/${RECORDINGS_DIR}/';
  public static \$language = 'en';					// Valid values are 'de', 'en', 'fr', 'sk'
  public static \$locale = 'C';						// Default is 'C'; other possible locales: 'de_AT.UTF-8' to enable all corresponding characters for the filename
  public static \$defaultStreamripperParams = '>/dev/null';		// Adds streamripper params to each call
  public static \$addDatePrefixToFilename = 'Y-m-d';			// Prefix format (e.g. 'Y-m-d') or null if no prefix to add
  public static \$postCommand = 'mpc update > /dev/null';		// Command to be executed after the recording is finished
  public static \$logThreshold = 1;					// Level of log messages, possible values : LEVEL_DEBUG=4, LEVEL_INFO=3, LEVEL_WARN=2, LEVEL_ERROR=1

}

?>" > res/settings.php

chown -R "${OWNER}" "${RADIO_RECORDER_WEB_SITE_DIR}"

_check_command_and_exit_if_error "${?}" 16 "Cannot change owner for: ${RADIO_RECORDER_WEB_SITE_DIR}"

_display_ok



##################################################################
# Checking if the recordings storage root directory can be accessed.
##################################################################

echo "Checking for access to the recordings storage root directory: ${RECORDINGS_STORAGE_ROOT_DIR}"

# If the directory does not exist.
if [[ ! -d "${RECORDINGS_STORAGE_ROOT_DIR}" ]]; then
		_exit_error 17 "Cannot find directory: ${RECORDINGS_STORAGE_ROOT_DIR}"
fi

_display_ok



##################################################################
# Create the recordings directory if required.
##################################################################

_RECORDINGS_DIR="${RECORDINGS_STORAGE_ROOT_DIR}/${RECORDINGS_DIR}"

echo "Checking for access to the recordings directory: ${_RECORDINGS_DIR}"

# If the directory does not exist.
if [[ ! -d "${_RECORDINGS_DIR}" ]]; then
	echo "Creating the recordings directory: ${_RECORDINGS_DIR}"

	mkdir "${_RECORDINGS_DIR}"

	_check_command_and_exit_if_error "${?}" 18 "Cannot make directory: ${_RECORDINGS_DIR}"

	chown "${OWNER}" "${_RECORDINGS_DIR}"

	_check_command_and_exit_if_error "${?}" 19 "Cannot change owner for: ${_RECORDINGS_DIR}"

	# If the directory still does not exist.
	if [[ ! -d "${_RECORDINGS_DIR}" ]]; then
		_exit_error 20 "Cannot find directory: ${_RECORDINGS_DIR}"
	fi
else
	echo "The recordings directory already exists. No changes have been made."
fi

_display_ok



##################################################################
# Create a symbolic link to the recordings directory.
##################################################################

# /var/lib/mpd/music
echo "Changing directory to: ${MPD_MUSIC_DIR}"

# cd "${MPD_MUSIC_DIR}"
_cd_func "${MPD_MUSIC_DIR}"

_check_command_and_exit_if_error "${?}" 21 "Cannot change directory to: ${MPD_MUSIC_DIR}"

echo "Checking for link: ${RECORDINGS_DIR} to: ${RECORDINGS_STORAGE_ROOT_DIR}/${RECORDINGS_DIR}"

# RECORDINGS_STORAGE_ROOT_DIR="/home/pi"
# RECORDINGS_DIR="Recordings"

# "${RECORDINGS_STORAGE_ROOT_DIR}/${RECORDINGS_DIR}"

# If the symbolic link does not exist.
#if [[ ! -h "${LIBRARY_TAG}" ]]; then
if [[ ! -L "${RECORDINGS_DIR}" ]]; then
	echo "Creating link: '${RECORDINGS_DIR}' to: '${RECORDINGS_STORAGE_ROOT_DIR}/${RECORDINGS_DIR}'"

	ln -s "${RECORDINGS_STORAGE_ROOT_DIR}/${RECORDINGS_DIR}" "${RECORDINGS_DIR}"

	_check_command_and_exit_if_error "${?}" 22 "Cannot create link to: ${RECORDINGS_STORAGE_ROOT_DIR}/${RECORDINGS_DIR}"
else
	echo "The link already exists. No changes have been made."
fi

echo "The link will appear in the moOde library panel as: '${RECORDINGS_DIR}'"

_display_ok



##################################################################
# Check for access to the recordings directory.
##################################################################

# If the directory where the recorded files will be stored cannot be accessed.

# /var/lib/mpd/music/Recordings
readonly	ACCESS_RECORDINGS_DIR="${MPD_MUSIC_DIR}/${RECORDINGS_DIR}"

echo "Checking for access to: ${ACCESS_RECORDINGS_DIR}"

# /var/lib/mpd/music/Recordings
if [[ ! -d "${ACCESS_RECORDINGS_DIR}" ]]; then
	_exit_error 23 "Cannot find directory: ${ACCESS_RECORDINGS_DIR}"
fi

_display_ok



##################################################################
# Tell mpd about the new recordings directory.
##################################################################

echo "Updating mpd with the recordings directory: ${RECORDINGS_DIR}"

mpc update > /dev/null

_check_command_and_exit_if_error "${?}" 24 "Cannot get mpd to update the music directory: ${RECORDINGS_DIR}"

_display_ok



##################################################################
# Add the web server start up command to '/etc/rc.local'.
##################################################################

echo "Checking for the web server start up command in: '${RC_LOCAL_FILE}'"

# Is the start up command not installed.
grep -q "/usr/bin/php" "${RC_LOCAL_FILE}"

RV="${?}"

# 0 = Found.
# 1 = Not found.

if [ 0 -ne ${RV} ]; then
	echo "Adding the web server start up command to: '${RC_LOCAL_FILE}'"

	# At the bottom and just before the last 'exit 0' statement add the following:

	# Delete the exit.
	sed -i '/exit.*/d' "${RC_LOCAL_FILE}"

	_check_command_and_exit_if_error "${?}" 25 "Cannot add the web server start up command in: '${RC_LOCAL_FILE}'"

	echo -e "# Start the radio recorder web server.
/usr/bin/php -q -S ${_IP}:${WEB_SERVER_PORT} -t ${RADIO_RECORDER_WEB_SITE_DIR} >/dev/null 2>&1

exit 0" >> "${RC_LOCAL_FILE}"

	_display_ok
else
	echo "The web server start up command has already been added to: '${RC_LOCAL_FILE}'"
fi



##################################################################
# Remove our traps.
##################################################################

trap	-	EXIT ERR SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM



##################################################################
# All done.
##################################################################

echo ""
echo -e "${Black}${On_Green}SUCCESS:${Colour_Off} The radio station recorder for ${HILITE}'moOde'${Colour_Off} has been installed ok."
echo ""
echo -e "The radio station recorder can be accessed on: ${HILITE}${_IP}:${WEB_SERVER_PORT}${Colour_Off}"
echo ""



# Change back to the directory where this script is located.
_cd_func "${DIRECTORY}"

"${DIRECTORY}"/Import-MoOde-Radio-Stations.sh "${RADIO_RECORDER_WEB_SITE_DIR}"



exit 0

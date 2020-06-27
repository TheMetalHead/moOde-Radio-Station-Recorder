# moode-radio-station-recorder

Instructions for a simple radio station recorder for moOde http://moodeaudio.org/.

It consists of a separate web server to schedule the recording of a radio station. This then updates moOde/mpd with the new recordings that appear in a directory called Recordings in the library. This has been tried on moOde versions 6.4.2 and 6.5.2

The following stream formats are supported by the stream ripper: mp3, nsv, aac, and ogg. I have only tried two formats, mp3 is ok, aac had audio interruptions.

The streamripper and radiorecorder software have been written by other people. Their links are given at the bottom.


As always, before installing I recommend that a backup is made of your moOde system. I will not be held responsible for any mistakes. That way if you do not like what you see, you can always go back to your old set up.

Drop into the command line in moOde using ssh. Use Putty or moOde Shellinabox.

Install the dependencies:

    sudo apt update
    sudo apt install streamripper at

Make a directory for the radio recorder in the pi home directory.

    mkdir RadioRecorder

    cd RadioRecorder

Download the file:

    wget https://sourceforge.net/projects/radiore...t/download -O RadioRecorder.tar.gz

Extract:

    tar -x -f RadioRecorder.tar.gz

Remove the downloaded file:

    rm RadioRecorder.tar.gz

Get the full working directory of the radio recorder and note this for the next step:

    pwd

Configure the radio recorder:

    nano res/settings.php

Change the following for your preferences:

    The full working directory of the radio recorder from 'pwd' in the previous step:
        $siteRoot = '/home/pi/RadioRecorder';

    The location of where to store the recordings. This will be different to your system. eg:
        $recordedFilesDestination = '/home/pi/Music/Recordings';

    Adds additional streamripper parameters to each call. This disables writing the stdout output to mail.
        $defaultStreamripperParams = '>/dev/null';

    Change the recording prefix from null to year, month, day:
        $addDatePrefixToFilename = 'Y-m-d';

    Command to be executed after the recording is finished. Here we just update mpd:
        $postCommand = 'mpc update > /dev/null';

    Change the log level to ERROR:
        $logThreshold = 1;

Exit nano.



Make a directory for the recordings in a suitable location. This will be used as the name that will appear in the moOde library panel:

eg    cd /home/pi/Music

    mkdir Recordings

Create a link for moOde to the new recordings directory:

    cd /var/lib/mpd/music

Create the link:

    sudo ln -s /home/pi/Music/Recordings

The link will appear in the moOde library panel as 'Recordings'.

Create a simple web server. Note this is not production grade and should not be visible on the internet:

    sudo nano /etc/rc.local

At the bottom and just before the 'exit 0' statement add the following:

    /usr/bin/php -q -S 192.168.1.123:8080 -t /home/pi/RadioRecorder >/dev/null 2>&1

Note: Change the ip address to your moOde ip address and ensure that the port is above 1024. In this case 8080.

Reboot moOde.



Access the web interface using:

    your-moode-ip:8080

Note: If you use the built in web interface playback function this uses local web browser audio player and not moOde. Also the built in web player cannot play aac files.



Example to rip as one track.

Create the stream to rip:

    Name of stream:                              RockRadio1 - One track
    Uniform Resource Locator (URL):    http://192.99.147.61:8000
    Additional Parameter:                       -k 0 -o always

You may need to add -u "FreeAmp/2.x" to the 'Additional Parameter' when creating the stream to rip.

The above places the recording in the 'Recordings' directory as '2020-06-26-09-06-00 name of recording.mp3'.



Other versions of 'Additional Parameter':

    -u "FreeAmp/2.x" -a -k 0 -o always

Places the recording in the 'Recordings/RockRadio1' directory as 'sr_program_2020_06_26_21_56_01.mp3'.



    -u "FreeAmp/2.x" -a -A -k 0 -o always

Places the recording in the 'Recordings/RockRadio1' directory as 'sr_program_2020_06_26_21_56_01.mp3'.



    -u "FreeAmp/2.x" -A -a "%S - %d" -k 0 -o always
    -u "FreeAmp/2.x" -a "%S - %d" -k 0 -o always

Places the recording in the 'Recordings' directory as 'RockRadio1 - 2020_06_26_22_11_00.mp3'.



Create the recording schedule:

    Stream:                RockRadio1 - One track
    Date:                    Set as required.
    Time:                    Set as required.
    Duration:              Set as required.
    Name of track:      Give it a suitable name. eg The Rock Show.
    Repeating:            Select the days to record from or leave blank for one day.
                                     eg tick Mon to record every monday.



Example to rip into individual tracks.

Create the stream to rip:

    Name of stream:                             RockRadio1 - Rip tracks
    Uniform Resource Locator (URL):   http://192.99.147.61:8000
    Additional Parameter:                        -D "%A - %T" -k 0 -o always



Create the schedule:

    Stream:                RockRadio1 - Rip tracks
    Date:                    Set as required.
    Time:                    Set as required.
    Duration:              Set as required.
    Name of track:      Leave as automatic track detection.
    Repeating:            Select the days to record from or leave blank for one day.
                                     eg tick Mon to record every monday.



'Additional Parameter' options:

-D %d
# Name files with date and time (per exec)
# If -D is used, the options -s and -P will be ignored.

    %S        Stream
    %A        Artist
    %T        Title
    %a        Album
    %D       Date and time (per song)
    %d        Date and time (per execution)
    %q        Sequence number (automatic detection)
    %Nq      Sequence number (starting from number N)
    %%       Percent sign

-a [pattern]
# Sometimes you want the stream recorded to a single (big) file
  without splitting into tracks. The -a option does this. If you use -a without
  including the [pattern], a timestamped filename will automatically be used.

-A
Don´t create individual tracks.
The default mode of operation is to create one file for each track.
But sometimes you don´t want these files.
Using the -A option, the individual files for each track are not created.

-u "FreeAmp/2.x"
# Some stream-servers will not accept the default Streamripper UserAgent,
  the solution is using this parameter with the value "FreeAmp/2.x".



To use via moOde:

    Go to the library panel.
    Select Recordings.



Info:

    https://sourceforge.net/projects/radiorecwebgui/
    http://streamripper.sourceforge.net/faq.php
    http://manpages.org/streamripper

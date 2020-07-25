# moOde-radio-station-recorder

Instructions for a simple radio station recorder for moOde http://moodeaudio.org/.

It consists of a separate web server to schedule the recording of a radio station. This then updates moOde/mpd with the new recordings that appear in a directory called Recordings in the library. This has been tried on moOde versions 6.4.2 onwards.

The following stream formats are supported by the stream ripper: mp3, nsv, aac, and ogg. I have only tried two formats, mp3 is ok, aac had audio interruptions. m3u8 streams are not supported.

The streamripper and radiorecorder software have been written by other people. Their links are given at the bottom.

There is a companion program called 'Import-MoOde-Radio-Stations.sh' that will import all stations into the radio recorder for you. This creates two entries per station. One to record it as one whole track, the other splits the recorded station into individual tracks. m3u8 streams are not supported and are filtered out.

# Installing:

As always, before installing it is recommend that a backup is made of your moOde system. I will not be held responsible for any mistakes. That way if you do not like what you see, you can always go back to your old set up.

Drop into the command line in moOde using ssh. Use Putty or moOde Shellinabox.

    git clone https://github.com/TheMetalHead/moOde-Radio-Station-Recorder.git
    cd moOde-Radio-Station-Recorder
    chmod 500 *.sh

To install into the home directory /home/pi/RadioRecorder using the recording directory of /media/DA1A-71FE/Recordings with the web server port of 8080 use:

    ./Install-Radio-Station-Recorder.sh ~ 8080 /media/DA1A-71FE Recordings

Reboot moOde.

Note: the directory /media/DA1A-71FE must already exist. In this case it is a mounted external usb drive.

# Usage:

Access the web interface using:

    your-moode-ip:8080

Note: If you use the built in web interface playback function this uses local web browser audio player and not moOde. Also the built in web player cannot play aac files.



Example to rip as one track.

Create the stream to rip:

    Name of stream:                    RockRadio1 - One track
    Uniform Resource Locator (URL):    http://192.99.147.61:8000
    Additional Parameter:              -k 0 -o always

You may need to add -u "FreeAmp/2.x" to the 'Additional Parameter' when creating the stream to rip.

The above places the recording in the 'Recordings' directory as '2020-06-26-09-06-00 name of track.mp3'.



Other versions of 'Additional Parameter':

    -u "FreeAmp/2.x" -a -k 0 -o always

Places the recording in the 'Recordings/RockRadio1' directory as 'sr_program_2020_06_26_21_56_01.mp3'.



    -u "FreeAmp/2.x" -a -A -k 0 -o always

Places the recording in the 'Recordings/RockRadio1' directory as 'sr_program_2020_06_26_21_56_01.mp3'.



    -u "FreeAmp/2.x" -A -a "%S - %d" -k 0 -o always
    -u "FreeAmp/2.x" -a "%S - %d" -k 0 -o always

Places the recording in the 'Recordings' directory as 'RockRadio1 - 2020_06_26_22_11_00.mp3'.



Create the recording schedule:

    Stream:                  RockRadio1 - One track
    Date:                    Set as required.
    Time:                    Set as required.
    Duration:                Set as required.
    Name of track:           Give it a suitable name. eg The Rock Show.
    Repeating:               Select the days to record from or leave blank for one day.
                               eg tick Mon to record every monday.



Example to rip into individual tracks.

Create the stream to rip:

    Name of stream:                   RockRadio1 - Rip tracks
    Uniform Resource Locator (URL):   http://192.99.147.61:8000
    Additional Parameter:             -D "%A - %T" -k 0 -o always



Create the schedule:

    Stream:                  RockRadio1 - Rip tracks
    Date:                    Set as required.
    Time:                    Set as required.
    Duration:                Set as required.
    Name of track:           Leave as automatic track detection.
    Repeating:               Select the days to record from or leave blank for one day.
                               eg tick Mon to record every monday.



'Additional Parameter' options:

-D %d
Name files with date and time (per exec). If -D is used, the options -s and -P will be ignored.

    %S        Stream
    %A        Artist
    %T        Title
    %a        Album
    %D        Date and time (per song)
    %d        Date and time (per execution)
    %q        Sequence number (automatic detection)
    %Nq       Sequence number (starting from number N)
    %%        Percent sign

-a [pattern]
  Sometimes you want the stream recorded to a single (big) file without splitting into tracks. The -a option does this. If you use -a without including the [pattern], a timestamped filename will automatically be used.

-A
Don´t create individual tracks. The default mode of operation is to create one file for each track. But sometimes you don´t want these files. Using the -A option, the individual files for each track are not created.

-u "FreeAmp/2.x"
  Some stream-servers will not accept the default Streamripper UserAgent, the solution is using this parameter with the value "FreeAmp/2.x".



# To access the saved recordings via moOde:

    Go to the library panel.
    Select Recordings.



# Additional info:

    https://sourceforge.net/projects/radiorecwebgui/
    http://streamripper.sourceforge.net/faq.php
    http://manpages.org/streamripper

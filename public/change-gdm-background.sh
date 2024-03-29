#!/usr/bin/env bash
# Autor: Thiago Silva
# Contact: thiagos.dasilva@gmail.com
# URL: https://github.com/thiggy01/change-gdm-background
# =================================================================== #

# Check if script is run by root.
if [ "$(id -u)" -ne 0 ] ; then
    echo 'This script must be run as root or with the sudo command.'
    exit 1
fi

# Check what linux distro is being used.
# distro="$(lsb_release -c | cut -f 2)"
# if ! [[ "$distro" =~ (focal|groovy|hirsute) ]]; then
#     echo 'Sorry, this script only works with focal, groovy or hirsute distros.'
#     exit 1
# fi

# Check if glib 2.0 development libraries are installed.
if [ ! -x "$(command -v glib-compile-resources)" ]; then
    echo 'Additional glib 2.0 libraries need to be installed.'
    read -p 'Type y or Y to proceed. Any other key to exit: ' -n 1
    if [[ "$REPLY" =~ ^[yY]$ ]]; then
	apt install libglib2.0-dev-bin
    else
	exit 1
    fi
fi

# Assign the default gdm theme file path.
if [ "$(lsb_release -i | awk '{print $3}')" == 'Ubuntu' ]; then
    gdm3Resource=/usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource
elif [ "$(lsb_release -i | awk '{print $3}')" == 'Pop' ]; then
    gdm3Resource=/usr/share/gnome-shell/theme/Pop/gnome-shell-theme.gresource
fi

# Create a backup file of the original theme if there isn't one.
[ ! -f "$gdm3Resource"~ ] && cp "$gdm3Resource" "$gdm3Resource~"

# Restore backup function.
restore () {
mv "$gdm3Resource~" "$gdm3Resource"
if [ "$?" -eq 0 ]; then
    chmod 644 "$gdm3Resource"
    echo 'GDM background sucessfully restored.'
    # read -p 'Do you want to restart gdm to apply change? (y/n):' -n 1
	# echo
	# if [[ "$REPLY" =~ ^[yY]$ ]]; then
	#     service gdm restart
	# else
	    echo 'Restart GDM service to apply change.'
	    exit 0
	# fi
fi
}

# Restore the original gdm3 theme.
[ "$1" == "--restore" ] && restore

#Define main variables.
gdm3xml=$(basename "$gdm3Resource").xml
workDir="/tmp/gdm3-theme"

# Create directories from resource list.
CreateDirs() {
for resource in `gresource list "$gdm3Resource~"`; do
    resource="${resource#\/org\/gnome\/shell\/}"
    if [ ! -d "$workDir"/"${resource%/*}" ]; then
      mkdir -p "$workDir"/"${resource%/*}"
    fi
done
}

# Extract resources from binary file.
ExtractRes() {
for resource in `gresource list "$gdm3Resource~"`; do
    gresource extract "$gdm3Resource~" "$resource" > \
    "$workDir"/"${resource#\/org\/gnome\/shell\/}"
done
}

# Compile resources into a gresource binary file.
CompileRes() {
glib-compile-resources --sourcedir=$workDir/theme/ $workDir/theme/"$gdm3xml"
}

# Moves the newly created resource to its default place.
MoveRes() {
mv $workDir/theme/gnome-shell-theme.gresource $gdm3Resource
}

# Check if gresource was sucessfuly moved to its default folder.
Check() {
if [ "$?" -eq 0 ]; then
# Solve a permission change issue (thanks to @huepf from github).
    chmod 644 "$gdm3Resource"
    echo 'GDM background successfully changed.' # Typo here on official repo (successfuly) : has to be changed
    # read -p 'Do you want to restart gdm to apply change? (y/n):' -n 1
#    echo
    # If change was successful apply ask for gdm restart.
    # if [[ "$REPLY" =~ ^[yY]$ ]]; then
	# service gdm restart
    # else
	# echo "Change will be applied only after restarting gdm"
	# echo
    # fi
else
    # If something went wrong, restore backup file.
    echo 'something went wrong.'
    restore
    echo 'No changes were applied.'
fi
}

CleanUp() {
    # Remove temporary directories and files.
    rm -r "$workDir"
    exit 0
}

# Test if argument is an image file.
if [[ $(file --mime-type -b "$1") == image/*g ]]; then

    # Define image variables.
    gdmBgImg=$(realpath "$1")
    imgFile=$(basename "$gdmBgImg")

    # Call procedures to create directories and extract resources to them.
    CreateDirs
    ExtractRes

    # Copy selected image to the resources directory.
    cp "$gdmBgImg" "$workDir"/theme

    # Change gdm background to the image you submited.
    oldBg="#lockDialogGroup \{.*?\}"
    newBg="#lockDialogGroup {
	background: url('resource:\/\/\/org\/gnome\/shell\/theme\/$imgFile');
	background-size: cover; }"
    perl -i -0777 -pe "s/$oldBg/$newBg/s" "$workDir"/theme/gdm.css

    # Generate gresource xml file.
    echo '<?xml version="1.0" encoding="UTF-8"?>
<gresources>
    <gresource prefix="/org/gnome/shell/theme">' > "$workDir"/theme/"$gdm3xml"
    for file in `gresource list "$gdm3Resource~"`; do
	echo "        <file>${file#\/org\/gnome/shell\/theme\/}</file>" \
	>> "$workDir"/theme/"$gdm3xml"
    done
    echo "        <file>$imgFile</file>" >> "$workDir"/theme/"$gdm3xml"
    echo '    </gresource>
</gresources>' >> "$workDir"/theme/"$gdm3xml"

    # Compile the new gresource.
    CompileRes

    # Move gresource to the default place.
    MoveRes

    # Check if everything was successful.
    Check

    # Remove temporary files and exit.
    CleanUp

# Change background colors.
elif [[ "$1" =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]]; then

    # Store selected background color.
    BgColor="$1"

    CreateDirs
    ExtractRes

    # Change gdm background to the color you submited.
    oldBg="#lockDialogGroup \{.*?\}"
    newBg="#lockDialogGroup {
	background: $BgColor;
	background-size: cover; }"
    perl -i -0777 -pe "s/$oldBg/$newBg/s" "$workDir"/theme/gdm.css

    # Generate the gresource xml file.
    echo '<?xml version="1.0" encoding="UTF-8"?>
<gresources>
    <gresource prefix="/org/gnome/shell/theme">' > "$workDir"/theme/"$gdm3xml"
    for file in `gresource list "$gdm3Resource~"`; do
	echo "        <file>${file#\/org\/gnome/shell\/theme\/}</file>" \
	>> "$workDir"/theme/"$gdm3xml"
    done
    echo '    </gresource>
</gresources>' >> "$workDir"/theme/"$gdm3xml"

    # Compile the new gresource.
    CompileRes

    # Move gresource to the default place.
    MoveRes

    # Remove temporary files and exit.
    CleanUp

else

    # If no file was submited or file submited isn't an image,
    # show this message.
    echo 'Image file not found or wrong color hex code.'
    echo 'Please, submit a .jpg or .png image file or a valid hex code.'
    echo 'Usage: sudo ./ubuntu-20.04-change-gdm-background /path/to/image.*g'
    echo 'Usage: sudo ./ubuntu-20.04-change-gdm-background \#yourhexcode'

fi
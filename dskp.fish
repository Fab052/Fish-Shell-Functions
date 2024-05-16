function dskp
    echo ""
    echo "dskpc > Creates .desktop entries."
    echo "dskpd > Deletes .desktop entries."
    echo "dskpe > Edits .desktop entries using micro."
    echo "dskpu > Updates .desktop entries."
    echo "dskpls > Lists .desktop entries."
    echo "dskps > Saves .desktop entries in a tarball in the current directory."
    echo "dskpl > Loads .desktop entries from a tarball in the current directory."
    echo "dskpdeleteeverything > Deletes all .desktop entries."
    echo ""
end

function dskpc
    if test (count $argv) -ne 3
        echo "Usage: dskpc <executable_path> <icon> <exe_name>"
        return 1
    end

    set executable_path $argv[1]
    set icon $argv[2]
    set exe_name $argv[3]
    set desktop_file_path "$HOME/.local/share/applications/fish/$exe_name.desktop"

    # Extracting information from the executable
    set executable_name (basename $executable_path)
    set executable_basename (basename $executable_path ".exe")

    # Creating directory if it doesn't exist
    mkdir -p (dirname $desktop_file_path)
    cp $icon $HOME/.local/share/applications/fish/$exe_name.png

    # Writing .desktop file content
    echo "[Desktop Entry]" > $desktop_file_path
    echo "Type=Application" >> $desktop_file_path
    echo "Name=$executable_name" >> $desktop_file_path
    echo "Exec='$executable_path'" >> $desktop_file_path
    echo "Icon=$HOME/.local/share/applications/fish/$exe_name.png" >> $desktop_file_path
    echo "Terminal=false" >> $desktop_file_path
    echo "Desktop file created: $desktop_file_path"
    chmod +x $desktop_file_path
end

function dskpd
    if test (count $argv) -ne 1
        echo "Usage: dskpd <name>"
        return 1
    end

    set name $argv[1]
    set desktop_file_path "$HOME/.local/share/applications/fish/$name.desktop"

    if test -f $desktop_file_path
        rm $desktop_file_path
        rm "$HOME/.local/share/applications/fish/$name.png"
        update-desktop-database $HOME/.local/share/applications
        echo "Desktop file '$name.desktop' deleted."
    else
        echo "Desktop file '$name.desktop' not found."
    end
end

function dskpe --argument user_input
    if test (count $argv) -ne 1
        echo "Usage: dskpe <user_input>"
        return 1
    end
    
micro $HOME/.local/share/applications/fish/"$user_input".desktop
end

function dskpu
update-desktop-database $HOME/.local/share/applications
end

function dskpls
ls $HOME/.local/share/applications/fish/*.desktop
end

function dskps --argument user_input
    if test (count $argv) -ne 1
        echo "Usage: dskps <user_input>"
        return 1
    end

set tar_filename "$user_input.tar"
tar cvf - "$tar_filename" -C $HOME/.local/share/applications fish | lz4 > "$tar_filename".lz4
end

function dskpl --argument tar_input
    if test (count $argv) -ne 1
        echo "Usage: dskpl <tar_input>"
        return 1
    end
    
    set tar_filename "$tar_input.tar.lz4"
    
    echo "Do you want to delete .local/share/applications/fish? (y/N)"
    read -l confirm_delete
    if string match -q -r "(?i)y|yes" $confirm_delete
        rm -rf $HOME/.local/share/applications/fish 
    end
if [ -z "$FISH_VERSION" ]; then
    command -v fish > /dev/null 2>&1 && exec fish
end
lz4 -d "$tar_filename" -c | tar xvf - -C $HOME/.local/share/applications fish
end

function dskpdeleteeverything
rm -rf $HOME/.local/share/applications/fish
end

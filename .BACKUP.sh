#!/bin/bash

# This tool was designed to only run on my computer, but can be changed to run anywhere.
# By default, things are stored to "$DRIVE/.BACKUPS" ($DRIVE being a variable that directs to my SD card)
# If you want to change the place things are stored, then it would be best to use CTRL + F and find all
# references for "$DRIVE"
#
# Hope this can help you at all!

#alias impPacks='source $(GetDrive -o)/.BACKUPS/.LOADER/.BACKUP.sh'
#BACKS="$DRIVE/.BACKUPS/.LOADER"
# 'using' => Modified 'source' command
#using "$BACKS/.COMMAND_PARSER.sh"
#using "$BACKS/.UTILS.sh"
#using "$BACKS/.EXTRAS.sh"

source "path/to/Colors.sh" # Replace with path to Colors.sh. It contains the color commands you will see throughout this file

__padRight() {
    printf '\e[34m%-16s\e[33m%s\e[32m' "$(hostname)" "($1)" >$HOME/.__TEMP_INFO.INFO
}

warn() {
    echo -ne "$(red)$*$(norm)\n"
}

__padLeft() {
    printf '%s%*s' "\e[35m[$1]" "$(($2 - ${#1}))" ""
}

GetName() {
    [[ "$*" == "" ]] && echo $(red)No files provided && return 1
    local DRIVE=$(GetDrive -o)
    local NUM=0
    local FOLD=""
    for folder in $DRIVE/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq $1 ] && FOLD=${folder//$DRIVE\/.BACKUPS/} && FOLD=${FOLD//\//} && echo $FOLD && return 0
            NUM=$((NUM + 1))
        fi
    done
    return 1
}

RemoveLast() {
    local word="$*"
    while [[ "${word: -1}" != "/" ]]; do
        word=${word%?}
    done
    echo "$word"
}

GetDrive() {
    local ARGS="$*"
    for letter in {a..z}; do
        if [ -d /mnt/$letter/.BACKUPS/ ]; then
            [[ $ARGS == *"-o"* ]] && echo /mnt/$letter && return 0
            [[ $ARGS == *"-O"* ]] && DRIVE=/mnt/$letter && echo $DRIVE && return 0
            DRIVE=/mnt/$letter && return 0
        fi
    done
    [[ $ARGS == *"-q" ]] && echo $(red)Unable to find drive && return 1
}

GetDate() {
    DATE=$(date +"%Y/%m/%d %T")
    DATE=${DATE//\//:}
    DATE=${DATE// /_}
    [[ $* == *"-o"* ]] && echo $DATE && unset DATE
}

backup() {
    local text="$*"
    GetDate
    GetDrive
    [[ $DRIVE == "" ]] && echo $(red) No SDCard && return 1

    mkdir $DRIVE/.BACKUPS/$DATE || echo $(red)Failed to create backup directory $DRIVE/$DATE
    cp -r $HOME/LocalScripts $DRIVE/.BACKUPS/$DATE || echo $(red)Failed to copy LocalScripts $DRIVE/$DATE
    cp $HOME/.bashrc $DRIVE/.BACKUPS/$DATE || echo $(red)Failed to copy .bashrc to $DRIVE/$DATE
    __padRight backup
    [[ $text != "" ]] && text="\n\e[96m  $text"
    echo -ne "\e[33m$(date) \e[90m:: $(cat $HOME/.__TEMP_INFO.INFO)$text" >$DRIVE/.BACKUPS/$DATE/.BACKUP.INFO
    rm $HOME/.__TEMP_INFO.INFO
    echo $(green)Backed up .bashrc and LocalScripts to $DRIVE/.BACKUPS/$DATE
    unset DATE
}

# Backs up .bashrc and a folder I have called "LocalScripts"
# This command is really only helpful to me, so it would be best to use 'pack' instead
backups() {
    GetDrive
    [[ $DRIVE == "" ]] && echo $(red)No SDCard && return 1
    local NUM=0
    local SPACE=" "
    for folder in "$DRIVE"/.BACKUPS/*; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            TMP_folder=${folder//$DRIVE\/.BACKUPS\//}
            backup_info=$(cat "$folder"/.BACKUP.INFO 2>/dev/null)
            [[ $backup_info == "" ]] && backup_info="\e[31mNO_TIME_IMFORMATION\e[32m"
            if [ $NUM -gt 9 ]; then
                SPACE=""
            else
                SPACE=" "
            #elif [ $NUM -gt 99 ]; then
            #    SPACE=""
            #else # Not till at least 100
            #    SPACE="  "
            fi
            echo -ne "\e[35m[$NUM]$SPACE\e[32m[$TMP_folder] $backup_info\n"
            NUM=$((NUM + 1))
        fi
    done
    unset backup_info TMP_folder
}

# Allows you to backup specific files
pack() {
    [[ "$*" == "" ]] && echo $(red)No files provided && return 1
    local files=($*)
    local DRIVE=$(GetDrive -o)
    local DATE=$(GetDate -o)

    local TAGS=FALSE
    local TAG=""
    local LAP=0

    for word in "${files[@]}"; do
        [[ $word == "-t" ]] && TAGS=TRUE && unset -v 'files[$LAP]' && LAP=$((LAP + 1)) && continue
        [[ $TAGS == TRUE ]] && TAG="$TAG$word " && unset -v 'files[$LAP]'
        LAP=$((LAP + 1))
    done

    mkdir "$DRIVE/.BACKUPS/$DATE" || echo $(red)Failed to create backup directory $DRIVE/$DATE
    for file in "${files[@]}"; do
        [[ $file == "" ]] && continue
        [ -d $file ] && cp -r $file $DRIVE/.BACKUPS/$DATE && echo Packed $file && continue
        [ -f $file ] && cp $file $DRIVE/.BACKUPS/$DATE && echo Packed $file && continue
        echo $(yellow)Failed to move $file
    done
    __padRight pack
    [[ $TAG != "" ]] && TAG="\n\e[96m  $TAG"
    echo -ne "\e[33m$(date) \e[90m:: $(cat $HOME/.__TEMP_INFO.INFO)$TAG" >$DRIVE/.BACKUPS/$DATE/.BACKUP.INFO
    rm $HOME/.__TEMP_INFO.INFO
}

# removes a backup
unback() {
    [[ "$*" == "" ]] && echo $(red)No files provided && return 1
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo Accepted &>/dev/null
    else
        echo $(red)Numbers only
        return 1
    fi
    local DRIVE=
    DRIVE=$(GetDrive -o)
    local NUM=0
    local FOUND=FALSE
    local FOLDER=""
    local FOLDER_NAME=""
    for folder in $DRIVE/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq $1 ] && FOUND=TRUE && FOLDER=$folder && break
            NUM=$((NUM + 1))
        fi
    done
    if [[ $FOUND == FALSE ]]; then
        echo -ne "$(red)No backup found with number \e[35m[$1]\n"
        return 1
    else
        FOLDER_NAME=${FOLDER//$DRIVE\/.BACKUPS\//}
        FOLDER_NAME=${FOLDER_NAME//\//}
    fi
    unset answer
}

# 'cont' => "content"
# Write out all files and folders from a backup usng an index number
cont() {
    # Check if input data is acceptable
    [[ "$*" == "" ]] && backups && return 1
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo Accepted &>/dev/null
    else
        echo $(red)Numbers only
        return 1
    fi

    local DRIVE=$(GetDrive -o)
    local NUM=0
    local FOUND=FALSE
    local FOLDER=""
    local FOLDER_NAME=""
    # Find wanted backup folder
    for folder in $DRIVE/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq $1 ] && FOUND=TRUE && FOLDER=$folder && FOLDER_NAME=${folder//$DRIVE\/.BACKUPS/} && break
            NUM=$((NUM + 1))
        fi
    done

    FOLDER_NAME=${FOLDER_NAME//\//}
    # Main payload
    if [[ $FOUND == FALSE ]]; then
        echo -ne "$(red)No backup found with number \e[35m[$1]\n"
        return 1
    else
        local ARGS=($(find $FOLDER))
        local arr=()
        local type=()
        local HEADER="$DRIVE\/.BACKUPS\/$FOLDER_NAME\/"

        # Get content from indevidual files (cat them)
        if [[ $2 != "" ]] && [[ $(echo $2 | sed 's/i//g') =~ ^[0-9]+$ ]]; then
            local T=0
            for line in "${ARGS[@]}"; do
                [[ $T -eq $(echo $2 | sed 's/i//g') ]] && [[ -d $line ]] && echo $(red)Cannot cat a directory && return 1
                [[ $T -eq $(echo $2 | sed 's/i//g') ]] && echo -ne "\n$(cat $line)\n\n" && return 0
                T=$((T + 1))
            done
        fi

        local LAP=0
        # Color coding
        for line in "${ARGS[@]}"; do
            arr[$LAP]=0
            [ -d $line ] && type[$LAP]="\e[93m"
            [ -f $line ] && type[$LAP]="\e[33m"
            line="${line//$HEADER/}"
            for ((i = 0; i < ${#line}; i++)); do
                local char="${line:$i:1}"
                [[ $char == "/" ]] && arr[$LAP]=$((arr[LAP] + 1))
            done
            LAP=$((LAP + 1))
        done

        local LAST_LAP=0
        local LAP=0
        local SKIP=TRUE
        # Write out folder content
        echo -ne "\n$FOLDER \n"
        for ((i = 0; i < "${#ARGS[@]}"; i++)); do
            [[ $SKIP == TRUE ]] && SKIP=FALSE && continue
            local line="${ARGS[i]}"
            [[ $line == *".BACKUP.INFO"* ]] && continue
            if [[ $line == "" ]] || [[ $line == " " ]]; then continue; fi
            echo -ne "$(__padLeft $LAP)${type[i]}"
            # Indents
            for ((x = 0; x < 2; x++)); do
                printf '%*s' "${arr[i]}" ""
            done
            printf '%s' "${line//$(RemoveLast "$line")/}"
            [[ $LAP -gt 0 ]] && echo
            [[ $LAST_LAP -gt "${arr[i]}" ]] && [[ "${type[i]}" == "\e[95m" ]] && echo
            LAST_LAP="${arr[i]}"
            LAP=$((LAP + 1))
        done
    fi

    echo
    local FILES=$*
    FILES=${FILES//$1/}
    FILES=($FILES)
    # loop through all sub-directories
    for file in "${FILES[@]}"; do
        [[ $file == "" ]] || cont $file
    done
}

# cd's to the backup of the input index
goto() {
    [[ "$*" == "" ]] && echo $(red)No files provided && return 1
    local DRIVE=$(GetDrive -o)
    local NUM=0
    local FOUND=FALSE
    local FOLDER=""
    for folder in $DRIVE/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq $1 ] && FOUND=TRUE && FOLDER=$folder && break
            NUM=$((NUM + 1))
        fi
    done
    FOLDER_NAME=${FOLDER_NAME//\//}
    if [[ $FOUND == FALSE ]]; then
        echo -ne "$(red)No backup found with number \e[35m[$1]\n"
        return 1
    else
        cd "$FOLDER" || echo $(red)Failed to change directory to $FOLDER
        ls -a
        return 0
    fi
}

# changes the content of a backup with the given input index
overwrite() {
    [[ "$*" == "" ]] && echo $(red)No files provided && return 1
    [[ "$2" == "" ]] && echo $(red)No replacement files provided && return 1
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo Accepted &>/dev/null
    else
        echo $(red)Numbers only
        return 1
    fi
    local DRIVE=
    DRIVE=$(GetDrive -o)
    local NUM=0
    local FOUND=FALSE
    local FOLDER=""
    local FOLDER_NAME=""
    for folder in $DRIVE/.BACKUPS/*/; do
        if [[ $folder == *"_"* ]] && [[ $folder == *":"* ]]; then
            [ $NUM -eq $1 ] && FOUND=TRUE && FOLDER=$folder && FOLDER_NAME=${folder//$DRIVE\/.BACKUPS/} && break
            NUM=$((NUM + 1))
        fi
    done
    if [[ $FOUND == FALSE ]]; then
        echo -ne "$(red)No backup found with number \e[35m[$1]\n"
        return 1
    else
        echo "$(red)Are you sure you want to overwrite backup $(magenta)[$1]$(red)? (y/n)"
        while [[ $answer != "y" ]] && [[ $answer != "n" ]]; do
            cat $FOLDER/.BACKUP.INFO || echo $(red)NO_BACKUP_INFO
            echo -ne "\n$(red)Are you sure you want to remove backup $(magenta)[$1]$(red)? (y/n)\n"
            read answer
            [[ $answer != "y" ]] && [[ $answer != "n" ]] && echo -ne "\n$(red)\"y\" or \"n\"\n" && continue
        done
        if [[ $answer == "y" ]]; then
            echo $(green)Removed contents of backup $FOLDER_NAME
            local FILES="$*"
            FILES=${FILES//$1 /}
            FILES=(FILES)
            for file in "${FILES[@]}"; do
                [[ -d $file ]] && cp -r $file $FOLDER
                [[ -f $file ]] && cp $file $FOLDER
            done
        fi
        [[ $answer == "n" ]] && echo $(red)Aborted && unset answer && return 1
    fi
}

# └ ─ ├

# Write out a file tree
# WARNING: This was horribly written and gathers all paths BEFORE writing them out
# It will take FOREVER when ran somewhere like "/"
form() {
    closer() {
        set +f
        unset ARGS
        echo -ne "\n\n$(red)Exiting\n"
        trap - INT
        return 1
    }
    trap closer INT
    set -f
    IFS='
'
    #local ARGS=($(sudo find . 2>/dev/null))
    [[ $1 != "" ]] && local DIR="$1"
    [[ $1 != "" ]] && local DIR="."
    mapfile -t ARGS < <(sudo find $DIR 2>/dev/null)
    local arr=()
    local type=()
    local HEADER="$(pwd)"
    local LAP=0
    set +f
    unset IFS
    for line in "${ARGS[@]}"; do
        arr[$LAP]=0
        [ -d "$line" ] && type[$LAP]="\e[93m"
        [ -f "$line" ] && type[$LAP]="\e[33m"
        line="${line//$HEADER/}"
        for ((i = 0; i < ${#line}; i++)); do
            local char="${line:$i:1}"
            [[ $char == "/" ]] && arr[$LAP]=$((arr[LAP] + 1))
        done
        LAP=$((LAP + 1))
    done

    local LAST_LAP=0
    LAP=1
    local LAST_LINE="${#type[@]}"
    local nLEN=${#LAST_LINE}
    LEN=$((nLEN + 2))
    local SKIP=TRUE

    for ((i = 0; i < "${#ARGS[@]}"; i++)); do
        [[ $SKIP == TRUE ]] && SKIP=FALSE && continue
        local line="${ARGS[i]}"
        [[ $line == *".BACKUP.INFO"* ]] && continue
        [[ $line == "" ]] && continue
        echo -ne "$(__padLeft $LAP $LEN)${type[i]}"
        for ((x = 0; x < 2; x++)); do
            printf '%*s' "${arr[i]}" ""
        done
        #echo -ne $i : $line
        echo -ne "${line//$(RemoveLast "$line")/}"
        [[ $LAP -gt 0 ]] && echo
        [[ $LAST_LAP -gt "${arr[i]}" ]] && [[ "${type[i]}" == "\e[95m" ]] && echo
        LAST_LAP="${arr[i]}"
        LAP=$((LAP + 1))
    done
    set +f
    trap - INT
}

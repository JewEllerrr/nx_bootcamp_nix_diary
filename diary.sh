#!/bin/bash

umask g-w,o-w

if [ -z "$DIARYPATH" ]; then
    mkdir -p $HOME/diary/recycle_diary_bin
    DIARYPATH="$HOME/diary"
    export DIARYPATH
    DIARYRECYCLEPATH="$DIARYPATH/recycle_diary_bin"
    export DIARYRECYCLEPATH
fi

if [ -z "$EDITOR" ]; then
    EDITOR=vi
    export EDITOR
fi

if [ -f "$DIARYPATH/.diaryrc" ]; then
    . "$DIARYPATH/.diaryrc"
fi

function diary() {
    echo "
Commands:
  add  [header name]        adds new note to diary
  open [note ID]            opens choosen note
  statistics                shows some statistics 
  choose_editor             choices for the alternative text editor
  setpath [PATH]            changes current path
  getpath                   returns current diary path
  delete [note ID]          deletes choosen note to recycle diary byn (rdb)
  show_rdb                  shows files in recycle diary byn
  remove_diary              removes diary
  last5                     shows last 5 created files
"
}

function add() {
    if [ -n $1 ]; then
        date=$(date '+%Y-%m-%d_%H:%M')
        current_year=$(date +'%Y')
        current_month=$(date +'%B')

        if [ ! -f $DIARYPATH/$current_year/$current_month ]; then
            mkdir -p $DIARYPATH/$current_year/$current_month
        fi

        # bash generate random 5 character alphanumeric string (lowercase only)
        local ID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
        touch $DIARYPATH/$current_year/$current_month/$ID"__$date.md"
        $EDITOR $DIARYPATH/$current_year/$current_month/$ID*
        echo "Note $1 added to your diary!"
        return 0
    fi
}

function open() {
    if [ -n $1 ]; then
        local ID=$1
        if [ -f $DIARYPATH/$current_year/$current_month/$ID* ]; then
            $EDITOR $DIARYPATH/$current_year/$current_month/$ID*
            return 0
        else
            echo "File $filename not found!"
            return 0
        fi
    fi
}

function statistic() {
    echo "
  1. Number of stored diary notes
  2. -
  3. -
  4. Longest diary note
  "
    read doing

    case $doing in
    1)
        echo "Number of stored diary notes: $(find $DIARYPATH -type f| wc -l)"; 
        ;;
    2)
        echo "Should be Date of the last note"
        ;;
    3)
        echo "Should be Number of stored diary notes or each year and month"
        ;;
    4)
        find $DIARYPATH -maxdepth 3 -type f -exec ls -s {} \; | sort -n -r | head -1
        return 0
        ;;
    *)
        echo "Unavailable option"
        ;;
    esac
}

function choose_editor() {
    echo "Choose alternative text editor:
  1  nano
  2  vim
  3  emacs
  4  exit
  "
    read doing

    case $doing in
    1)
        EDITOR=nano
        echo "Text editor 'nano' seted"
        ;;
    2)
        if [ ! -e /usr/bin/vim ]; then
            sudo apt-get update
            sudo apt-get install vim -y
        fi
        EDITOR=vim
        echo "Text editor 'vim' seted"
        ;;
    3)
        if [ ! -e /usr/bin/emacs ]; then
            sudo apt-get update
            sudo apt-get install emacs -y
        fi
        EDITOR=emacs
        echo "Text editor 'emacs' seted"
        ;;
    4)
        exit 0
        ;;
    *)
        echo "Unavailable option"
        ;;
    esac
}

function setpath() {
    if [ -d "$1" ]; then
        local new_path=$1
        OLD_DIARYPATH=$DIARYPATH
        if cp -R $OLD_DIARYPATH/* $new_path; then
            DIARYPATH="$new_path"
            echo "Files moved successfully from $OLD_DIARYPATH to $new_path!"
            rm -r $OLD_DIARYPATH
        else
            echo "Failed to remove the directory"
            return 0
        fi
    else
        echo "Directory $new_path not found"
    fi
}

function getpath() {
    if [ ! -z "$DIARYPATH" ]; then
        echo $DIARYPATH
    fi
}

function delete() {
    if [ -n $1 ]; then
        local ID=$1
        local file_path=$DIARYPATH/$current_year/$current_month/$ID*

        if [ ! -f $DIARYRECYCLEPATH ]; then
            mkdir -p $DIARYPATH/recycle_diary_bin
            DIARYRECYCLEPATH="$DIARYPATH/recycle_diary_bin"
        fi

        if [ -f $file_path ]; then
            cp $file_path $DIARYRECYCLEPATH
            rm $file_path
            echo "File delited"
            return 0
        else
            echo "File $file_path not found!"
            return 0
        fi
    fi
}

function show_rdb() {
    if [ ! -z "$DIARYRECYCLEPATH" ]; then
        ls -1 $DIARYRECYCLEPATH
    fi
}

function remove_diary() {
    if [ ! -z "$DIARYPATH" ]; then
        rm -r $DIARYPATH
    fi
}

function last5(){
    find /$DIARYPATH -maxdepth 3 -type f -exec ls -s {} \; | sort -n -r | head -5
}
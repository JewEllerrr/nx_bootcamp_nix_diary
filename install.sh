#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/JewEllerrr/nx_bootcamp_nix_diary/main/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/JewEllerrr/nx_bootcamp_nix_diary/main/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/JewEllerrr/nx_bootcamp_nix_diary/main/install.sh)"
#
set -e
# Default settings
DIARYPATH=${DIARYPATH:-~/.diary}
REPO=${REPO:-JewEllerrr/nx_bootcamp_nix_diary}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

fmt_error() {
  printf '%sError: %s%s\n' "$BOLD$RED" "$*" "$RESET" >&2
}

fmt_underline() {
  printf '\033[4m%s\033[24m\n' "$*"
}

fmt_code() {
  # shellcheck disable=SC2016 # backtic in single-quote
  printf '`\033[38;5;247m%s%s`\n' "$*" "$RESET"
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

setup_diary() {

  umask g-w,o-w
  
  command_exists git || {
    fmt_error "git is not installed"
    exit 1
  }
  
  mkdir $DIARYPATH 

  git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    --depth=1 --branch "$BRANCH" "$REMOTE" "$DIARY" || {
    fmt_error "git clone of diary repo failed"
    exit 1
  }

  echo
}

setup_diaryrc() {

  touch $DIARYPATH/.diaryrc
  source $DIARY/diary.sh

	echo
}

main() {

  setup_color

  if ! command_exists diary; then
    echo "${YELLOW}Diary is not installed.${RESET} Please install diary first."
    exit 1
  fi

  setup_diary
  setup_diaryrc

  printf %s "$GREEN"
  cat <<'EOF'
   
   Diary....is now installed!
EOF
  cat <<EOF
EOF
  printf %s "$RESET"

  if [ $RUNZSH = no ]; then
    echo "${YELLOW}Run diary to try it out.${RESET}"
    exit
  fi
}

main "$@"

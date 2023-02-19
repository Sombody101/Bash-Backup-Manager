#tput setab [1-7] – Set a background color using ANSI escape
#tput setb [1-7] – Set a background color
#tput setaf [1-7] – Set a foreground color using ANSI escape
#tput setf [1-7] – Set a foreground color
#~~~
#tput bold – Set bold mode
#tput dim – turn on half-bright mode
#tput smul – begin underline mode
#tput rmul – exit underline mode
#tput rev – Turn on reverse mode
#tput smso – Enter standout mode (bold on rxvt)
#tput rmso – Exit standout mode
#tput sgr0 – Turn off all attributes
#~~~
#0 – Black
#1 – Red
#2 – Green
#3 – Yellow
#4 – Blue
#5 – Magenta
#6 – Cyan
#7 – White

# Text colors
alias black='tput setaf 0'
alias red='tput setaf 1'
alias green='tput setaf 2'
alias yellow='tput setaf 3'
alias blue='tput setaf 4'
alias magenta='tput setaf 5'
alias cyan='tput setaf 6'
alias white='tput setaf 7'

# Highlighted
alias ,black='tput smso; black'
alias ,red='tput smso; red'
alias ,green='tput smso; green'
alias ,yellow='tput smso; yellow'
alias ,blue='tput smso; blue'
alias ,magenta='tput smso; magenta'
alias ,cyan='tput smso; cyan'
alias ,white='tput smso; white'

# Undo highlight
alias .black='tput rmso; black'
alias .red='tput rmso; red'
alias .green='tput rmso; green'
alias .yellow='tput rmso; yellow'
alias .blue='tput rmso; blue'
alias .magenta='tput rmso; magenta'
alias .cyan='tput rmso; cyan'
alias .white='tput rmso; white'

# Accents
alias bold='tput bold'
alias underline='tput smul'
alias ,underline='tput rmul'
alias dim='tput dim'
alias rev='tput rev'

# Reset
alias norm='tput sgr0'

# using ColorSheet.sh
#fromRGB() {
#    local colorName=$1
#    local R=$2
#    local G=$3
#    local B=$4
#    [[ $colorName == "" ]] && warn "No value for the color name, red, green, or blue (0-255)" && return 1
#    [[ $R == "" ]] && warn "No value for red, green, or blue (0-255)" && return 1
#    [[ $R == "" ]] && warn "No value for red, green, or blue (0-255)" && return 1
#    [[ $B == "" ]] && warn "No value for blue (0-255)" && return 1
#    printf 'alias %s='"'"'echo -ne \x1b[38;2;%s;%s;%sm'"'"'\n' $colorName $R $G $B>> $HOME/LocalScripts/ColorSheet.sh
#    using $HOME/LocalScripts/ColorSheet.sh
#}
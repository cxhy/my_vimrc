alias g gvim
alias ll 'ls -ltrhF --color=auto'
alias cp cp -i
alias mv mv -i
alias rm rm -i
alias u cd ..
alias uu cd ../../
alias uuu cd ../../../
alias uuuu cd ../../../../
alias cd 'chdir \!*; ls'
alias qq 'cd -'
alias kk 'll'
alias d 'cd'
set nobeep
set autolist
set correct = cmd

alias gitaddm 'git ls-files --modified . | xargs git add'
alias qdb     'srun -p memory -w memory-5 verdi -dbdir ../build/simv.daidir -ssf dump.vf &'
alias getsub  'git submodule update --init --recursive'
alias useverdi 'squeue | grep verdi | awk "NR>1 {print $4}" | sort | uniq -c | sort -nr'
alias i 'cd `find . -maxdepth 1 -mindepth 1 -type d  -printf "%T@ %p\n" | sort -nr | awk '\''NR==1 {print $2}'\''`'

set cr = "%{\033[31m%}"
set cg = "%{\033[32m%}"
set cy = "%{\033[33m%}"
set cb = "%{\033[34m%}"
set cq = "%{\033[36m%}"
set c0 = "%{\033[0m%}" 

set prompt = "[${cq}%n${c0}@${cr}%m${c0}:${cb}%c${c0}]# "

setenv CLICOLOR yes
setenv LSCOLORS ExGxFxdxCxegedabagExEx

setenv GREP_OPTIONS --color=auto
setenv NOVAS_RC  ~/verdi_config/novas.rc



  

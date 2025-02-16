# .bashrc

# note: append to already existing .bashrc

# User specific aliases and functions
# Editing shell prompt 
PS1='nvo> '

### SHORTCUTS ###
#Creating shortcuts to directories  
alias ..='cd ..;pwd;ls'  # move to parent folder 
alias home='cd ~;pwd;ls'
alias DIR_NAME='cd /PATH/TO/DIR;pwd;ls'  # move to commonly used fodler 

# shortcuts for slurm 
alias myq='squeue -u USERNAME'
alias QUEUE_NAME='squeue -p PARTITION_NAME -u USERNAME'  # my jobs on a commonly used partition 

# salloc
alias mysalloc='salloc -N 1 -n 1 -c 1 --time=10:00:00 -p PARTITION_NAME'

# salloc for a specific commonly used node
alias sshsalloc='salloc -N 1 -c 5 -w NODE_NAME --time=12:00:00 -p PARTITION_NAME'

# conda/mamba shortcuts 
alias condaa='mamba activate'
alias condad='mamba deactivate'
alias condac='mamba create'
alias CONDA_ENV_NAME='mamba activate CONDA_ENV_NAME' # for a commonly activated/used conda environment 

# other shortcuts 
alias chgrp='chgrp -R chisholmlab *'  # change group permission recursively 
alias c='clear'  # clear terminal screen
alias tree='tree --dirsfirst -F'  # display directory structure better 
alias mkdir='mkdir -p -v'  # make directory and all parent directories with verbosity
alias py3='python3'
alias rm='rm -i'  # prompts user before deleting file - lowkey annoying 

### Changes to $PATH ###
export PATH=$HOME/bin:$PATH


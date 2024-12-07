docker run -v /Users/dinelkananayakkara/Desktop/UNC/PhD/Fall_2024/BIOS611/project:/home/rstudio/myproject\
           -p 8787:8787\
           -p 8888:8888\
           -e USERNAME="rstudio"\
           -e PASSWORD="password"\
           -it loanapp
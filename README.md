# Introduction

This is my data science project for BIOS 611 (Data Science Basics) at UNC-CH. 

Overview/Problem: : financial institutions are always on the lookout for ways to make processes efficient. One area of focus is the approval process of a loan. This project aims to use around 10 possible indicators to attempt automating the loan approval process.

Machine Learning algorithms used: Logistic Regression, Random Forest.

Dataset: Loan Approval Dataset from Kaggle. Source data can be found at https://www.kaggle.com/competitions/playground-series-s4e10/data

# Getting started

To start with working on this project, we can first build a docker environment. This can be done as follow (make sure you first have docker installed on your computer). To build this docker container first create a file called .password (this contains the password that can be used when logging into RStudio).

```bash
docker build . --build-arg linux_user_pwd="$(cat .password)" -t loan_pred
```
The above will create a docker container. We can next run this docker container using the following commands:

```bash
docker run -v $(pwd):/home/rstudio/ashar-ws\
           -p 8787:8787\
           -p 8888:8888\
           -e PASSWORD="$(cat .password)"\
           -it ashar
```
Next, use link http://localhost:8787 via your web browser to access RStudio. Port 8888 also has been exposed to launch RShiny for those who want to view the dashboard.


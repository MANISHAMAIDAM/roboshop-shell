#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf install golang -y &>>$LOGFILE
VALIDATE $? "Installing golang"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exist...$Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip  &>> $LOGFILE
VALIDATE $? "Downloading dispatch application"

cd /app  &>> $LOGFILE
VALIDATE $? "Moving to app directory"

unzip /tmp/dispatch.zip  &>> $LOGFILE
VALIDATE $? "Extracting dispatch application"

cd /app  &>> $LOGFILE
VALIDATE $? "Moving to app directory"

go mod init dispatch  &>> $LOGFILE
go get  &>> $LOGFILE
go build  &>> $LOGFILE

VALIDATE $? "build dispatch"


cp /home/ec2-user/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE
VALIDATE $? "Copying dispatch service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable dispatch &>> $LOGFILE
VALIDATE $? "Enable dispatch"

systemctl start dispatch &>> $LOGFILE
VALIDATE $? "Start dispatch"
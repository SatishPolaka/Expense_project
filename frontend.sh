#!bin/bash

USERID=$(id -u)

# colors
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

#logs

Log_Folder="/var/log/expense_project_frontend"


if [ ! -d "$Log_Folder" ]
then
    echo "File doesn't exist. Creating now"
    mkdir $Log_Folder
    echo "File created"
else
    echo "File exists"
fi

Log_File=$( echo $0 | cut -d "." -f1 ) 
TimeStamp=$(date "+%Y-%m-%d_%H-%M-%S")
Log_File_Name="$Log_Folder/$Log_File-$TimeStamp.log"


VALIDATE(){
if [ $1 -ne 0 ]
    then
        echo -e " $2 ... $R failed $N"
        exit 1
    else
        echo -e "$2 ...  $G  sucess $N"            
    fi

}

Check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e " $R  You must be the root user to excute the script $N "
        exit 1
    fi
}

echo  -e " script started at $TimeStamp" &>>$Log_File_Name

Check_root

dnf install nginx -y &>>$Log_File_Name
VALIDATE $? " installing nginx"

systemctl enable nginx &>>$Log_File_Name
VALIDATE $? " enabling nginx"

systemctl start nginx &>>$Log_File_Name
VALIDATE $? " starting nginx"

rm -rf /usr/share/nginx/html/* &>>$Log_File_Name
VALIDATE $? " removing files from /usr/share/nginx/html"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$Log_File_Name
VALIDATE $? " downloading frontend.zip"


cd /usr/share/nginx/html
VALIDATE $? " changing directory to /usr/share/nginx/html"

unzip /tmp/frontend.zip &>>$Log_File_Name
VALIDATE $? " unzipping frontend.zip"

#vim /etc/nginx/default.d/expense.conf
cp /home/ec2-user/Expense_project/expense.conf /etc/nginx/default.d/expense.conf


systemctl restart nginx &>>$Log_File_Name
VALIDATE $? " restarting nginx"
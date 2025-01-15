#!bin/bash

USERID=$(id -u)

# colors
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

#logs

Log_Folder="/var/log/expense_project_backend"


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

dnf module disable nodejs -y &>>$Log_File_Name
VALIDATE $? " disabling nodejs"

dnf module enable nodejs:20 -y &>>$Log_File_Name
VALIDATE $? " enabling nodejs"

dnf install nodejs -y &>>$Log_File_Name
VALIDATE $? " installing nodejs"

# user validation exist or not
id expense &>>$Log_File_Name
if [ $? -eq 0 ]
then
    echo "user already exist"
else
    useradd expense &>>$Log_File_Name
    VALIDATE $? " adding user"
fi

# checking the driectory exist or not
dir="/home/expense" 

if [ ! -d "$dir" ]
then
    echo "File doesn't exist. Creating now"
    mkdir $dir
    echo "File created"
else
    echo "File exists"
fi

# checking the app directory exist or not

dirapp="/app"
if [ ! -d "$dirapp" ]
then
    echo "File doesn't exist. Creating now"
    mkdir $dirapp &>>$Log_File_Name
    echo "File created"
else
    echo "File exists"
fi


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$Log_File_Name
VALIDATE $? " downloading backend"

cd /app

# loading the same unzipping files

rm -rf * &>>$Log_File_Name
unzip /tmp/backend.zip &>>$Log_File_Name
VALIDATE $? " unzipping backend"

npm install &>>$Log_File_Name
VALIDATE $? " installing dependencies"

cp /home/ec2-user/Expense_project/backend.service /etc/systemd/system/backend.service &>>$Log_File_Name

dnf install mysql -y &>>$Log_File_Name
VALIDATE $? " installing mysql"

mysql -h mysql.psrexpense.store -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$Log_File_Name
VALIDATE $? " setting up the transaction and schema"

systemctl daemon-reload &>>$Log_File_Name
VALIDATE $? " reloading daemon"

systemctl enable backend &>>$Log_File_Name
VALIDATE $? " enabling backend"

systemctl start backend &>>$Log_File_Name
VALIDATE $? " starting backend"



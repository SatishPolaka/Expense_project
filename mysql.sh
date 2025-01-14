#!bin/bash

USERID=$(id -u)

# colors
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

#logs

Log_Folder="/var/log/expense_project"


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

echo  -e " script started at $TimeStamp" &>>$Log_File_Name

if [ $USERID -ne 0 ]
then
    echo -e " $R  You must be the root user to excute the script $N "
    exit 1
fi

dnf install mysql-server -y &>>$Log_File_Name
VALIDATE $? " installing mysql-server"

systemctl enable mysqld &>>$Log_File_Name
VALIDATE $? " enabling mysql-server"

systemctl start mysqld &>>$Log_File_Name
VALIDATE $? " starting mysql-server"

mysql -h mysql.psrexpense.store -u root -pExpenseApp@1 -e 'show databases;' &>>$Log_File_Name

if [ $? -ne 0 ]
then
    echo "Creating database"
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$Log_File_Name
    VALIDATE $? " creating database"
else
    echo " $Y Database already exists $N"
fi

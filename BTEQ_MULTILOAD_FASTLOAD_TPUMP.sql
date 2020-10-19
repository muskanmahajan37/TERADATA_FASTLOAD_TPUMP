https://forgetcode.com/Teradata/1593-BTEQ-ERRORCODE-Checking-for-errors

http://teradatatrainingbysatish.blogspot.com/2016/01/teradata-sample-scripts-bteq-fastload.html

/********************************************************************************

.RUN FILE c:\tx\sample.txt;

Consider the below content is in the above path.
.LOGON localtd/dbc,dbc
 
DATABASE forgetcode;
DELETE FROM tbl_employee;
 
.IF ERRORCODE=0 THEN .GOTO ins
 
CREATE TABLE tbl_employee(
id INT,
name VARCHAR(30),
Salary DECIMAL(30,4));
 
.LABEL ins
INSERT INTO tbl_employee(1,'Ruby',15000);
INSERT INTO tbl_employee(2,'Rose',17000);
 
.LOGOFF
.EXIT


Explanation:
1. First we login with user id and password.
2. We choose Database.
3. We are deleting the records from the employee table.
4. If delete operation is successful, then the error code will be zero and move to ins LABEL part.
5. It will insert the records and quit BTEQ.


/********************************************************************************
BTEQ SAMPLE SCRIPT :
1. SQL's running through Bteq : 

/********************************************************************************
*  Project:  Project_name                                                  
*  Describtion: Details 
********************************************************************************/
.Logon Server/Userid,PWD;

** Initiate remark for start of script
.REMARK "<<<< Processing Initiated >>>>"

SELECT DATE,TIME;
.SET WIDTH 132;

Database db_name;

CREATE TABLE Sou_EMP_Tab
( EMP_ID   Integer,
EMP_Name Char(10)
)Primary Index (EMP_ID);

INSERT INTO Sou_EMP_Tab
(1, 'bala‘);
INSERT INTO Sou_EMP_Tab
(2, 'nawab‘);

.QUIT
.Logoff

/********************************************************************************

2. BTEQ EXPORT :
/********************************************************************************

.logon tdpid/username,password;
database db_name;
.export report file=c:\p\hi.txt
.set retlimit 4
select * from tab_name;
.export reset;

.logoff;

{or}

.EXPORT FILE = <Local path>;


Example:
.LOGON localtd/dbc,dbc;
.EXPORT FILE = C:\TX\out.txt;
.SET SEPARATOR '|'
 
DATABASE forgetcode;
SELECT * FROM tbl_employee;
 
.LOGOFF
.EXIT


/********************************************************************************
3. BTEQ IMPORT :
/********************************************************************************
.logon tdpid/username,password;
.import vartext ',' file = c:\p\var.txt
database db_name;
.quiet on;
.repeat *;
using i_eid(integer),
           i_ename(varchar(30)),
           i_sal(dec(6,2)),
           i_grade(varchar(30)),
           i_dept(varchar(30))
insert into tab_name(eid,ename,sal,grade,dept)
values(:i_eid,:i_ename,:i_sal,:i_grade,:i_dept);
.logoff;



/********************************************************************************

FASTLOAD Sample script :
/********************************************************************************

ERRLIMIT 25;
logon tdpid/username,password;

create table cust(
wh_cust_no integer not null,
cust_name varchar(200),
bal_amt decimal(15,3) 
)
unique primary index( wh_cust_no ) ;

SET RECORD UNFORMATTED;

define
                wh_cust_no(char(10)), delim1(char(1)),
                cust_name(char(200)), delim2(char(1)),
                bal_amt(char(18)), delim3(char(1))
                newlinechar(char(1))
file=insert.input;

SHOW;

BEGIN LOADING cust errorfiles error_1, error_2;

insert into cust(
                :wh_cust_no,
                :cust_name,
                :bal_amt
);

END LOADING;



/********************************************************************************

MULTILOAD Sample script :
/********************************************************************************

.logtable inslogtable;
.logon tdpid/username,password;
 create table cust_tab (
wh_cus_no integer not null,
cus_name varchar(200),
bal_amt decimal(15,3)
)
unique primary index( wh_cust_no ) ;
 .BEGIN IMPORT MLOAD tables cust_tab;
 .layout cuslayout;
                .field wh_cus_no 1 char(10);
                .field cus_name 12 char(200);
                .field bal_amt 213 char(18);
.dml label insercusdml;
 insert into cust_tab.*;
 .import infile insert.input
                format text
                layout cuslayout
                apply insertcusdml;
.END MLOAD;
 .logoff; 



/********************************************************************************

FASTEXPORT Sample script :
/********************************************************************************

.logtable db_name.mgr;
.logon CDW/Sql101,whynot;

.set col_name to 'pawan';

.display 'run1 at --&systime' to file e:\td_folder\fast_export.txt;

.begin export tenacity 4 sleep 2;
.export outfile e:\td_folder\fast_export.out 
 mode record
 format text;
select * from db_name.tb_name  where emp_name = '&col_name';
.END EXPORT;

.display 'run2 at --&systime' to file e:\td_folder\fast_export.txt;

.begin export tenacity 4 sleep 2;
.export outfile e:\td_folder\fast_export1.out 
 mode record
 format text;
select * from db_name.tb_name1 where emp_name = '&col_name';
.END EXPORT;

.LOGOFF; 


/********************************************************************************
TPUMP Sample script :
/********************************************************************************


.logtable db_name.mgr;
.logon CDW/Sql101,whynot;
database db_name;
.name test;
.begin load errortable ET_test
sleep 5
checkpoint 5
sessions 8
errlimit 4
pack 4
/*pack 2 tells TPump to "pack" 4 rows and load them at one time */
tenacity 4
serialize on;
/*you only use the SERIALIZE parameter when you are going to
specify a PRIMAY KEY in the .FILED command */
.layout sou;
.field i_emp_id * varchar(5) key;
.field i_emp_name * varchar(30);
.dml label INST;
insert into test
(party_id,party_name
)
values
(:i_emp_id,
:i_emp_name
);
.import infile e:\TD_FOLDER\vartext_data.txt
format vartext ','
layout sou
apply INST;
.end load;
.logoff;

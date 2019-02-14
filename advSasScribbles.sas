/*Use the VALIDATE keyword to check the SELECT statement syntax*/
proc sql;
	validate
	select * from PA_HW1.hw1;
quit;

/*Use the NOEXEC option to check the SELECT statement syntax*/
proc sql noexec;
	select * from PA_HW1.hw1;
quit;

/*Use the RESET option to reset the PROC SQL options*/
proc sql noexec;
	reset exec;
	select * from PA_HW1.hw1;
quit;

/*Use the FEEDBACK option to write the expanded SELECT statement to the log
Output:
select EMPLOYEE_PAYROLL.Employee_ID, EMPLOYEE_PAYROLL.Employee_Gender, EMPLOYEE_PAYROLL.Salary, 
 EMPLOYEE_PAYROLL.Birth_Date, EMPLOYEE_PAYROLL.Employee_Hire_Date, EMPLOYEE_PAYROLL.Employee_Term_Date, 
 EMPLOYEE_PAYROLL.Marital_Status, EMPLOYEE_PAYROLL.Dependents
from ORION.EMPLOYEE_PAYROLL;*/
proc sql feedback;
	select * from orion.employee_payroll;
quit;

*Describes the columns in a table;
proc sql;
	describe table orion.customer;
quit;

*Column name will show blank if no alias has been specified;
proc sql ;
	select customer_id, gender, 2*2 as dummy from orion.customer;
quit;

/*SCAN function: returns the nth word or segment from a character string
after breaking it up by delimiters - index begins from 1.
Index can also begin from RTL, use -1 instead to select last character*/
proc sql ;
	*Gives the first name of the customer;
	select scan(customer_name, 1) from orion.customer;
	*Gives the second name of the customer;
	select scan(customer_name, 2) from orion.customer;
quit;

*CASE WHEN;
*Use this when mix-matching variables;
proc sql;
	select job_title, salary,
		case
			when scan(job_title, -1, ' ') ='I'
				then salary*0.05
			when scan(job_title, -1, ' ') ='II'
				then salary*0.07
			when scan(job_title, -1, ' ') ='III'
				then salary*0.1
			when scan(job_title, -1, ' ') ='IV'
				then salary*0.12
			else salary*0.08
		end as bonus
	from orion.staff;
quit;

proc sql;
	select job_title, salary,
		case scan(job_title, -1, ' ')
			when 'I' then salary*0.05
			when 'II' then salary*0.07
			when 'III' then salary*0.1
			when 'IV' then salary*0.12
			else salary*0.08
		end as bonus
	from orion.staff;
quit;

*SAS date is stored as the number of wholed days from Jan 1 1960;

/*
	TODAY() - today's date in SAS date form
	MONTH(arg) - returns the month portion of a SAS date variable as an int from 1-12
	INT(arg) - returns the integer portion of a number
*/
proc sql;
	select
	employee_id, employee_gender, 
	int((today()-birth_date)/365.25) as age
	from orion.employee_payroll;
quit;

*Escape clause specifies the escape character - any char following this is an actual text and not a special character;
proc sql;
	select
	employee_id, job_code
	from orion.employee_organization
	where job_code like 'SA/_%' ESCAPE '/';
	*Searches for SA_;
quit;

/*Calculated columns cannot be used with WHERE clause. Use the foll. solutions
1. Re-do the calculation in the where clause
2. Use CALCULATED keyword to refer to an already calculated column*/

proc sql;
	select * from orion.employee_payroll;
quit;

/*FINDC - Searches a string for any character in a list of characters
INDEXC - 
INDEXW - 
*/

proc sql;
	select
	employee_id,
	salary
	from
	orion.employee_payroll
	where
	employee_hire_date<'01JAN1979'd
	order by salary desc, employee_id desc;
quit;

proc sql;
	select
	employee_id, max(qtr1,qtr2,qtr3,qtr4)
	from
	orion.employee_donations
	where
	paid_by='Cash or Check'
	order by 2 desc, employee_id;
quit;

/*To change the default behaviour of remerge, use noremerge option*/
proc sql noremerge;
quit;

/*where clause is processed before the group by clause, 
having is processed after the group by clause and determines
which groups are to be displayed*/

*Non-Correlated subquery example;
proc sql;
	select 
	job_title, avg(salary) as MeanSalary
	from orion.staff
	group by job_title
	having avg(salary)>
	(select 
	avg(salary)
	from orion.staff);
quit;

/*Correlated subquery
1. Cannot be evaluated independently
2. Requires values to be passed from outer query to the inner query
3. Are evaluated for each row in the outer query
*/
proc sql;
	select 
	employee_id, avg(salary) as MeanSalary
	from orion.employee_addresses
	where 'AU'=
	(
		select 
		country 
		from work.supervisors
		where 
		employee_addtesses.employee_id=supervisors.employee_id
	);
quit;

proc sql;
	select 
	department, job_title,
	(find(job_title,"managaer","i")>0)
	"Manager"
	from orion.employee_organization;
quit;

proc sql;
	title "Manager to employee ratios";
	select
	Department,
	sum(find(job_title, 'manager', 'i')>0) as Managers,
	sum(find(job_title, 'manager', 'i')=0) as Employees,
	calculated Managers/calculated Employees as Ratio format=percent8.2
	from
	orion.employee_organization
	group by Department;
quit;

/*Joins*/

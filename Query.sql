-- Aggregate Functions(count, sum, avg, min, max) with having
-- Total no. of classrooms in each faculty
select faculty, sum(no_of_classrooms) as Total_no_of_classrooms from department group by faculty;
-- Average salary of teachers in each department
select dept_name, avg(salary) as Average_salary from instructor group by dept_name;
-- Total no. of students in each department
select dept_name, count(*) as Total_no_of_students from student group by dept_name;
-- Minimum salary of teachers in each department
select dept_name, min(salary) as Minimum_salary from instructor group by dept_name;
-- Maximum salary of teachers in each department
select dept_name, max(salary) as Maximum_salary from instructor group by dept_name;
-- Name of faculty having more than 55 classrooms with no. of classrooms and no. of departments
select faculty, sum(no_of_classrooms) as Total_no_of_classrooms, count(dept_name) as Number_of_departments from department group by faculty having sum(no_of_classrooms) > 55;

-- String
-- Name of the 1st boy/girl in each department
select dept_name, name from student where id like '____1';

-- Union, Intersection, Except
-- Name of dept having at least one student with total credit more than 20 or having more than 15 classrooms
(select dept_name from student where tot_cred > 20) union (select dept_name from department where no_of_classrooms > 20);
-- Name of courses having credit greater than or equal to 3.0 and at least one student has got A on that course
(select course_id from course where credit >= 3.0) intersect (select course_id from takes where grade like 'A');
-- Name of courses having credit equal to 4.00 and students taking that course has got less than 'A' 
(select course_id from course where credit = 4.0) except (select course_id from takes where grade like 'A'); 

-- In, Not in
-- Name of students who have taken courses taught by instructor with id = '11101';
select name from student where id in (select id from takes where course_id in (select course_id from teaches where id like '11101')); 
-- Titles of courses that are taught in 3rd year but not in 'ME' faculty
select title from course where year like '3rd' and dept_name not in (select dept_name from department where faculty like 'ME');

-- And, Or, Not
-- Title of all course taught in 3rd year in 'CSE' dept
select title from course where dept_name like 'CSE' and year like '3rd';
-- Title of all courses taught in 'CSE' dept or 'EEE' dept
select title from course where dept_name like 'CSE' or dept_name like 'EEE';
-- Name of instructors who are not in 'CSE' dept;
select name from instructor where not dept_name like 'CSE';
 
-- Some, All, Exist, Distinct
-- Name of students who have got D in some courses
select id from student where id = some(select id from takes where grade like 'D');
-- Name of instructors in each faculty having highest salary
select name from instructor where salary >= all (select salary from instructor);
-- Name of students who have got A in some courses
select name from student where exists (select * from takes where grade like 'A' and student.id = takes.id);
-- Name of all faculty
select distinct faculty from department;

-- Join
-- List of all advisors and their advisees of 'EEE' faculty
select i.name as Advisor, s.name as Advisee from student s join advisor a on s.id = a.s_id join instructor i on i.id = a.i_id where s.dept_name in (select dept_name from department where faculty like 'EEE');

-- View
-- Find Top 3 students of 'EEE' faculty
create or replace view results as select name, fCgpa(id) as cgpa from student where dept_name in (select dept_name from department where faculty like 'EEE') order by cgpa desc;
select * from results fetch next 3 rows only;

-- With
-- List of faculty which has the maximum average salary
with avg_salary(faculty, avg_sal) as (select faculty, avg(salary) from instructor i join department d on i.dept_name = d.dept_name group by faculty)
select faculty, avg_sal from avg_salary where avg_sal = (select max(avg_sal) from avg_salary);

-- PL/SQL
-- Find the salary of the advisor of student having ID = '19101'
set serveroutput on
declare
name instructor.name%type;
salary instructor.salary%type;
begin
select name, salary into name, salary from instructor where id = (select i_id from advisor where s_id = '19101');
dbms_output.put_line('Salary of ' || name || ': ' || salary);
end;
/
-- Find information of all 4 credit courses
set serveroutput on
declare
cursor c is select * from course where credit = 4.0; 
course_info course%rowtype;
begin
open c;
fetch c into course_info.course_id, course_info.title, course_info.dept_name, course_info.credit, course_info.semester, course_info.year;
while c%found loop
dbms_output.put_line('Course ID: ' || course_info.course_id || ', Title: ' || course_info.title || ', Dept. Name: ' || course_info.dept_name || ', Year: ' || course_info.year || ', Semester: ' || course_info.semester);
fetch c into course_info.course_id, course_info.title, course_info.dept_name, course_info.credit, course_info.semester, course_info.year;
end loop;
close c;
end;
/
-- Find the name of the students who are of 'EEE' faculty and got A in any course
set serveroutput on
declare
cursor c is select name from student where dept_name in (select dept_name from department where faculty like 'EEE') and id in (select id from takes where grade like 'A');
type namearray is varray(20) of student.name%type;
names namearray := namearray();
cnt number := 0;
begin
	for info in c loop
	names.extend;
	cnt := cnt + 1;
	names(cnt) := info.name;
	end loop;
	for i in 1 .. cnt loop
	dbms_output.put_line('Name: ' || names(i));
	end loop;
end;
/
-- Show the faculty name of each student
set serveroutput on
declare
cursor c is select * from student;
begin
	for info in c loop
	if info.id like '__1%' or info.id like '__4%' or info.id like '__7%'
		then 
		dbms_output.put_line('Name: ' || info.name || ', Faculty: CE');
	elsif info.id like '__2%' or info.id like '__5%' or info.id like '__8%'
		then 
		dbms_output.put_line('Name: ' || info.name || ', Faculty: EEE');
	else 
		dbms_output.put_line('Name: ' || info.name || ', Faculty: ME');
	end if;
	end loop;
end;
/

-- Procedure
-- Find all information of a student by a given ID
create or replace procedure fInfoProc(varId in student.id%type) as
cursor c is select * from takes where id = varId;
type courseIdArray is varray(10) of course.title%type;
type gradeArray is varray(10) of takes.grade%type;
info1 student%rowtype;
info2 instructor.name%type;
info3 takes%rowtype;
courses courseIdArray := courseIdArray();
grades gradeArray := gradeArray();
cnt integer := 0;
begin
    select name, dept_name, tot_cred into info1.name, info1.dept_name, info1.tot_cred from student where id = varId;
    select name into info2 from instructor where id = (select i_id from advisor where s_id = varId);
    for info in c loop
        courses.extend;
        grades.extend;
        cnt := cnt + 1;
        select title into courses(cnt) from course where course_id = info.course_id;
        grades(cnt) := info.grade;
    end loop;
    dbms_output.put_line('Name: ' || info1.name);
    dbms_output.put_line('Dept. Name: ' || info1.dept_name);
    dbms_output.put_line('Total Credit: ' || info1.tot_cred);
    dbms_output.put_line('Advisor Name: ' || info2);
    dbms_output.put_line('---<< Course Title with Grades >>---');
    for i in 1 .. cnt loop
        dbms_output.put_line('Course: ' || courses(i) || ', Grade: ' || grades(i));
    end loop;
end;
/
begin
finfoproc(19101);
end;
/

-- Function
-- Find the result of student by a given ID
create or replace function fCgpa(varId in student.id%type) return number as
cursor c is select * from takes where id = varId;
grad numeric(2, 1);
cred numeric(2, 1);
tot_grad numeric(4, 2) := 0;
tot_cred numeric(4, 2) := 0;
cgpa numeric(4, 2) := 0;
begin
for info in c loop
    if info.grade like 'A' 
        then
        grad := 4.0;
    elsif info.grade like 'B'
        then 
        grad := 3.5;
    elsif info.grade like 'C'
        then
        grad := 3.0;
    elsif info.grade like 'D'
        then 
        grad := 2.5;
    else
        grad := 0;
    end if;
    select credit into cred from course where info.course_id like course.course_id;
    tot_grad := tot_grad + cred * grad;
    tot_cred := tot_cred + cred;
end loop;
cgpa := tot_grad / tot_cred;
return cgpa;
end;
/
declare
vId student.id%type := 19101;
cgpa numeric(4, 2) := 0;
name student.name%type;
begin
select name into name from student where id = vId;
cgpa := fCgpa(vId);
dbms_output.put_line('Name: ' || name || ', CGPA: ' || cgpa);
end;
/




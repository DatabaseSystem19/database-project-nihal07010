drop table advisor;
drop table takes;
drop table teaches;
drop table course;
drop table instructor;
drop table student;
drop table department;

create table department(
    dept_name varchar(5),
    no_of_classrooms number(2, 0) check (no_of_classrooms > 0),
    faculty varchar(5) check(faculty in ('CE', 'EEE', 'ME')),
    primary key(dept_name)
);

create table student(
    id varchar(5),
    name varchar(40) not null,
    dept_name varchar(5),
    tot_cred number(5, 2) check(tot_cred >= 0),
    primary key(id),
    foreign key(dept_name) references department(dept_name) on delete set null
);

create table instructor(
    id varchar(5),
    name varchar(40) not null,
    dept_name varchar(5),
    salary number(8, 2) check(salary >= 20000),
    primary key(id),
    foreign key(dept_name) references department(dept_name) on delete set null
);

create table course(
    course_id varchar(10),
    title varchar(60) not null,
    dept_name varchar(5),
    credit number(3, 2) check (credit >= 0.75),
    semester varchar(3) check (semester in ('1st', '2nd')),
    year varchar(3) check (year in ('1st', '2nd', '3rd', '4th')),
    primary key(course_id),
    foreign key(dept_name) references department(dept_name) on delete set null
);

create table teaches(
    id varchar(5),
    course_id varchar(10),
    primary key(id, course_id),
    foreign key(id) references instructor(id) on delete cascade,
    foreign key(course_id) references course(course_id) on delete cascade
);

create table takes(
    id varchar(5),
    course_id varchar(10),
    grade varchar(1) check (grade in ('A', 'B', 'C', 'D', 'F')),
    primary key(id, course_id),
    foreign key(id) references student(id) on delete cascade,
    foreign key(course_id) references course(course_id) on delete cascade
);

create table advisor(
    s_id varchar(5),
    i_id varchar(5),
    primary key(s_id),
    foreign key(s_id) references student(id) on delete cascade,
    foreign key(i_id) references instructor(id) on delete set null
);
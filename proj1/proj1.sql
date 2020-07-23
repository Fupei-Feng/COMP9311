-- comp9311 19s1 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(unswid, longname)
as
 	SELECT DISTINCT rooms.unswid, rooms.longname
 	FROM rooms, room_types, semesters, classes, courses, subjects
 	WHERE  rooms.rtype = room_types.id and room_types.description = 'Laboratory' and rooms.id = room and course = courses.id  
  			and courses.subject = subjects.id and subjects.code = 'COMP9311' and courses.semester = semesters.id 
   			and semesters.year = 2013 and semesters.term = 'S1';


--... SQL statements, possibly using other views/functions defined by you ...


-- Q2:
create or replace view Q2(unswid,name)
as
    SELECT p2.unswid, p2.name
    FROM people p1, people p2, course_enrolments, course_staff
    WHERE p1.name = 'Bich Rae' and p1.id = course_enrolments.student 
          and course_staff.staff = p2.id
          and course_enrolments.course = course_staff.course ;
--... SQL statements, possibly using other views/functions defined by you ...



-- Q3:
create or replace view Q3_1(student, semester)
as
    (SELECT course_enrolments.student, courses.semester
 	FROM course_enrolments, courses, subjects, semesters
	WHERE subjects.code = 'COMP9021' and subjects.id = courses.subject 
    		and courses.id = course_enrolments.course and semesters.id = courses.semester)
INTERSECT
 	(SELECT course_enrolments.student, courses.semester
 	FROM course_enrolments, courses, subjects, semesters
 	WHERE subjects.code = 'COMP9311' and subjects.id = courses.subject 
    		and courses.id =course_enrolments.course and semesters.id = courses.semester) ;

create or replace view Q3(unswid, name)
as
 	SELECT people.unswid, people.name
 	FROM Q3_1 std, students, people
 	WHERE std.student = people.id and students.stype = 'intl' and students.id = std.student ;
--... SQL statements, possibly using other views/functions defined by you ...




-- -- Q4:
create or replace view Q4_1(program, intl_num)
as
 	SELECT DISTINCT program_enrolments.program, count(distinct program_enrolments.student)
 	FROM program_enrolments, students
 	WHERE students.stype = 'intl' and students.id = program_enrolments.student
 	GROUP BY program_enrolments.program ;

create or replace view Q4_2(program, allstudents_num)
as
 	SELECT DISTINCT program_enrolments.program, count(distinct program_enrolments.student)
 	FROM program_enrolments
 	GROUP BY program_enrolments.program ;

create or replace view Q4(code,name)
as
 	SELECT DISTINCT programs.code, programs.name
 	FROM programs, Q4_1, Q4_2
 	WHERE Q4_2.program = Q4_1.program
 	 		and Q4_1.intl_num/(Q4_2.allstudents_num)::numeric >= 0.3 
 			and Q4_1.intl_num/(Q4_2.allstudents_num)::numeric <= 0.7 and Q4_1.program = programs.id ;

-- --... SQL statements, possibly using other views/functions defined by you ...


-- --Q5:
create or replace view Q5_1(course_id, min_mark)
as
 	SELECT courses.id, MIN(course_enrolments.mark)
 	FROM courses, course_enrolments
 	WHERE course_enrolments.course = courses.id
 	GROUP BY courses.id
 	Having count(course_enrolments.mark) >= 20 ;

create or replace view Q5_2(id)
as
 	SELECT courses.id 
 	FROM Q5_1, courses, course_enrolments
 	WHERE Q5_1.course_id = courses.id and course_enrolments.mark = Q5_1.min_mark 
 	 and course_enrolments.course = courses.id
 	 and Q5_1.min_mark = (SELECT MAX(Q5_1.min_mark) FROM Q5_1) ;

create or replace view Q5(code,name,semester)
as
 	SELECT subjects.code, subjects.name, semesters.name
	 FROM Q5_2, semesters, subjects, courses
 	 WHERE Q5_2.id = courses.id and courses.subject = subjects.id 
 	 and courses.semester = semesters.id ;
-- --... SQL statements, possibly using other views/functions defined by you ...


-- -- Q6:
create or replace view Q6_1(q1)
as
    SELECT count(DISTINCT s1.id)
    FROM streams, stream_enrolments, semesters, program_enrolments, students s1
    WHERE semesters.year = '2010' and semesters.term = 'S1' 
 			and semesters.id = program_enrolments.semester and s1.stype = 'local' 
			and s1.id = program_enrolments.student and program_enrolments.id = stream_enrolments.partof
            and stream_enrolments.stream = streams.id and streams.name = 'Chemistry' ;

create or replace view Q6_2(q2)
as
    SELECT count(DISTINCT s2.id)
    FROM orgunits, program_enrolments, programs, semesters, students s2
    WHERE semesters.year = '2010' and semesters.term = 'S1' and semesters.id = program_enrolments.semester 
            and s2.stype = 'intl' and s2.id = program_enrolments.student and program_enrolments.program = programs.id
  			and programs.offeredby = orgunits.id and orgunits.name = 'Faculty of Engineering' ;

create or replace view Q6_3(q3)
as
	SELECT count(DISTINCT s3.id)
	FROM semesters, students s3, programs, program_enrolments
	WHERE semesters.year = '2010' and semesters.term = 'S1' and semesters.id = program_enrolments.semester
  			and s3.id = program_enrolments.student and program_enrolments.program = programs.id
  			and programs.code = '3978' ;

create or replace view Q6(num1, num2, num3)
as
 	SELECT Q6_1.q1, Q6_2.q2, Q6_3.q3
 	FROM Q6_1, Q6_2, Q6_3 ;
-- --... SQL statements, possibly using other views/functions defined by you ...


-- -- Q7:
create or replace view Q7(name, school, email, starting, num_subjects)
as
 	SELECT people.name, orgunits.longname, people.email, affiliations.starting, count(DISTINCT courses.subject)
 	FROM affiliations, course_staff, courses, orgunit_types, orgunits, people, staff_roles
 	WHERE staff_roles.name like 'Dean%' and staff_roles.id = affiliations.role and affiliations.isprimary 
  			and affiliations.orgunit = orgunits.id and orgunits.utype = orgunit_types.id and orgunit_types.name = 'Faculty' 
  			and affiliations.staff = course_staff.staff and affiliations.staff IN (SELECT course_staff.staff FROM course_staff) 
  			and course_staff.course = courses.id and course_staff.staff = people.id
 	GROUP BY people.name, orgunits.longname, people.email, affiliations.starting ;
-- --... SQL statements, possibly using other views/functions defined by you ...


-- -- Q8: 
create or replace view Q8_1(courses_id)
as
 	SELECT DISTINCT course_enrolments.course
 	FROM course_enrolments
 	GROUP BY course_enrolments.course
 	Having count(course_enrolments.student) >= 20;

create or replace view Q8_2(sbj_id)
as
 	SELECT courses.subject
 	FROM Q8_1, courses
 	WHERE Q8_1.courses_id = courses.id 
 	GROUP BY courses.subject
 	Having count(DISTINCT courses.id) >= 20;

create or replace view Q8(subject)
as
 	SELECT DISTINCT concat(subjects.code, ' ', subjects.name)
 	FROM subjects, Q8_2
 	WHERE Q8_2.sbj_id = subjects.id;
-- --... SQL statements, possibly using other views/functions defined by you ...


-- -- Q9:
create or replace view Q9_1(org_name, year, num)
as 
    SELECT orgunits.longname, semesters.year, count(DISTINCT students.id)
 	FROM programs, program_enrolments, orgunits, semesters, students
 	WHERE program_enrolments.student = students.id and students.stype = 'intl' and program_enrolments.program = programs.id
 	and program_enrolments.semester = semesters.id and programs.offeredby = orgunits.id
 	GROUP BY orgunits.longname, semesters.year;

create or replace view Q9_2(unit, num)
as
 	SELECT Q9_1.org_name, MAX(Q9_1.num)
 	FROM Q9_1
 	GROUP BY Q9_1.org_name;

create or replace view Q9(year, num, unit)
as
 	SELECT Q9_1.year, Q9_2.num, Q9_2.unit
 	FROM Q9_1, Q9_2
 	WHERE Q9_2.num = Q9_1.num and Q9_2.unit = Q9_1.org_name;
-- --... SQL statements, possibly using other views/functions defined by you ...


-- -- Q10:
create or replace view Q10_1(std_id, avg_mark)
as
 	SELECT course_enrolments.student, AVG(course_enrolments.mark)
 	FROM course_enrolments, courses, semesters
 	WHERE semesters.year = '2011' and semesters.term = 'S1' and course_enrolments.mark >= 0
  			and courses.semester = semesters.id and course_enrolments.course = courses.id 
 	GROUP BY course_enrolments.student
 	Having count(course_enrolments.course) >= 3;

create or replace view Q10(unswid,name,avg_mark)
as
 	SELECT people.unswid, people.name, cast(Q10_1.avg_mark as numeric(4,2))
 	FROM people, Q10_1
 	WHERE Q10_1.std_id = people.id and Q10_1.avg_mark IN (SELECT Q10_1.avg_mark FROM Q10_1 ORDER BY Q10_1.avg_mark desc LIMIT 10)
 	ORDER BY Q10_1.avg_mark desc;
-- --... SQL statements, possibly using other views/functions defined by you ...


-- -- Q11:
create or replace view Q11_1(std_id, num_courses)
as
 	SELECT students.id, count(DISTINCT courses.id)
 	FROM courses, course_enrolments, semesters, students, people
 	WHERE semesters.year = '2011' and semesters.term = 'S1' and people.unswid >= 3130000 and people.unswid < 3140000  
  			and people.id = students.id and course_enrolments.mark >= 0 and course_enrolments.course = courses.id and courses.semester = semesters.id
  			and course_enrolments.student = students.id
 	GROUP BY students.id;

create or replace view Q11_2(std_id, passed_num_courses)
as 
 	SELECT Q11_1.std_id, coalesce( (count( DISTINCT b.id )), 0 ) 
 	FROM Q11_1
 	LEFT JOIN (SELECT course_enrolments.student, courses.id 
    FROM courses, course_enrolments, students, semesters, people 
    WHERE semesters.year= '2011' and semesters.term = 'S1' and people.unswid >= 3130000 and people.unswid < 3140000 
      		and people.id = students.id and course_enrolments.mark >= 50 and course_enrolments.course = courses.id 
     		and courses.semester = semesters.id) b ON b.student = Q11_1.std_id
 	GROUP BY Q11_1.std_id;

create or replace view Q11(unswid, name, academic_standing)
as
 SELECT people.unswid, people.name,
  (case 
   when Q11_2.passed_num_courses*1.0/Q11_1.num_courses*1.0 > 0.5 then 'Good'
   when Q11_2.passed_num_courses = 0 and Q11_1.num_courses > 1 then 'Probation'
   else 'Referral'
   end)academic_standing
 FROM Q11_1, Q11_2, people
 WHERE Q11_1.std_id = Q11_2.std_id and Q11_1.std_id = people.id;
-- --... SQL statements, possibly using other views/functions defined by you ...


-- -- Q12:
create or replace view Q12_1(sbj_code)
as
	SELECT subjects.code
	FROM courses, semesters, subjects
	WHERE semesters.year::integer >= 2003 and semesters.year::integer <= 2012 and semesters.term like 'S%' 
  		  and courses.semester = semesters.id 
          and subjects.id = courses.subject
  		  and subjects.code like 'COMP90%'
    GROUP BY subjects.code
    Having count(courses.semester) = 20;

create or replace view Q12_2(id, code, name, year, term, num_std)
as 
    SELECT courses.id, code, subjects.name, year, term, count(course_enrolments.mark)
    FROM courses, semesters, subjects, Q12_1, course_enrolments
    WHERE semesters.year::integer >= 2003 and semesters.year::integer <= 2012 and semesters.term like 'S%' and subjects.code = Q12_1.sbj_code
  			and semesters.id = courses.semester and subjects.id = courses.subject and courses.id = course_enrolments.course 
  			and course_enrolments.mark >= 0
    GROUP BY courses.id, code,subjects.name, year, term; 


create or replace view Q12_3(id, code, name, year, term, passed_num_std)
as 
 	SELECT Q12_2.id, Q12_2.code, Q12_2.name, Q12_2.year, Q12_2.term, coalesce(count(student),0)
 	FROM Q12_2 LEFT JOIN   (SELECT Q12_2.id, student
       						FROM courses, semesters, subjects, course_enrolments, Q12_2
       						WHERE Q12_2.id = course_enrolments.course and semesters.id = courses.semester and subjects.id = courses.subject and courses.id = course_enrolments.course 
        					and course_enrolments.mark >= 50) a on a.id = Q12_2.id
 	GROUP BY Q12_2.id, Q12_2.code, Q12_2.name, Q12_2.year, Q12_2.term;

create or replace view Q12(code, name, year, s1_ps_rate, s2_ps_rate)
as
 	SELECT q1.code, q1.name, substr(q1.year::text,3,2) as year, sum((case when q1.term = 'S1' then (q2.passed_num_std::float/q1.num_std::float)::numeric(4,2) end)) as s1_ps_rate, 
  			sum((case when q1.term = 'S2' then q2.passed_num_std::float/q1.num_std::float end))::numeric(4,2) as s2_ps_rate 
 	FROM Q12_2 q1, Q12_3 q2
 	WHERE q1.code = q2.code and q1.name = q2.name and q1.year = q2.year and q1.term = q2.term
 	GROUP BY q1.code, q1.name, q1.year;
-- --... SQL statements, possibly using other views/functions defined by you ...


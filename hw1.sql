/*
-- ДОМАШНЕЕ ЗАДАНИЕ.--
1. Создать таблицу courses, в которой будут храниться курсы студентов. Поля -- id, name, is_exam, min_grade, max_grade.--
2. Создать таблицу groups, в которой будут храниться данные групп. Поля -- id, full_name, short_name, students_ids.--
3. Создать таблицу students, в которой будут храниться данные студентов. Поля -- id, first_name, last_name, group_id, courses_ids.--
4. Создать таблицу любого курса, в котором будут поля -- student_id, grade, grade_str с учетом min_grade и max_grade--
-- Каждую таблицу нужно заполнить соответствующими данные, показать процедуры фильтрации и агрегации.
*/

/*
1. Создать таблицу courses, в которой будут храниться курсы студентов.
Поля -- id, name, is_exam, min_grade, max_grade.--
*/

CREATE TABLE courses(
	id SERIAL PRIMARY KEY,
	name CHARACTER VARYING(30),
	is_exam BOOLEAN,
	min_grade SMALLINT,
	max_grade SMALLINT
);

/*
2. Создать таблицу groups, в которой будут храниться данные групп.
Поля -- id, full_name, short_name, students_ids.--
*/

CREATE TABLE groups(
	id SERIAL PRIMARY KEY,
	full_name CHARACTER VARYING(250),
	short_name CHARACTER VARYING(250),
	students_ids TEXT
);

/*
3. Создать таблицу students, в которой будут храниться данные студентов.
Поля -- id, first_name, last_name, group_id, courses_ids.--
*/

CREATE TABLE students(
	id SERIAL PRIMARY KEY,
	first_name CHARACTER VARYING(250),
	last_name CHARACTER VARYING(250),
	group_id INTEGER,
	courses_ids TEXT
);

/*
4. Создать таблицу любого курса, в котором будут
поля -- student_id, grade, grade_str с учетом min_grade и max_grade--
-- Каждую таблицу нужно заполнить соответствующими данные, показать процедуры фильтрации и агрегации.
*/

CREATE TABLE course_grades (
    student_id INTEGER,
    course_id INTEGER,
    grade INTEGER,
	CHECK (grade >= 50 AND grade <= 100),
    grade_str VARCHAR(4),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- Заполнение

INSERT INTO courses (id, name, is_exam, min_grade, max_grade) VALUES
(1, 'Mathematics', TRUE, 50, 100),
(2, 'Physics', TRUE, 50, 100),
(3, 'Chemistry', FALSE, 50, 100);

INSERT INTO groups (id, full_name, short_name, students_ids) VALUES
(1, 'Group A', 'GA', '1, 2'),
(2, 'Group B', 'GB', '3');

INSERT INTO students (id, first_name, last_name, group_id, courses_ids) VALUES
(1, 'John', 'Doe', 1, '1,2'),
(2, 'Jane', 'Smith', 1, '1'),
(3, 'Alice', 'Johnson', 2, '2,3');

INSERT INTO course_grades (student_id, course_id, grade, grade_str) VALUES
(1, 1, 85, 'B'),
(1, 2, 90, 'A'),
(2, 1, 70, 'C'),
(3, 2, 60, 'D'),
(3, 3, 55, 'D');

-- Показ процедуры фильтрации и агрегации.

SELECT * FROM students WHERE group_id = 1;

SELECT course_id, AVG(grade) AS average_grade
FROM course_grades
GROUP BY course_id;

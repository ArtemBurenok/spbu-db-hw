/*
ДОМАШНЕЕ ЗАДАНИЕ 2

1. Создать промежуточные таблицы:
student_courses — связывает студентов с курсами. Поля: id, student_id, course_id.
group_courses — связывает группы с курсами. Поля: id, group_id, course_id.
Заполнить эти таблицы данными, чтобы облегчить работу с отношениями «многие ко многим».
Должно гарантироваться уникальное отношение соответствующих полей (ключевое слово UNIQUE).

Удалить неактуальные, после модификации структуры, поля (пример: courses_ids) SQL запросом, (запрос ALTER TABLE).

2. Добавить в таблицу courses уникальное ограничение на поле name, чтобы не допустить дублирующих названий курсов.
Создать индекс на поле group_id в таблице students и объяснить, как индексирование влияет на производительность 
запросов (Комментариями в коде).

3. Написать запрос, который покажет список всех студентов с их курсами. Найти студентов, у которых средняя 
оценка по курсам выше, чем у любого другого студента в их группе. (Ключевые слова JOIN, GROUP BY, HAVING)

4. Подсчитать количество студентов на каждом курсе.
Найти среднюю оценку на каждом курсе.
*/

/*
1. Создать промежуточные таблицы:
student_courses — связывает студентов с курсами. Поля: id, student_id, course_id.
group_courses — связывает группы с курсами. Поля: id, group_id, course_id.
Заполнить эти таблицы данными, чтобы облегчить работу с отношениями «многие ко многим».
Должно гарантироваться уникальное отношение соответствующих полей (ключевое слово UNIQUE).

Удалить неактуальные, после модификации структуры, поля (пример: courses_ids) SQL запросом, (запрос ALTER TABLE).
*/

CREATE TABLE student_courses(
	id SERIAL PRIMARY KEY UNIQUE,
	student_id INTEGER, 
	course_id INTEGER,
	grade INTEGER,
	CHECK (grade >= 50 AND grade <= 100),
    grade_str VARCHAR(4),
	FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

CREATE TABLE group_courses(
	id SERIAL PRIMARY KEY UNIQUE,
	group_id INTEGER, 
	course_id INTEGER,
	FOREIGN KEY (group_id) REFERENCES groups(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

INSERT INTO student_courses(id, student_id, course_id, grade, grade_str) VALUES
(1, 1, 1, 75, '75'), (2, 1, 2, 80, '80'),
(3, 2, 1, 56, '56'), (4, 3, 2, 98, '98'), (5, 3, 3, 63, '63');

INSERT INTO group_courses(id, group_id, course_id) VALUES
(1, 1, 1), (2, 1, 2),
(3, 2, 3), (4, 2, 2);

ALTER TABLE students DROP COLUMN courses_ids;
ALTER TABLE groups DROP COLUMN students_ids;

/*
2. Добавить в таблицу courses уникальное ограничение на поле name, чтобы не допустить дублирующих названий курсов.
Создать индекс на поле group_id в таблице students и объяснить, как индексирование влияет на производительность 
запросов (Комментариями в коде).
*/

ALTER TABLE courses ADD UNIQUE (name);
CREATE INDEX students_index ON students(group_id);

/*
Индексирование улучшает производительность запросов, так как позволяет базе данных быстрее находить 
необходимые данные вместо полного сканирования таблицы. Индексы создают структуры данных, которые упрощают поиск, 
сортировку и фильтрацию. Однако создание и поддержка индексов требуют дополнительных ресурсов.
*/


/*
3. Написать запрос, который покажет список всех студентов с их курсами. Найти студентов, у которых средняя 
оценка по курсам выше, чем у любого другого студента в их группе. (Ключевые слова JOIN, GROUP BY, HAVING)
*/

SELECT students.id, first_name, last_name, course_id, courses.name FROM students 
INNER JOIN student_courses ON students.id = student_courses.student_id
INNER JOIN courses ON student_courses.course_id = courses.id
LIMIT 10;

SELECT students.id, AVG(student_courses.grade) AS average_grade
FROM students 
INNER JOIN student_courses ON students.id = student_courses.student_id
INNER JOIN courses ON student_courses.course_id = courses.id
GROUP BY students.id
HAVING AVG(student_courses.grade) > (
    SELECT MAX(avg_grade)
    FROM (
        SELECT AVG(g2.grade) AS avg_grade
        FROM students s2
        JOIN student_courses g2 ON s2.id = g2.student_id
        WHERE s2.group_id = students.group_id AND s2.id <> students.id
        GROUP BY s2.id
    ) AS other_students
)

/*
4. Подсчитать количество студентов на каждом курсе.
Найти среднюю оценку на каждом курсе.
*/

SELECT student_courses.course_id, COUNT(*), AVG(grade) FROM students INNER JOIN student_courses 
ON students.id = student_courses.student_id
GROUP BY student_courses.course_id

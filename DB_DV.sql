-- ТАЖЕ СХЕМА НО В СТРУКТУРЕ DATA VAULT

-- Хабы
-- Хаб типов экзаменов (содержит список уникальных экзаменов)
CREATE TABLE hub_exam_types (
exam_type_pk VARCHAR(32) PRIMARY KEY,
exam_type_id INT NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(256) NOT NULL
);

-- Хаб предметов (содержит уникальные дисциплины/предметы)
CREATE TABLE hub_subjects (
subject_pk VARCHAR(32) PRIMARY KEY,
subject_id INT NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(128) NOT NULL
);

-- Хаб курсов (содержит список учебных курсов)
CREATE TABLE hub_courses (
course_pk VARCHAR(32) PRIMARY KEY,
course_id INT NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(128) NOT NULL
);

-- Хаб преподавателей (содержит уникальных преподавателей)
CREATE TABLE hub_teachers (
teacher_pk VARCHAR(32) PRIMARY KEY,
teacher_id INT NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(128) NOT NULL
);

-- Хаб тем (содержит список тем для изучения)
CREATE TABLE hub_topics (
topic_pk VARCHAR(32) PRIMARY KEY,
topic_id INT NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(128) NOT NULL
);

-- Хаб шагов подготовки (содержит этапы подготовки к экзамену)
CREATE TABLE hub_preparation_steps (
preparation_step_pk VARCHAR(32) PRIMARY KEY,
preparation_step_id INT NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(128) NOT NULL
);

-- Сателлиты
-- Сателлит типов экзаменов (хранит наименование и детали экзамена)
CREATE TABLE sat_exam_types (
diff_hash VARCHAR(32) NOT NULL,
exam_type_pk VARCHAR(32) NOT NULL,
exam_name VARCHAR(255) NOT NULL,
loaded_time TIMESTAMPTZ NOT NULL,

PRIMARY KEY (exam_type_pk, loaded_time),

CONSTRAINT fk_exam_type_pk
FOREIGN KEY (exam_type_pk)
REFERENCES hub_exam_types
);

-- Сателлит предметов (хранит название предмета и даты обработки/загрузки)
CREATE TABLE sat_subjects (
diff_hash VARCHAR(32) NOT NULL,
subject_pk VARCHAR(32) NOT NULL,
subject_name VARCHAR(64) NOT NULL,
date_proceeding TIMESTAMPTZ NOT NULL,
date_loaded TIMESTAMPTZ NOT NULL,

PRIMARY KEY (subject_pk, date_loaded),

CONSTRAINT fk_subject_pk
FOREIGN KEY (subject_pk)
REFERENCES hub_subjects (subject_pk)
);

-- Сателлит курсов (хранит информацию о стоимости, описании и названии курса)
CREATE TABLE sat_courses (
diff_hash VARCHAR(32) NOT NULL,
course_pk VARCHAR(32) NOT NULL,
course_name VARCHAR(255) NOT NULL,
price DECIMAL(8,2) NOT NULL,
description TEXT,
date_loaded TIMESTAMPTZ NOT NULL,

PRIMARY KEY (course_pk, date_loaded),

CONSTRAINT fk_course_pk
FOREIGN KEY (course_pk)
REFERENCES hub_courses(course_pk)
);

-- Сателлит преподавателей (хранит персональные данные, рейтинг и отзывы о преподавателе)
CREATE TABLE sat_teachers (
diff_hash VARCHAR(32) NOT NULL,
teacher_pk VARCHAR(32) NOT NULL,
name VARCHAR(64) NOT NULL,
second_name VARCHAR(64) NOT NULL,
phone_number VARCHAR(20),
rate INT CHECK(rate BETWEEN 1 AND 5),
feedback TEXT,
date_loaded TIMESTAMPTZ NOT NULL,

PRIMARY KEY (teacher_pk, date_loaded),

CONSTRAINT fk_teacher_pk
FOREIGN KEY (teacher_pk)
REFERENCES hub_teachers(teacher_pk)
);

-- Сателлит тем (хранит название темы и уровень её важности)
CREATE TABLE sat_topics (
diff_hash VARCHAR(32) NOT NULL,
topic_pk VARCHAR(32) NOT NULL,
title VARCHAR(255) NOT NULL,
importance_level VARCHAR(255) NOT NULL,
date_loaded TIMESTAMPTZ NOT NULL,

PRIMARY KEY (topic_pk, date_loaded),

CONSTRAINT fk_topic_pk
FOREIGN KEY (topic_pk)
REFERENCES hub_topics (topic_pk)
);

-- Сателлит шагов подготовки (хранит порядковый номер, тип действия, описание и статус выполнения шага)
CREATE TABLE sat_preparation_steps(
diff_hash VARCHAR(32) NOT NULL,
preparation_step_pk VARCHAR(32) NOT NULL,
step_number INT NOT NULL,
action_type VARCHAR(50) NOT NULL,
description TEXT,
is_completed BOOLEAN NOT NULL,
date_loaded TIMESTAMPTZ NOT NULL,

PRIMARY KEY (preparation_step_pk, date_loaded),

CONSTRAINT fk_preparation_step_pk
FOREIGN KEY (preparation_step_pk)
REFERENCES hub_preparation_steps(preparation_step_pk)
);


-- Линки
-- Линк связывает курсы с преподавателями, которые их ведут
CREATE TABLE link_course_teacher (
link_pk VARCHAR(32) PRIMARY KEY,
course_pk VARCHAR(32) NOT NULL,
teacher_pk VARCHAR(32) NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(128) NOT NULL,

CONSTRAINT uq_link_course_teacher UNIQUE (course_pk, teacher_pk),

CONSTRAINT fk_course_pk
FOREIGN KEY (course_pk)
REFERENCES hub_courses(course_pk),

CONSTRAINT fk_teacher_pk
FOREIGN KEY (teacher_pk)
REFERENCES hub_teachers(teacher_pk)
);

-- Линк связывает типы экзаменов с изучаемыми предметами
CREATE TABLE link_subject_exam_type (
link_pk VARCHAR(32) PRIMARY KEY,
exam_type_pk VARCHAR(32) NOT NULL,
subject_pk VARCHAR(32) NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(128) NOT NULL,

CONSTRAINT uq_link_subject_exam_type UNIQUE (exam_type_pk, subject_pk),

CONSTRAINT fk_exam_type_pk
FOREIGN KEY (exam_type_pk)
REFERENCES hub_exam_types(exam_type_pk),

CONSTRAINT fk_subject_pk
FOREIGN KEY (subject_pk)
REFERENCES hub_subjects (subject_pk)
);

-- Линк связывает темы с конкретными шагами подготовки
CREATE TABLE link_topics_preparation_steps (
link_pk VARCHAR(32) PRIMARY KEY,
topic_pk VARCHAR(32) NOT NULL,
preparation_step_pk VARCHAR(32) NOT NULL,
loaded_date TIMESTAMPTZ NOT NULL,
recorded_source VARCHAR(128) NOT NULL,

CONSTRAINT uq_link_topic_preparation_step UNIQUE (topic_pk, preparation_step_pk),

CONSTRAINT fk_topic_pk
FOREIGN KEY (topic_pk)
REFERENCES hub_topics (topic_pk),

CONSTRAINT fk_preparation_step_pk
FOREIGN KEY (preparation_step_pk)
REFERENCES hub_preparation_steps(preparation_step_pk)
);

-- 4. Линк Предмет <-> Темы (связывает предмет с входящими в него темами)
CREATE TABLE link_subject_topics (
    link_pk VARCHAR(32) PRIMARY KEY,
    subject_pk VARCHAR(32) NOT NULL,
    topic_pk VARCHAR(32) NOT NULL,
    loaded_date TIMESTAMPTZ NOT NULL,
    recorded_source VARCHAR(128) NOT NULL,

    CONSTRAINT uq_link_subject_topics UNIQUE (subject_pk, topic_pk),

    CONSTRAINT fk_subject_pk
        FOREIGN KEY (subject_pk)
        REFERENCES hub_subjects(subject_pk),

    CONSTRAINT fk_topic_pk
        FOREIGN KEY (topic_pk)
        REFERENCES hub_topics(topic_pk)
);

-- 5. Линк Предмет <-> Курсы (связывает предмет с доступными курсами по нему)
CREATE TABLE link_subject_courses (
    link_pk VARCHAR(32) PRIMARY KEY,
    subject_pk VARCHAR(32) NOT NULL,
    course_pk VARCHAR(32) NOT NULL,
    loaded_date TIMESTAMPTZ NOT NULL,
    recorded_source VARCHAR(128) NOT NULL,

    CONSTRAINT uq_link_subject_courses UNIQUE (subject_pk, course_pk),

    CONSTRAINT fk_subject_pk
        FOREIGN KEY (subject_pk)
        REFERENCES hub_subjects(subject_pk),

    CONSTRAINT fk_course_pk
        FOREIGN KEY (course_pk)
        REFERENCES hub_courses(course_pk)
);
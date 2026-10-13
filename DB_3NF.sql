-- 1. Справочник типов экзаменов (Зачет, Экзамен, Диф. зачет)
CREATE TABLE exam_types (
    exam_type_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    exam_name VARCHAR(255) NOT NULL
);

-- 2. Таблица предметов для сдачи
CREATE TABLE subjects (
    subject_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subject_name VARCHAR(64) NOT NULL,
    exam_type_id INT NOT NULL,
    date_proceeding TIMESTAMP NOT NULL,

    CONSTRAINT fk_subject_types
        FOREIGN KEY (exam_type_id) REFERENCES exam_types(exam_type_id) ON DELETE RESTRICT
);

-- 3. Темы / вопросовые билеты по предмету (Бизнес-логика порядка подготовки)
CREATE TABLE topics (
    topic_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subject_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    importance_level INT DEFAULT 3 CHECK (importance_level BETWEEN 1 AND 5),

    CONSTRAINT fk_topic_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
);

-- 4. Конкретные шаги алгоритма подготовки (Сам "Порядок подготовки")
CREATE TABLE preparation_steps (
    step_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    topic_id INT NOT NULL,
    step_number INT NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- 'Теория', 'Практика', 'Повторение'
    description TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_step_topic
        FOREIGN KEY (topic_id) REFERENCES topics(topic_id) ON DELETE CASCADE
);

-- 5. Курсы для подготовки к предметам
CREATE TABLE courses (
    course_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    course_name VARCHAR(255) NOT NULL,
    price DECIMAL(8, 2) NOT NULL,
    subject_id INT NOT NULL,
    description TEXT,

    CONSTRAINT fk_course_for_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE RESTRICT
);

-- 6. Оценки и отзывы о курсах
CREATE TABLE course_rates (
    course_rate_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id INT NOT NULL,
    rate INT NOT NULL CHECK (rate BETWEEN 1 AND 5),
    feedback TEXT,

    CONSTRAINT fk_course_rate
        FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

-- 7. Преподаватели
CREATE TABLE teachers (
    teacher_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    second_name VARCHAR(64) NOT NULL,
    phone_number VARCHAR(20)
);

-- 8. Оценки преподавателей
CREATE TABLE teachers_rates (
    teacher_rate_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    teacher_id INT NOT NULL,
    rate INT NOT NULL CHECK (rate BETWEEN 1 AND 5),
    feedback TEXT,

    CONSTRAINT fk_teacher_rate
        FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE
);

-- 9. Промежуточная таблица связи N:M (Курсы <-> Преподаватели)
CREATE TABLE courses_have_teachers (
    course_id INT,
    teacher_id INT,

    PRIMARY KEY(course_id, teacher_id),
    
    CONSTRAINT fk_course_has_teacher
        FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
        
    CONSTRAINT fk_teacher_has_courses
        FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE
);

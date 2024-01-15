CREATE TYPE ASKED_QUESTION AS (
    question VARCHAR(255),
    answer TEXT
);  

CREATE TYPE TUTORIAL AS (
    title VARCHAR(255),
    description TEXT,
    url VARCHAR(255),
    is_active BOOLEAN
);

CREATE TYPE NORMATIVE AS (
    title VARCHAR(255),
    description TEXT,
    url VARCHAR(255),
    is_active BOOLEAN
);

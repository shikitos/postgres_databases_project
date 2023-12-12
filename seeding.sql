DROP SCHEMA IF EXISTS Project CASCADE;

CREATE SCHEMA IF NOT EXISTS Project;

CREATE TABLE IF NOT EXISTS Project.Users
(
    user_id            SERIAL PRIMARY KEY,
    user_email         VARCHAR(100) UNIQUE NOT NULL,
    user_password      VARCHAR(255)        NOT NULL,
    user_name          VARCHAR(100),
    user_username      VARCHAR(100),
    user_surname       VARCHAR(100),
    user_date_of_birth DATE,
    user_phone         VARCHAR(20),
    user_address       VARCHAR(200),
    user_created_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_is_active     BOOLEAN                  DEFAULT TRUE,
    user_last_login    TIMESTAMP WITH TIME ZONE,
    user_avatar        VARCHAR(255)
);

-- Create function that will generate random user_username for Project.Users
CREATE OR REPLACE FUNCTION set_default_username()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.user_username := 'User_' || NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_default_username_trigger
    BEFORE INSERT
    ON Project.Users
    FOR EACH ROW
EXECUTE FUNCTION set_default_username();

CREATE TABLE IF NOT EXISTS Project.User_Settings
(
    user_settings_id                  INT PRIMARY KEY,
    user_settings_language            VARCHAR(10) NOT NULL DEFAULT 'en',
    user_settings_allow_notifications BOOLEAN     NOT NULL DEFAULT TRUE,
    user_settings_privacy             JSONB,
    user_settings_preferred_currency  VARCHAR(5)  NOT NULL DEFAULT 'USD',
    user_settings_timezone            VARCHAR(50) NOT NULL DEFAULT 'UTC',
    user_settings_email_frequency     INT         NOT NULL DEFAULT 0,
    user_settings_theme_preference    VARCHAR(5)  NOT NULL DEFAULT 'light',
    user_settings_dark_mode_schedule  JSONB,
    user_settings_notifications_sound BOOLEAN              DEFAULT TRUE,
    CONSTRAINT check_theme_preference CHECK (user_settings_theme_preference IN ('light', 'dark')),
    FOREIGN KEY (user_settings_id) REFERENCES Project.Users (user_id)
);

CREATE TABLE IF NOT EXISTS Project.Projects
(
    project_id               SERIAL PRIMARY KEY,
    project_for_user_id      INT,
    project_size             INT         NOT NULL     DEFAULT 0,
    project_name             VARCHAR(100)             DEFAULT 'Project',
    project_date_created     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    project_type_of_tracking VARCHAR(20) NOT NULL,
    project_visibility       BOOLEAN                  DEFAULT FALSE,
    CONSTRAINT chk_tracking_type CHECK (project_type_of_tracking IN ('markerless', 'image')),
    FOREIGN KEY (project_for_user_id) REFERENCES Project.Users (user_id)
);

-- Create function that will generate random project_name for Project.Projects
CREATE OR REPLACE FUNCTION set_default_project_name()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.project_name := 'Project_' || NEW.project_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_default_project_name_trigger
    BEFORE INSERT
    ON Project.Projects
    FOR EACH ROW
EXECUTE FUNCTION set_default_project_name();

CREATE TABLE IF NOT EXISTS Project.Project_Statistics
(
    project_statistics_project_id  INT PRIMARY KEY,
    project_statistics_views       INT DEFAULT 0,
    project_statistics_unique_view INT DEFAULT 0,
    CONSTRAINT check_views_correctness CHECK (project_statistics_unique_view <= project_statistics_views),
    FOREIGN KEY (project_statistics_project_id) REFERENCES Project.Projects (project_id)
);

CREATE TABLE IF NOT EXISTS Project.Scenes
(
    scene_id         SERIAL PRIMARY KEY,
    scene_project_id INT,
    scene_url        VARCHAR(255) NOT NULL,
    scene_name       VARCHAR(100) NOT NULL DEFAULT 'Default scene',
    FOREIGN KEY (scene_project_id) REFERENCES Project.Projects (project_id)
);

CREATE TABLE IF NOT EXISTS Project.Audios
(
    audio_id            SERIAL PRIMARY KEY,
    audio_data          BYTEA NOT NULL,
    audio_creation_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    audio_scene_id      INT UNIQUE,
    audio_size          INT   NOT NULL,
    audio_duration      INT   NOT NULL           DEFAULT 60,
    FOREIGN KEY (audio_scene_id) REFERENCES Project.Scenes (scene_id)
);

CREATE TABLE IF NOT EXISTS Project.Objects
(
    object_id        SERIAL PRIMARY KEY,
    object_data      BYTEA  NOT NULL,
    object_scene_id  INT UNIQUE,
    object_size      INT    NOT NULL,
    object_triangles BIGINT NOT NULL,
    object_vertices  BIGINT NOT NULL,
    object_uv_layers BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (object_scene_id) REFERENCES Project.Scenes (scene_id)
);

CREATE TABLE IF NOT EXISTS Project.Markers
(
    marker_id       SERIAL PRIMARY KEY,
    marker_data     BYTEA NOT NULL,
    marker_scene_id INT UNIQUE,
    marker_size     INT   NOT NULL,
    FOREIGN KEY (marker_scene_id) REFERENCES Project.Scenes (scene_id)
);

CREATE TABLE IF NOT EXISTS Project.Product_Categories
(
    product_category_id          SERIAL PRIMARY KEY,
    product_category_name        VARCHAR(255) UNIQUE NOT NULL,
    product_category_description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Project.Products
(
    product_id          SERIAL PRIMARY KEY,
    product_name        VARCHAR(100)                                       NOT NULL,
    product_category_id INT                                                NOT NULL,
    product_price       DECIMAL(10, 2)                                     NOT NULL,
    product_created_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    product_update_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    product_quantity    SMALLINT                 DEFAULT 1,
    FOREIGN KEY (product_category_id) REFERENCES Project.Product_Categories (product_category_id)
);

CREATE TABLE IF NOT EXISTS Project.Carts
(
    cart_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES Project.Users (user_id)
);


CREATE TABLE IF NOT EXISTS Project.Cart_Products
(
    cart_id                INT NOT NULL,
    product_id             INT NOT NULL,
    cart_products_quantity INT NOT NULL             DEFAULT 1,
    cart_products_add_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES Project.Carts (cart_id),
    FOREIGN KEY (product_id) REFERENCES Project.Products (product_id)
);


CREATE TABLE IF NOT EXISTS Project.Orders
(
    order_id   SERIAL PRIMARY KEY,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS Project.Order_Products
(
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL DEFAULT 1,
    FOREIGN KEY (order_id) REFERENCES Project.Orders (order_id),
    FOREIGN KEY (product_id) REFERENCES Project.Products (product_id),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE IF NOT EXISTS Project.User_Limits
(
    user_limit_id           INT PRIMARY KEY,
    user_limit_audio        INT        NOT NULL,
    user_limit_projects     SMALLINT   NOT NULL,
    user_limit_objects      SMALLINT   NOT NULL,
    user_limit_scenes       SMALLINT   NOT NULL,
    user_limit_for_user_id  INT UNIQUE NOT NULL,
    user_limit_last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_limit_for_user_id) REFERENCES Project.Users (user_id)
);

-- Create function that will connect user_limits with users
DROP SEQUENCE IF EXISTS user_limits_sequence;
CREATE SEQUENCE user_limits_sequence START WITH 1;

CREATE OR REPLACE FUNCTION create_limits_for_new_user()
    RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO Project.User_Limits (user_limit_id, user_limit_audio, user_limit_projects, user_limit_objects,
                                     user_limit_scenes, user_limit_for_user_id)
    VALUES (NEXTVAL('user_limits_sequence'), 1, 1, 1, 1, NEW.user_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add limits after user added
CREATE TRIGGER trigger_create_limits
    AFTER INSERT
    ON Project.Users
    FOR EACH ROW
EXECUTE FUNCTION create_limits_for_new_user();

-- Add cart after user added
CREATE OR REPLACE FUNCTION create_cart_for_new_user()
    RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO Project.Carts (user_id)
    VALUES (NEW.user_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_cart
    AFTER INSERT
    ON Project.Users
    FOR EACH ROW
EXECUTE FUNCTION create_cart_for_new_user();


-- Users Table
INSERT INTO Project.Users (user_email, user_password, user_name, user_surname, user_date_of_birth, user_phone,
                           user_address, user_last_login)
VALUES ('user1@gmail.com', 'pass123', 'John', 'Doe', TO_DATE('15-05-15', 'DD-MM-YY'), '+1234567890',
        '123 Main St, Kosice', CURRENT_TIMESTAMP - INTERVAL '6 hours 3 minutes'),
       ('user2@gmail.com', 'pass456', 'Alice', 'Smith', TO_DATE('1988-09-22', 'YYYY-MM-DD'), '+1987654321',
        '456 Elm St, Nice', CURRENT_TIMESTAMP - INTERVAL '1 months 13 days 3 hours 23 minutes'),
       ('user3@gmail.com', 'pass789', 'Eva', 'Johnson', TO_DATE('1995-12-03', 'YYYY-MM-DD'), '+1122334455',
        '789 Oak St, Sydney', CURRENT_TIMESTAMP - INTERVAL '26 minutes'),
       ('user4@gmail.com', 'pass789', 'Sophia', 'Wilson', TO_DATE('1993-08-10', 'YYYY-MM-DD'), '+1122334455',
        '789 Pine St, Rome', CURRENT_TIMESTAMP),
       ('user5@gmail.com', 'pass101', 'Oliver', 'Brown', TO_DATE('1998-04-25', 'YYYY-MM-DD'), '+1567890234',
        '101 Cedar St, New York', CURRENT_TIMESTAMP),
       ('user6@gmail.com', 'pass112', 'Emma', 'Miller', TO_DATE('1985-11-17', 'YYYY-MM-DD'), '+1654327890',
        '112 Maple St, Sunriver', CURRENT_TIMESTAMP - INTERVAL '2 hours 45 minutes'),
       ('user7@gmail.com', 'pass131', 'William', 'Garcia', TO_DATE('1992-02-08', 'YYYY-MM-DD'), '+1908765432',
        '131 Oak St, Paris', CURRENT_TIMESTAMP - INTERVAL '7 months'),
       ('user8@gmail.com', 'pass415', 'Ava', 'Martinez', TO_DATE('1996-07-30', 'YYYY-MM-DD'), '+1987654321',
        '415 Walnut St, Kostroma', CURRENT_TIMESTAMP),
       ('user9@gmail.com', 'pass161', 'James', 'Lopez', TO_DATE('1990-12-12', 'YYYY-MM-DD'), '+1765432987',
        '161 Elm St, Tokyo', CURRENT_TIMESTAMP),
       ('user10@gmail.com', 'pass718', 'Mia', 'Gonzalez', TO_DATE('1987-05-29', 'YYYY-MM-DD'), '+1123456789',
        '718 Birch St, Ufa', CURRENT_TIMESTAMP - INTERVAL '2 months 3 hours'),
       ('user11@gmail.com', 'pass819', 'Logan', 'Perez', TO_DATE('1994-09-03', 'YYYY-MM-DD'), '+1982374650',
        '819 Spruce St, Brno', CURRENT_TIMESTAMP),
       ('user12@gmail.com', 'pass922', 'Charlotte', 'Rodriguez', TO_DATE('1997-03-18', 'YYYY-MM-DD'), '+1650432876',
        '922 Ash St, London', CURRENT_TIMESTAMP - INTERVAL '1 days'),
       ('andysmith@gmail.com', 'anysmith123A', 'Andy', 'Smith', TO_DATE('1992-09-25', 'YYYY-MM-DD'), '+42039012534',
        '142 Air St, Prague', CURRENT_TIMESTAMP - INTERVAL '7 months');


UPDATE Project.User_Limits ul
SET user_limit_last_updated = '2023-02-05', user_limit_projects = 5
WHERE user_limit_for_user_id = 3
   OR user_limit_for_user_id = 1;


-- User_Settings Table
INSERT INTO Project.User_Settings (user_settings_id, user_settings_language, user_settings_allow_notifications,
                                   user_settings_privacy, user_settings_preferred_currency,
                                   user_settings_timezone, user_settings_email_frequency,
                                   user_settings_theme_preference)
VALUES (1, 'en', true, '{
  "profile_visibility": "public",
  "message_notifications": true
}', 'USD', 'UTC', 1, 'light'),
       (2, 'en', true, '{
         "profile_visibility": "private",
         "message_notifications": false
       }', 'EUR', 'GMT', 0, 'dark')
        ,
       (3, 'en', true, '{
         "profile_visibility": "friends",
         "message_notifications": true
       }', 'GBP', 'PST', 2, 'light')
        ,
       (4, 'en', true, '{
         "profile_visibility": "public",
         "message_notifications": true
       }', 'USD', 'UTC', 1, 'light')
        ,
       (5, 'en', true, '{
         "profile_visibility": "private",
         "message_notifications": false
       }', 'EUR', 'GMT', 0, 'dark')
        ,
       (6, 'en', true, '{
         "profile_visibility": "friends",
         "message_notifications": true
       }', 'GBP', 'PST', 2, 'light')
        ,
       (7, 'en', true, '{
         "profile_visibility": "public",
         "message_notifications": false
       }', 'USD', 'EST', 1, 'dark')
        ,
       (8, 'en', true, '{
         "profile_visibility": "friends",
         "message_notifications": true
       }', 'EUR', 'CST', 0, 'light')
        ,
       (9, 'en', true, '{
         "profile_visibility": "private",
         "message_notifications": true
       }', 'GBP', 'PST', 2, 'dark')
        ,
       (10, 'en', true, '{
         "profile_visibility": "public",
         "message_notifications": false
       }', 'USD', 'MST', 1, 'light')
        ,
       (11, 'en', true, '{
         "profile_visibility": "friends",
         "message_notifications": true
       }', 'EUR', 'AST', 0, 'dark')
        ,
       (12, 'en', true, '{
         "profile_visibility": "private",
         "message_notifications": true
       }', 'GBP', 'HST', 2, 'light');


-- Projects Table
INSERT INTO Project.Projects (project_for_user_id, project_size, project_name, project_type_of_tracking)

VALUES (1, 25, 'Project 1', 'markerless'),         -- 1
       (2, 50, 'Project 2', 'image'),              -- 2
       (3, 30, 'Project 3', 'markerless'),         -- 3
       (4, 25, 'Project 4', 'markerless'),         -- 4
       (5, 50, 'Project 5', 'image'),              -- 5
       (6, 30, 'Project 6', 'markerless'),         -- 6
       (7, 40, 'Project 7', 'image'),              -- 7
       (8, 20, 'Project 8', 'markerless'),         -- 8
       (9, 35, 'Project 9', 'image'),              -- 9
       (10, 45, 'Project 10', 'markerless'),       -- 10
       (11, 55, 'Project 11', 'image'),            -- 11
       (1, 1255, 'Favourite AR', 'image'),         -- 12
       (1, 95, 'CocaCola Advertisement', 'image'), -- 13
       (11, 55, 'Project 11', 'image'),            -- 14
       (12, 60, 'Project 12', 'markerless'),       -- 15
       (1, 234, 'My new project!', 'markerless');


-- Statistics Table
INSERT INTO Project.Project_Statistics (project_statistics_project_id, project_statistics_views,
                                        project_statistics_unique_view)
VALUES (1, 500, 250),
       (2, 1000, 700),
       (3, 750, 400),
       (4, 800, 400),
       (5, 1200, 900),
       (6, 600, 350),
       (7, 950, 600),
       (8, 400, 250),
       (9, 850, 500),
       (10, 1100, 750),
       (11, 1300, 950),
       (12, 532, 123),
       (13, 247442, 223013),
       (14, 1300, 950),
       (16, 1400, 1000);


-- Scene Table
INSERT INTO Project.Scenes (scene_project_id, scene_url, scene_name)
VALUES (1, 'https://example.com/scene15245346', 'Scene 1'),
       (2, 'https://example.com/scene212312312', 'Scene 2'),
       (3, 'https://example.com/scene33123123', 'Scene 3'),
       (4, 'https://example.com/scene4123423', 'Scene 4'),
       (5, 'https://example.com/scene4234125', 'Scene 5'),
       (6, 'https://example.com/scene6341242', 'Scene 6'),
       (7, 'https://example.com/scene3534537', 'Scene 7'),
       (8, 'https://example.com/scene84534', 'Scene 8'),
       (9, 'https://example.com/scene93453453', 'Scene 9'),
       (10, 'https://example.com/scene10345345', 'My birthday'),
       (11, 'https://example.com/scene11235234', 'Scene 11'),
       (13, 'https://example.com/scene1223423423', 'Scene 12'),
       (13, 'https://example.com/scene12234132', 'My favourite scene'),
       (14, 'https://example.com/scene122321323', 'Alina');

-- Inserting sample data into Project.Audios
INSERT INTO Project.Audios (audio_data, audio_scene_id, audio_creation_date, audio_size, audio_duration)
VALUES (E'\\x0123456789ABCDEF', 1, '2023-01-10', 1024, 60),
       (E'\\xABCDEF0123456789', 2, '2023-01-11', 2048, 120),
       (E'\\x2233445566778899', 3, '2023-01-12', 4096, 180),
       (E'\\x1122334455667788', 4, '2023-01-13', 8192, 240),
       (E'\\xAA1122BB3344CCDD', 5, '2023-01-14', 16384, 300),
       (E'\\x9988776655443322', 6, '2023-01-15', 32768, 360),
       (E'\\xBBCCDDEEFF001122', 7, '2023-01-16', 65536, 420),
       (E'\\xEEFF00112233AABB', 8, '2023-01-17', 131072, 480),
       (E'\\xCCDDEEFF00112233', 9, '2023-01-18', 262144, 540),
       (E'\\x00112233AABBCCDD', 10, '2023-01-19', 524288, 600),
       (E'\\xAA99BB88CC77DD66', 11, '2023-01-20', 1048576, 660),
       (E'\\xEEFF99BB77DDAA22', 12, '2023-01-21', 2097152, 720);

-- Inserting sample data into Project.Objects
INSERT INTO Project.Objects (object_data, object_scene_id, object_size, object_vertices, object_triangles,
                             object_uv_layers)
VALUES (E'\\x0123456789ABCDEF', 1, 512, 1000, 800, true),
       (E'\\xDEADBEEF01234567', 2, 1024, 2000, 1600, true),
       (E'\\xAA1122BB3344CCDD', 3, 2048, 4000, 3200, true),
       (E'\\x9988776655443322', 6, 8192, 16000, 12800, false),
       (E'\\xBBCCDDEEFF001122', 5, 4096, 8000, 6400, false),
       (E'\\xEEFF00112233AABB', 8, 16384, 32000, 25600, true),
       (E'\\xCCDDEEFF00112233', 9, 32768, 64000, 51200, false),
       (E'\\x00112233AABBCCDD', 10, 65536, 128000, 102400, true),
       (E'\\xEEFF99BB77DDAA22', 12, 262144, 256000, 204800, false);

-- Inserting sample data into Project.Markers
INSERT INTO Project.Markers (marker_data, marker_scene_id, marker_size)
VALUES (E'\\x0123456789ABCDEF', 1, 1231),
       (E'\\xABCDEF0123456789', 2, 3231),
       (E'\\x9988776655443322', 3, 4322),
       (E'\\x9988776655443322', 4, 1252),
       (E'\\x9988776655443322', 5, 2321),
       (E'\\x9988776655443322', 6, 4234),
       (E'\\xBBCCDDEEFF001122', 7, 4252),
       (E'\\xEEFF00112233AABB', 8, 3413),
       (E'\\xCCDDEEFF00112233', 9, 3278),
       (E'\\x2233445566778899', 10, 1212),
       (E'\\x1122334455667788', 11, 3312),
       (E'\\xAA1122BB3344CCDD', 12, 4342);


-- Shop_Category Table
INSERT INTO Project.Product_Categories (product_category_name, product_category_description)
VALUES ('3D Models', 'High-quality digital models for your projects'),
       ('Project Customization', 'Tailored services to personalize your projects'),
       ('Add-ons', 'Additional enhancements and extensions for projects'),
       ('Audio', ''),
       ('Video', ''),
       ('Markers', 'Different types of high quality markers');


-- Products for '3D Models' category
INSERT INTO Project.Products (product_name, product_category_id, product_price)
VALUES ('Modern House 3D Model', 1, 49.99),
       ('Furniture Pack 3D Models', 1, 29.99),
       ('Vehicle Collection 3D Models', 1, 39.99),
       ('Character Rig 3D Model', 1, 59.99),
       ('Cityscape 3D Model', 1, 79.99),
       ('Animals Pack 3D Models', 1, 34.99),
       ('Customized Logo Design', 2, 99.99),
       ('Personalized Website Template', 2, 149.99),
       ('Tailored Branding Package', 2, 199.99),
       ('Bespoke Marketing Campaign', 2, 299.99),
       ('Exclusive App Development', 2, 499.99),
       ('Extra Content Pack', 3, 14.99),
       ('Upgrade Package', 3, 19.99),
       ('Enhancement Bundle', 3, 24.99),
       ('Extended Warranty', 3, 9.99),
       ('Music Production Software', 4, 199.99),
       ('Premium Sound Effects Library', 4, 79.99),
       ('Audio Editing Suite', 4, 149.99),
       ('Podcasting Starter Kit', 4, 99.99),
       ('Video Editing Software', 5, 249.99),
       ('Cinematic Camera Pack', 5, 899.99),
       ('Stock Footage Collection', 5, 129.99),
       ('VR Production Kit', 5, 499.99),
       ('Documentary Masterclass', 5, 79.99),
       ('Assorted Color Markers (Pack of 12)', 6, 7.99),
       ('Dual Tip Brush Pens (Set of 24)', 6, 14.99),
       ('Highlighter Set (Pack of 6)', 6, 5.99),
       ('Permanent Markers (Pack of 8)', 6, 9.99);


-- User_Cart_Items Table
INSERT INTO Project.Cart_Products (cart_id, product_id, cart_products_quantity)
VALUES (1, 1, 2),
       (2, 2, 1),
       (1, 12, 1),
       (2, 7, 1),
       (3, 3, 1),
       (4, 5, 2),
       (4, 1, 7),
       (4, 3, 2),
       (6, 1, 1),
       (5, 5, 1),
       (6, 6, 1),
       (7, 5, 2),
       (7, 11, 1),
       (7, 12, 3),
       (8, 8, 1),
       (9, 9, 1),
       (10, 10, 2);


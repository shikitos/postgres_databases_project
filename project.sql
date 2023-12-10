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
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Project.Users (user_id)
);


CREATE TABLE IF NOT EXISTS Project.Cart_Products
(
    cart_id    INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL DEFAULT 1,
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

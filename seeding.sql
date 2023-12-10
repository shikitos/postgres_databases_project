-- Users Table
INSERT INTO Project.Users (user_email, user_password, user_name, user_surname, user_date_of_birth, user_phone,
                           user_address)
VALUES ('user1@example.com', 'pass123', 'John', 'Doe', TO_DATE('15-05-15', 'DD-MM-YY'), '+1234567890',
        '123 Main St, City'),
       ('user2@example.com', 'pass456', 'Alice', 'Smith', TO_DATE('1988-09-22', 'YYYY-MM-DD'), '+1987654321',
        '456 Elm St, Town'),
       ('user3@example.com', 'pass789', 'Eva', 'Johnson', TO_DATE('1995-12-03', 'YYYY-MM-DD'), '+1122334455',
        '789 Oak St, Village'),
       ('user4@example.com', 'pass789', 'Sophia', 'Wilson', TO_DATE('1993-08-10', 'YYYY-MM-DD'), '+1122334455',
        '789 Pine St, Town'),
       ('user5@example.com', 'pass101', 'Oliver', 'Brown', TO_DATE('1998-04-25', 'YYYY-MM-DD'), '+1567890234',
        '101 Cedar St, City'),
       ('user6@example.com', 'pass112', 'Emma', 'Miller', TO_DATE('1985-11-17', 'YYYY-MM-DD'), '+1654327890',
        '112 Maple St, Village'),
       ('user7@example.com', 'pass131', 'William', 'Garcia', TO_DATE('1992-02-08', 'YYYY-MM-DD'), '+1908765432',
        '131 Oak St, Town'),
       ('user8@example.com', 'pass415', 'Ava', 'Martinez', TO_DATE('1996-07-30', 'YYYY-MM-DD'), '+1987654321',
        '415 Walnut St, City'),
       ('user9@example.com', 'pass161', 'James', 'Lopez', TO_DATE('1990-12-12', 'YYYY-MM-DD'), '+1765432987',
        '161 Elm St, Village'),
       ('user10@example.com', 'pass718', 'Mia', 'Gonzalez', TO_DATE('1987-05-29', 'YYYY-MM-DD'), '+1123456789',
        '718 Birch St, Town'),
       ('user11@example.com', 'pass819', 'Logan', 'Perez', TO_DATE('1994-09-03', 'YYYY-MM-DD'), '+1982374650',
        '819 Spruce St, City'),
       ('user12@example.com', 'pass922', 'Charlotte', 'Rodriguez', TO_DATE('1997-03-18', 'YYYY-MM-DD'), '+1650432876',
        '922 Ash St, Village');


-- User_Settings Table
INSERT INTO Project.User_Settings (user_settings_user_id, user_settings_language, user_settings_allow_notifications,
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
INSERT INTO Project.Scenes (scene_for_project_id, scene_url, scene_name)
VALUES (1, 'https://example.com/scene1', 'Scene 1'),
       (2, 'https://example.com/scene2', 'Scene 2'),
       (3, 'https://example.com/scene3', 'Scene 3'),
       (4, 'https://example.com/scene4', 'Scene 4'),
       (5, 'https://example.com/scene5', 'Scene 5'),
       (6, 'https://example.com/scene6', 'Scene 6'),
       (7, 'https://example.com/scene7', 'Scene 7'),
       (8, 'https://example.com/scene8', 'Scene 8'),
       (9, 'https://example.com/scene9', 'Scene 9'),
       (10, 'https://example.com/scene10', 'Scene 10'),
       (11, 'https://example.com/scene11', 'Scene 11'),
       (12, 'https://example.com/scene12', 'Scene 12');

INSERT INTO Project.Audios (audio_data, audio_for_scene_id)
VALUES (E'\\x0123456789ABCDEF', 1),
       (E'\\xABCDEF0123456789', 2),
       (E'\\x2233445566778899', 3),
       (E'\\x1122334455667788', 4),
       (E'\\xAA1122BB3344CCDD', 5),
       (E'\\x9988776655443322', 6),
       (E'\\xBBCCDDEEFF001122', 7),
       (E'\\xEEFF00112233AABB', 8),
       (E'\\xCCDDEEFF00112233', 9),
       (E'\\x00112233AABBCCDD', 10),
       (E'\\xAA99BB88CC77DD66', 11),
       (E'\\xEEFF99BB77DDAA22', 12);

INSERT INTO Project.Objects (object_data, object_for_scene_id)
VALUES (E'\\x0123456789ABCDEF', 1),
       (E'\\xDEADBEEF01234567', 2),
       (E'\\xAA1122BB3344CCDD', 3),
       (E'\\x9988776655443322', 6),
       (E'\\xBBCCDDEEFF001122', 5),
       (E'\\xEEFF00112233AABB', 8),
       (E'\\xCCDDEEFF00112233', 9),
       (E'\\x00112233AABBCCDD', 10),
       (E'\\xEEFF99BB77DDAA22', 12);

-- Inserting sample data into Project.Marker
INSERT INTO Project.Markers (marker_data, marker_for_scene_id)
VALUES (E'\\x0123456789ABCDEF', 1),
       (E'\\xABCDEF0123456789', 2),
       (E'\\x9988776655443322', 3),
       (E'\\x9988776655443322', 4),
       (E'\\x9988776655443322', 5),
       (E'\\x9988776655443322', 6),
       (E'\\xBBCCDDEEFF001122', 7),
       (E'\\xEEFF00112233AABB', 8),
       (E'\\xCCDDEEFF00112233', 9),
       (E'\\x2233445566778899', 10),
       (E'\\x1122334455667788', 11),
       (E'\\xAA1122BB3344CCDD', 12);

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
INSERT INTO Project.Cart_Products (cart_id, cart_product_id)
VALUES (1, 1),
       (2, 2),
       (1, 12),
       (2, 7),
       (3, 3),
       (4, 14),
       (5, 5),
       (6, 6),
       (7, 5),
       (7, 11),
       (7, 12),
       (7, 12),
       (8, 8),
       (9, 9),
       (10, 10);

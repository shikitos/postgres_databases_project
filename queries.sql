/* Query 1 - SQL Category: G1, F1 */
/* Check what users have product with id 1 in their carts */
SELECT u.user_email, u.user_name, u.user_surname, u.user_phone
FROM Project.Users u
WHERE u.user_id IN (SELECT c.user_id
                    FROM Project.Carts c
                             JOIN Project.Cart_Products cp ON c.cart_id = cp.cart_id
                    WHERE cp.product_id = 1);

/* Query 2 - SQL Category: F4, I1, I2, K  */
/* Get subtotal of every user's cart */
SELECT u.user_name                                                   AS name,
       u.user_surname                                                AS surname,
       u.user_email                                                  AS email,
       SUM(COALESCE(p.product_price * cp.cart_products_quantity, 0)) AS subtotal
FROM Project.Users u
         LEFT JOIN project.carts c on u.user_id = c.user_id
         LEFT JOIN project.cart_products cp on c.cart_id = cp.cart_id
         LEFT JOIN project.products p on cp.product_id = p.product_id
GROUP BY (u.user_name, u.user_surname, u.user_email)
ORDER BY subtotal DESC;

/* Query 3 - SQL Category: G3, F4, I1, K  */
/* Get user's projects count and sum of all these project's views */
SELECT u.user_email,
       (SELECT COUNT(*) FROM Project.Projects p WHERE p.project_for_user_id = u.user_id) AS project_count,
       (SELECT COALESCE(SUM(ps.project_statistics_views), 0) AS sum_views
        FROM Project.Projects p
                 LEFT JOIN Project.project_statistics ps ON p.project_id = ps.project_statistics_project_id
        WHERE p.project_for_user_id = u.user_id)                                         AS total_views
FROM Project.Users u
ORDER BY total_views DESC;

/* Query 4 - SQL Category: O, G4  */
/* UPDATE user's limits who has only one project and last login older than month ago */
UPDATE Project.User_Limits us
SET user_limit_last_updated = CURRENT_TIMESTAMP,
    user_limit_scenes       = user_limit_scenes + 2,
    user_limit_audio        = user_limit_audio + 2,
    user_limit_objects      = user_limit_objects + 2,
    user_limit_projects     = user_limit_projects + 1
WHERE EXISTS (SELECT *
              FROM Project.Users u
              WHERE u.user_id = us.user_limit_for_user_id
                AND us.user_limit_projects = 1
                AND u.user_last_login < (CURRENT_TIMESTAMP - INTERVAL '1 months'));

/* Query 5 - SQL Category: O */
/* Update user's cart  */
UPDATE Project.Cart_Products cp
SET cart_products_add_date = CURRENT_TIMESTAMP - INTERVAL '6 months 13 days 20 hours'
WHERE cart_products_quantity < 2;

/* Query 6 - SQL Category: P  */
/* Delete items from the cart if user's last login was too old and he has only one item */
DELETE
FROM Project.Cart_Products cp
WHERE cp.cart_products_quantity < 2
  AND cp.cart_products_add_date < (CURRENT_TIMESTAMP - INTERVAL '3 months');

/* Query 7 - SQL Category: H1 */
/* Get a list of all scenes with the name Default in the scene name and product names with prices greater than 100 */
/* {Project.Scenes(scene_name LIKE '%Default%')[scene_id]} ∪ {Project.Products(product_price > 100)[product_id]} */
SELECT scene_id
FROM Project.Scenes
WHERE scene_name LIKE '%Default%'
UNION
SELECT product_id
FROM Project.Products
WHERE product_price > 100;


/* Query 8 - SQL Category: H3 */
/* Get users who have available 3 or more projects */
/* {Project.Users[user_id]} ∩ {Project.User_Limits(user_limit_projects > 2)[user_limit_for_user_id]} */
SELECT u.user_id
FROM Project.Users u
INTERSECT
SELECT ul.user_limit_for_user_id
FROM Project.User_Limits ul
WHERE ul.user_limit_projects > 2;

/* Query 9 - SQL Category: B */
/* Get all users whose email doesnt contain a user  */
/* Project.Users(user_email NOT LIKE '%user%')[user_email->email, user_phone->phone] */
SELECT user_email AS email, user_phone as phone
FROM Project.Users
WHERE (user_email NOT LIKE '%user%');

/* Query 10 - SQL Category: B */
/* Get the list of products in the range of price (50-100) but not in category 1 */
/* Project.Products(product_price >= 50 AND product_category_id!= 5 AND product_price <= 100)[*] */
SELECT *
FROM Project.Products
WHERE (product_price >= 50 AND product_category_id != 5 AND product_price <= 100);

/* Query 11 - SQL Category: H1 */
/* Get products priced above 100 and below 50 */
/* {Project.Products(PRODUCT_PRICE > 100)[product_id, product_name]} ∪ Project.Products(PRODUCT_PRICE < 50)[product_id, product_name] */
SELECT product_id, product_name
FROM Project.Products
WHERE product_price > 100
UNION
SELECT product_id, product_name
FROM Project.Products
WHERE product_price < 50;


/* Query 12 - SQL Category: B */
/* get users without phone num and last login long time ago */
/* Project.Users(USER_PHONE IS NULL OR user_last_login < '2023-09-05') */
SELECT DISTINCT *
FROM Project.Users
WHERE (USER_PHONE IS NULL OR user_last_login < '2023-09-05');

/* Query 13 - SQL Category: B */
/* Find products that are not in the first category and price more than 100 */
/* {Project.Products(product_price > 100)} \ Project.Products(product_category_id = 3) */
SELECT *
FROM project.products
WHERE product_price > 100
  AND product_id NOT IN (SELECT product_id
                         FROM project.products
                         WHERE product_category_id = 3);

/* Query 14 - SQL Category: H3 */
/* List products that a re both in the 1 category and have been added to a cart */
/* Project.Products(product_category_id=1) ∩ Project.Cart_Products */
SELECT DISTINCT *
FROM Project.Products
WHERE (product_category_id = 1);

/* Query 15 - SQL Category: H2 */
/* Find scenes without any audio added */
/* {Project.Scenes[scene_id]} \ {Project.Audios[audio_scene_id]} */
SELECT s.scene_id
FROM Project.scenes s
         LEFT JOIN Project.audios a ON s.scene_id = a.audio_scene_id
WHERE a.audio_scene_id IS NULL;

/* Query 16 - SQL Category: F3 */
/* Generate a list of all possible combinations of projects and scenes (Cartesian Product) */
/* {Project.Projects[project_id, project_name]} × {Project.Scenes[scene_id, scene_name]} */
SELECT project_id, project_name, scene_id, scene_name
FROM Project.Projects
         CROSS JOIN Project.Scenes;

/* Query 17 - SQL Category: G1, G4, H3 */
/* Get users who have both created project and at least one item in the cart */
SELECT u.user_name
FROM Project.Users u
WHERE EXISTS (SELECT 1 FROM Project.Projects p WHERE p.project_for_user_id = u.user_id)
INTERSECT
SELECT u.user_name
FROM Project.Users u
WHERE EXISTS (SELECT 1
              FROM Project.Carts c
                       JOIN Project.Cart_Products cp ON c.cart_id = cp.cart_id
              WHERE c.user_id = u.user_id);

/* Query 18 - SQL Category: C, G2 */
/* List users who have only 'light' theme preference in settings */
SELECT u.user_name, u.user_email
FROM Project.Users u
WHERE u.user_id IN (SELECT us.user_settings_id
                    FROM Project.User_Settings us
                    WHERE us.user_settings_theme_preference = 'light'
                    EXCEPT
                    SELECT us.user_settings_id
                    FROM Project.User_Settings us
                    WHERE us.user_settings_theme_preference != 'light');

/* Query 19 - SQL Category: C, F2 */
/* View for users with objects */
CREATE VIEW MarkerlessTrackingUsers AS
SELECT u.user_name
FROM Project.Users u
         JOIN Project.Projects p ON u.user_id = p.project_for_user_id
WHERE p.project_type_of_tracking = 'markerless'
  AND NOT EXISTS (SELECT 1
                  FROM Project.Projects p2
                  WHERE p2.project_for_user_id = u.user_id
                    AND p2.project_type_of_tracking != 'markerless');
SELECT *
FROM MarkerlessTrackingUsers;


/* Query 20 - SQL Category: B, F5 */
/* Negative Query & Full Outer Join  */
SELECT u.user_name, u.user_last_login
FROM Project.Users u
         LEFT JOIN Project.Projects p ON u.user_id = p.project_for_user_id
WHERE p.project_id IS NULL;

/* Query 21 - SQL Category: D2, J */
/* Check if all projects have statistics */
SELECT p.project_id
FROM Project.Projects p
WHERE NOT EXISTS (SELECT 1 FROM Project.Project_Statistics ps WHERE ps.project_statistics_project_id = p.project_id);

/* Query 22 - SQL Category: G2 */
/* Count of user projects */
SELECT u.user_name, project_count
FROM Project.Users u
         JOIN (SELECT project_for_user_id, COUNT(*) as project_count
               FROM Project.Projects
               GROUP BY project_for_user_id) AS project_info ON u.user_id = project_info.project_for_user_id;

/* Query 23 - SQL Category: N */
/* Add a default scene for all projects without a scene */
INSERT INTO Project.Scenes (scene_project_id, scene_url)
SELECT project_id, 'http://defaultscene.com'
FROM Project.Projects
WHERE project_id NOT IN (SELECT scene_project_id FROM Project.Scenes);


/* Query 24 - SQL Category: F5 */
/* Get projects and their total views, including projects without statistics, and a count of unique views */
SELECT p.project_name,
       COALESCE(SUM(ps.project_statistics_views), 0)     AS total_views,
       COALESCE(SUM(ps.project_statistics_unique_view), 0) AS unique_views
FROM Project.Projects p
         FULL OUTER JOIN Project.Project_Statistics ps ON p.project_id = ps.project_statistics_project_id
GROUP BY p.project_name
ORDER BY unique_views DESC;





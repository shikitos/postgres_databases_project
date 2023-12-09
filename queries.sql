-- email, project name, project size, type_of_tracking
SELECT u.user_email, p.project_name, p.project_size, p.project_type_of_tracking
FROM Project.Users u
         INNER JOIN Project.Projects p ON p.project_for_user_id = u.user_id;

-- Get projects that user "user1@example.com" has
SELECT u.user_email,
       p.project_name,
       scenes.scene_name,
       Project.Markers.marker_id,
       Project.Audios.audio_id,
       Project.Objects.object_id
FROM Project.Users u
         INNER JOIN Project.Projects p ON p.project_for_user_id = u.user_id
         INNER JOIN Project.Scenes scenes ON scenes.scene_for_project_id = p.project_id
         INNER JOIN Project.Audios audios ON audios.auidio_for_scene_id = scenes.scene_id
         INNER JOIN Project.Markers markers ON markers.marker_for_scene_id = scenes.scene_id
         INNER JOIN Project.Objects objects ON objects.object_for_scene_id = scenes.scene_id
WHERE user_email = 'user1@example.com';


-- Category && Product

-- Get user's items in his cart
SELECT u.user_id, u.user_email, c.cart_id, p.product_name, p.product_price
FROM Project.Users u
         LEFT JOIN project.carts c on u.user_id = c.cart_for_user_id
         LEFT JOIN project.cart_products cp on c.cart_id = cp.cart_id
         LEFT JOIN project.products p on p.product_id = cp.cart_product_id
ORDER BY user_id;

-- show projects views even if no view
SELECT p.project_name,
       COALESCE(ps.project_statistics_views, 0)       AS total_views,
       COALESCE(ps.project_statistics_unique_view, 0) AS unique_views
FROM Project.Projects p
         LEFT JOIN Project.Project_Statistics ps ON p.project_for_user_id = ps.project_statistics_project_id;

-- show ONE the most popular project that each user have
SELECT user_email,
       COALESCE(project_name, 'No Project') AS project_name,
       COALESCE(project_views, 0)           AS project_views,
       COALESCE(project_unique_views, 0)    AS project_unique_views
FROM (SELECT u.user_id,
             u.user_email                                                                        AS user_email,
             p.project_name                                                                      AS project_name,
             COALESCE(s.project_statistics_views, 0)                                             AS project_views,
             COALESCE(s.project_statistics_unique_view, 0)                                       AS project_unique_views,
             ROW_NUMBER()
             OVER (PARTITION BY u.user_id ORDER BY COALESCE(s.project_statistics_views, 0) DESC) AS project_rank
      FROM Project.Users u
               LEFT JOIN Project.Projects p ON u.user_id = p.project_for_user_id
               LEFT JOIN Project.Project_Statistics s
                         ON p.project_for_user_id = s.project_statistics_project_id) ranked_projects
WHERE project_rank = 1
ORDER BY user_id;






------QUERY TO GET ALL EDGES TABLE FOR EACH MODE OF TRANSPORT------
--    Public edge:
SELECT source,
       target,
       x1,
       y1,
       x2,
       y2,
       cost,
       reverse_cost
FROM   public_edges

--    Driving edge:
SELECT osm_source_id AS source,
       osm_target_id AS target,
       cost,
       reverse_cost,
       x1,
       y1,
       x2,
       y2
FROM   osm_2po_4pgr

--    Walking edge:
SELECT osm_source_id          AS source,
       osm_target_id          AS target,
       cost * kmh / 5         AS cost,
       reverse_cost * kmh / 5 AS reverse_cost,
       x1,
       y1,
       x2,
       y2,
       closest_outing_node,
       closest_restaurant_node
FROM   osm_2po_4pgr
WHERE  clazz != 11


-------USING DIJKSTRA TO GET ALL RESULTS------
SELECT *
FROM   pgr_dijkstra( 'Insert edge table as string here', array['starting nodes here, seperated by commas']::bigint[],
            --array function to get all valid endpoint nodes to parse into dijkstra
            array(
              SELECT nearest_road_neighbour_osm_id
              FROM   INSERT_ENDPOINT_TABLE))


------JOIN TO GET ENDPOINT NODE DATA------
--this gives ENDPOINT_NODE_DATA as results
SELECT *,
       INSERT_ENDPOINT_TABLE.cost AS price
FROM   DIJKSTRA_RESULTS_TABLE
       JOIN INSERT_ENDPOINT_TABLE
         ON DIJKSTRA_RESULTS_TABLE.end_vid =
            INSERT_ENDPOINT_TABLE.nearest_road_neighbour_osm_id


------JOIN TO GET LAT AND LONG DATA (TABLE 1)------
--this gives the final "results" table
SELECT ENDPOINT_NODE_DATA.*,
       osm_2po_4pgr.geom_way,
       osm_2po_4pgr.x1, -- long
       osm_2po_4pgr.y1 -- lat
FROM   ENDPOINT_NODE_DATA
       JOIN osm_2po_4pgr
         ON ENDPOINT_NODE_DATA.node = osm_2po_4pgr.osm_source_id


------FIND THE TOP DESIRED_NUM_OF_PLACES (TABLE 2)------
SELECT   *
         FROM    (
                         SELECT place_id,
                                sum(agg_cost) OVER (partition BY end_vid) AS total_cost,
                                max(agg_cost) OVER (partition BY end_vid) AS max_travel_time,
                                min(agg_cost) OVER (partition BY end_vid) AS min_travel_time
                         FROM   (
                                       SELECT *
                                       FROM   results
                                       WHERE  price != 'None') results
                         WHERE  edge = -1
                         AND    cast (price AS integer) < MAX_PRICE
                         AND    cast (price AS integer) > MIN_PRICE
                         AND    rating > MIN_RATING ) results
         WHERE    max_travel_time   - min_travel_time < MAX_TIME_DIFF
         ORDER BY total_cost limit 5*cardinality(array[425482381, 4488019045, 243213958]::bigint[])


------COMBINE TABLE 1 AND 2------
SELECT     path_seq,
           results.start_vid AS start_user,
           agg_cost          AS cost_for_user,
           total_cost,
           NAME,
           results.end_vid,
           geom_way  AS location,
           x1        AS longtitude,
           y1        AS latitude,
           st_x(way) AS restaurant_x,
           st_y(way) AS restaurant_y,
           results.price,
           results.rating,
           results.place_id
FROM       results
INNER JOIN best_places
ON       results.place_id = best_places.place_id



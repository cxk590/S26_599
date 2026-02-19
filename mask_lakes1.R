set_overpass_url("https://overpass.kumi.systems/api/interpreter")

# Stordalen point 
stordalen_pt <- st_as_sf(
  data.frame(lon = 19.05385, lat = 68.35170),
  coords = c("lon", "lat"),
  crs = 4326
)

# UTM zone
utm_epsg <- 32634
stordalen_utm <- st_transform(stordalen_pt, utm_epsg)

buffer_m <- 20000
area_utm <- st_buffer(stordalen_utm, dist = buffer_m)

# bbox 
area_ll <- st_transform(area_utm, 4326)
bb <- st_bbox(area_ll)


# waterways lines 
q_lines <- opq(bbox = bb, timeout = 300) %>%
  add_osm_feature(key = "waterway", value = c("river", "stream"))

osm_lines <- osmdata_sf(q_lines)

water_lines <- bind_rows(
  osm_lines$osm_lines %>% select(any_of(c("osm_id", "name", "waterway", "geometry"))),
  osm_lines$osm_multilines %>% select(any_of(c("osm_id", "name", "waterway", "geometry")))
) %>%
  st_as_sf() %>%
  st_make_valid() %>%
  st_transform(utm_epsg)


# Water polygons

q_waterpoly <- opq(bbox = bb, timeout = 300) %>%
  add_osm_feature(key = "natural", value = "water")

osm_waterpoly <- osmdata_sf(q_waterpoly)

water_polys <- bind_rows(
  osm_waterpoly$osm_polygons,
  osm_waterpoly$osm_multipolygons
) %>%
  st_as_sf() %>%
  st_make_valid() %>%
  st_transform(utm_epsg)

#should mask lakes
water_polys_mask <- water_polys %>%
  filter(is.na(water) | water %in% c("lake", "pond", "reservoir", "basin", "lagoon"))


area_geom <- st_make_valid(st_geometry(area_utm))





# If there are no lake polygons, keep it 
if (length(lake_union) == 0 || all(is.na(st_is_empty(lake_union))) || any(st_is_empty(lake_union))) {
  water_land <- water_clip
} 

cat("OSM waterways (clipped):", nrow(water_clip), "\n")
cat("Lake polygons (clipped):", nrow(lakes_clip), "\n")
cat("Waterways after lake mask:", nrow(water_land), "\n")


p <- ggplot() +
  geom_sf(data = area_utm, fill = NA) +
  geom_sf(data = lakes_clip, alpha = 0.4, color = NA) +
  geom_sf(data = water_land, linewidth = 0.6) +
  geom_sf(data = stordalen_utm, size = 3) +
  coord_sf() +
  labs(
    title = "Stordalen Mire with rivers/streams (OSM) — lakes masked out",
    subtitle = paste0("Buffer radius: ", buffer_m / 1000, " km"),
    x = "Easting (m)", y = "Northing (m)"
  ) +
  theme_minimal()

print(p)


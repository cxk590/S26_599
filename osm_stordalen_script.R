set_overpass_url("https://overpass.kumi.systems/api/interpreter")

stordalen_pt <- st_as_sf(
  data.frame(lon = 19.05385, lat = 68.35170),
  coords = c("lon", "lat"),
  crs = 4326
)
cat("stordalen_pt created:", inherits(stordalen_pt, "sf"), "\n")

stordalen_utm <- st_transform(stordalen_pt, 32634)
cat("stordalen_utm CRS:", st_crs(stordalen_utm)$epsg, "\n")

buffer_m <- 100000
area_utm <- st_buffer(stordalen_utm, dist = buffer_m)
cat("area_utm created:", inherits(area_utm, "sf"), "\n")

area_ll <- st_transform(area_utm, 4326)
bb <- st_bbox(area_ll)
print(bb)

q <- opq(bbox = bb, timeout = 300) %>%
  add_osm_feature(key = "waterway", value = c("river", "stream"))

osm <- osmdata_sf(q)
cat("OSM lines:", nrow(osm$osm_lines), " | OSM multilines:", nrow(osm$osm_multilines), "\n")

water_lines <- bind_rows(
  osm$osm_lines %>% select(any_of(c("osm_id", "name", "waterway", "geometry"))),
  osm$osm_multilines %>% select(any_of(c("osm_id", "name", "waterway", "geometry")))
) %>%
  st_as_sf() %>%
  st_make_valid()

water_utm <- st_transform(water_lines, 32634)
area_geom <- st_make_valid(st_geometry(area_utm))

water_clip <- suppressWarnings(st_intersection(water_utm, area_geom))
cat("Clipped waterways:", nrow(water_clip), "\n")

p <- ggplot() +
  geom_sf(data = area_utm, fill = NA) +
  geom_sf(data = water_clip, linewidth = 0.6) +
  geom_sf(data = stordalen_utm, size = 3) +
  coord_sf() +
  labs(
    title = "Stordalen Mire with rivers/streams (OpenStreetMap)",
    subtitle = paste0("Buffer radius: ", buffer_m / 1000, " km"),
    x = "Easting (m)", y = "Northing (m)"
  ) +
  theme_minimal()

print(p)




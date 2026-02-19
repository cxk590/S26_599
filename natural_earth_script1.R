ggplot() +
  
  # Rivers (Natural Earth, transformed inline)
  geom_sf(
    data = st_transform(
      ne_download(
        scale = 10,
        type = "rivers_lake_centerlines",
        category = "physical",
        returnclass = "sf"
      ),
      32634
    ),
    linewidth = 0.5
  ) +
  
  # Buffer around Stordalen Mire (created inline)
  geom_sf(
    data = st_buffer(
      st_transform(
        st_as_sf(
          data.frame(lon = 19.05385, lat = 68.35170),
          coords = c("lon", "lat"),
          crs = 4326
        ),
        32634
      ),
      dist = 150000
    ),
    fill = NA
  ) +
  
  # Point location (inline)
  geom_sf(
    data = st_transform(
      st_as_sf(
        data.frame(lon = 19.05385, lat = 68.35170),
        coords = c("lon", "lat"),
        crs = 4326
      ),
      32634
    ),
    size = 3
  ) +
  
  coord_sf(
    xlim = c(600000, 900000),
    ylim = c(7600000, 7800000)
  ) +
  
  theme_minimal() +
  labs(title = "Stordalen Mire – Rivers (Natural Earth)")




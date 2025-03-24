# ---- geojsonファイルの読み込み ----

rds_fileName <- "data/jp_pref_simplified.rds"
gis_fileName <- "data/jp_pref_simplified.geojson"

if (file.exists(rds_fileName)) {
  gis <- read_rds(rds_fileName)
} else {
  gis <- read_sf(gis_fileName)
  write_rds(gis, rds_fileName)
}


# ---- 税収データと結合 ----

df_fileName <- "data/tax_revenue.rds"
csv_fileName <- "data/tax_revenue.csv"

if (file.exists(df_fileName)) {
  df <- read_rds(df_fileName)
} else {
  csv <- read_csv(csv_fileName)
  df <- csv |> 
    left_join(gis, by = "id_pref") |> 
    pivot_longer(
      cols = starts_with(c("shotoku", "hojin", "shohi")), 
      names_to = c(".value", "year"), 
      names_sep = "_"
    ) |> 
    mutate(across(starts_with(c("year", "shotoku", "hojin", "shohi")), as.numeric)) |> 
    mutate(shotoku = sum(shotokuShinkoku, shotokuGensen), 
           .by = c(id_pref, year), 
           .before = shotokuShinkoku) |> 
    arrange(id_pref, year) |> 
    relocate(geometry, .after = last_col()) |> 
    st_as_sf()
  write_rds(df, df_fileName)
}

library(readtext)

# default is my home subdirectory
BASE <- '~/code/'

FILE <-  "data607-cp2021/p1/tournamentinfo.txt"

PATH <- str_c(BASE, FILE)

txtfile <- readtext(PATH)

chess_raw <- as_tibble(txtfile["text"])

# use a regex to extract literal record seperator
dash_bound <- str_extract(chess_raw, '-+')


# create a vector with intended column names
cols <- c("player_id_raw", "player_name", "total_points", 
          "r1", "r2", "r3", "r4", "r5", "r6", "r7", 
          "player_state", "player_uid", "pre_rating_raw", "post_rating", 
          "n_something", "r1_color","r2_color", "r3_color", "r4_color", 
          "r5_color", "r6_color", "r7_color")

# start by splitting the text using the dash boundary
chess_split <- str_split(chess_raw, dash_bound)[[1]] %>% 
  str_subset('.') %>% # drop empty rows
  str_replace_all("\\n", "") %>% # replace the one linebreak between stats
  str_replace("/", "|") %>% # replace one slash with pipe
  str_replace("->", "|") %>% # replace pre->post score with pipe
  str_split(" *\\| *", simplify = TRUE) %>% # split by all piptes
  as_tibble %>%
  filter(str_detect(V1, '[0-9]')) %>% # drop header row
  select(V1:V22) # drop empty final column
  

# rename each column
names(chess_split) <- cols

map_score <- function(outcome) {
  case_when(
    outcome %in% c("W", "B") ~ 1, # win or full by = 1 pt
    outcome %in% c("H", "D") ~ 0.5, # half by or draw = .5 pts
    outcome %in% c("L", "U") ~ 0 # loss or unplayed = 0 pts
  )
}


# create a list with my ruund detail column names
result_cols <- str_c("r", 1:7)


long_format <- chess_split %>% 
  # pivot my round columns into a long list
  pivot_longer(cols = result_cols, names_to = 'round', values_to = 'round_summary') %>%
  # extract + map scores from results
  mutate(points = map_score(str_extract(round_summary, "^[A-Z]"))) %>%
  # add flag for whether match was completed
  mutate(match_completed = str_detect(round_summary, "^[WLD]")) %>%
  # extract the opponent id
  mutate(opp_id = strtoi(str_extract(round_summary, "[0-9]+"))) %>%
  # extract the player's pre-tournament rating
  mutate(pre_rating = strtoi(str_extract(pre_rating_raw, '[0-9]+'))) %>%
  # convert player ID to an int
  mutate(player_id = strtoi(player_id_raw)) %>%
  # subset to important columns
  select(player_id, player_name, player_state, pre_rating, round, points, opp_id, match_completed) 



# create a lookup table of player ratings
player_pre_ratintgs <- distinct(long_format, player_id, pre_rating)

summarized_data <- long_format %>% 
  left_join(player_pre_ratintgs, by = c("opp_id" = "player_id")) %>% 
  rename(opp_pre_rating = pre_rating.y) %>%
  rename(pre_rating = pre_rating.x) %>%
  # calculate match expected points
  mutate(exp_match_points = 1/(10^((opp_pre_rating - pre_rating) / 400) + 1)) %>%
  group_by(player_name, player_state, pre_rating) %>%
  summarize(
    avg_opp_pre_rating = round(mean(opp_pre_rating, na.rm = TRUE)),
    total_points = sum(points),
    unplayed_match_count = sum(case_when(match_completed == FALSE ~ 1, match_completed == TRUE ~ 0)),
    expected_points = sum(exp_match_points, na.rm = TRUE)
    ) %>%
  mutate(expected_pt_diff = total_points - expected_points) %>%
  # sort by expected point difference to calculate extra credit
  arrange(desc(expected_pt_diff))

# head to see Aditya Bajaj had the highest point difference
head(summarized_data, 1)


# filtering sets to only the requested columns, and splitting output for players who completed all scheduled matches
only_requested_cols__all_matches_played <- summarized_data %>% 
  filter(unplayed_match_count == 0) %>%
  select(player_name, player_state, total_points, pre_rating, avg_opp_pre_rating)

only_requested_cols__matches_unplayed <- summarized_data %>% 
  filter(unplayed_match_count > 0) %>%
  select(player_name, player_state, total_points, pre_rating, avg_opp_pre_rating)

write.csv(only_requested_cols__matches_unplayed, "players_with_unplayed_matches.csv")
write.csv(only_requested_cols__all_matches_played, "players_without_unplayed_matches.csv")
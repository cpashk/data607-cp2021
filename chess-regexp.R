library(readtext)
PATH = "~/code/data607-cp2021/p1/tournamentinfo.txt"


txtfile <- readtext(PATH)

chess <- as_tibble(txtfile["text"])


?str_match
?str_wrap
?str_trim 

x <- "a\\b"
writeLines(x)


x <- c("apple", "banana.", "pear")
str_view(x, "a\\.")
z <- "\\"
writeLines("\\")

xx <- c('nan', 'pop', 'panuna', "eipaa", "PPP")
str_view(xx, '(.)(.)\\2')
str_view(xx, '(.)(.)\\1')

sentences
str_view(xx, '(p|P)a*')
str_view(xx, 'p|Pa*')

color_match <- c('\bred', 'blue', 'white', 'mauve', 'black', 'yellow') %>%
    str_c(collapse='|')

str_detect('blech', 'le..$')

str_subset(sentences, color_match)

str_subset(sentences, color_match) %>%
  str_extract(color_match)

?str_subset

tibble(sentence = sentences) %>% 
  tidyr::extract(
    sentence, c("article", "noun"), "(a|the) ([^ ]+)", 
    remove = FALSE
  )


sentences
pat <- "(the|a) ([^ ]+) ([^ ]+){0,3}"

sentences[str_detect(sentences, pat)] %>% 
  str_match(pat)

dash_bound <- str_extract(chess, '-+')
n_dash_bound <- nchar(str_extract(chess, '-+'))

chess %>%
  str_split('\n?-+\\n')


?str_subset

dash_bound


cols <- c("player_id", "player_name", "total_points", "r1_result", 
          "r2_result", "r3_result", "r4_result", "r5_result", 
          "r6_result", "r7_result", "player_state", "player_uid", 
          "pre_rating_raw", "post_rating", "n_something", "r1_color",
          "r1_color", "r2_color", "r3_color", "r4_color", "r5_color", 
          "r6_color", "r7_color")

chess_split <- str_split(chess, dash_bound)[[1]] %>% 
  str_subset('.') %>% # drop empty rows
  str_replace_all("\\n", "") %>% # replace the one linebreak between stats
  str_replace("/", "|") %>% # replace one slash with pipe
  str_replace("->", "|") %>% # replace pre->post score with pipe
  str_split("\\|", simplify = TRUE) %>% # split by all piptes
  as_tibble %>%
  filter(str_detect(V1, '[0-9]')) # drop header row

names(chess_split) <- cols

chess_split

cx <- chess_split
cx
mutate(cx, )

?select

str_split("Oh, that's nice", "|")

?tibble
?as_tibble


header <- chess_split[[1]][1]

chess_data <- chess_split[[1]][-1]


?read.table


chess_tibble <- tibble(str_split(chess_data, '\\|', simplify = TRUE))[[1]]

cols
vignette("tibble")
chess_tibble[1,]

names(chess_tibble) <- cols

?rename_all
rename_all(chess_tibble, .funs = list(cols))

chess_tibble
?map2_df


chess_result_split <- chess_split %>%
  # mutate across to create a point column for each match
  mutate(across(result_cols, ~ map_score(str_extract(.x, "^[A-Z]")), .names = "{.col}_points")) %>%
  # mutate across result cols to create an opp_id for each match
  mutate(across(result_cols, ~ str_extract(.x, '[0-9]+'), .names = "{.col}_opp_id")) %>%
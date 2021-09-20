filter(df, col == condition)

# name each column
select(df, col1, col2, col3, col4)

# select a range of columns
select(df, col1:col3)

# exclude a column(s)

select(df, -(col1))
select(df, -(col1:col2))
select(df, -c(col1, col3))

# use bools + helper functions
select(flights, starts_with('dep') | year)

#equivalent to multi select
select(flights, starts_with('dep'), year)

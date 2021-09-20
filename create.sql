

create schema movielens
;
create table movielens.movies (
  movie_id int,
  title varchar,
  genres varchar
);
copy movielens.movies(movie_id, title, genres)
from '/Users/chasepashkowich/code/data607-cp2021/assignment2/ml-latest-small/movies.csv'
csv header
;
create table movielens.ratings(
  user_id int,
  movie_id int,
  rating decimal,
  timestamp int
);
copy movielens.ratings(user_id, movie_id, rating, timestamp)
from '/Users/chasepashkowich/code/data607-cp2021/assignment2/ml-latest-small/ratings.csv'
csv header
;

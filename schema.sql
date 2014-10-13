DROP TABLE events;

CREATE TABLE events (
  guid string primary key,
  time timestamp,
  event string,
  username string,
  userinfo object(dynamic)
) with (number_of_replicas=0);


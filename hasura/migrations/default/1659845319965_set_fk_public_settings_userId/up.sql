alter table "public"."settings" drop constraint "settings_userId_fkey",
  add constraint "settings_userId_fkey"
  foreign key ("userId")
  references "public"."users"
  ("id") on update restrict on delete cascade;

alter table "public"."integrations" drop constraint "integrations_userId_fkey",
  add constraint "integrations_userId_fkey"
  foreign key ("userId")
  references "public"."users"
  ("id") on update restrict on delete restrict;

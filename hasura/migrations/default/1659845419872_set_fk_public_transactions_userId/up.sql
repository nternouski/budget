alter table "public"."transactions" drop constraint "transactions_userId_fkey",
  add constraint "transactions_userId_fkey"
  foreign key ("userId")
  references "public"."users"
  ("id") on update restrict on delete cascade;

alter table "public"."wallets" drop constraint "wallets_userId_fkey",
  add constraint "wallets_userId_fkey"
  foreign key ("userId")
  references "public"."users"
  ("id") on update restrict on delete cascade;

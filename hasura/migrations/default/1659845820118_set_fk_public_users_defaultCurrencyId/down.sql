alter table "public"."users" drop constraint "users_defaultCurrencyId_fkey",
  add constraint "users_defaultCurrencyId_fkey"
  foreign key ("defaultCurrencyId")
  references "public"."currencies"
  ("id") on update restrict on delete restrict;

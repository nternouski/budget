alter table "public"."currency_rates"
  add constraint "currency_rates_userId_fkey"
  foreign key ("userId")
  references "public"."users"
  ("id") on update cascade on delete cascade;

alter table "public"."currency_rates" drop constraint "currency_rates_currencyIdFrom_fkey",
  add constraint "currency_rates_currencyIdFrom_fkey"
  foreign key ("currencyIdFrom")
  references "public"."currencies"
  ("id") on update restrict on delete cascade;

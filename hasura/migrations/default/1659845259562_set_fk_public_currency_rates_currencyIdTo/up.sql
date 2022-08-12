alter table "public"."currency_rates" drop constraint "currency_rates_currencyIdTo_fkey",
  add constraint "currency_rates_currencyIdTo_fkey"
  foreign key ("currencyIdTo")
  references "public"."currencies"
  ("id") on update restrict on delete cascade;

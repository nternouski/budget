alter table "public"."currency_rates" drop constraint "currency_rates_pkey";
alter table "public"."currency_rates"
    add constraint "currency_rates_pkey"
    primary key ("currencyIdTo", "currencyIdFrom");

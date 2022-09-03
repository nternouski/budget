BEGIN TRANSACTION;
ALTER TABLE "public"."currency_rates" DROP CONSTRAINT "currency_rates_pkey";

ALTER TABLE "public"."currency_rates"
    ADD CONSTRAINT "currency_rates_pkey" PRIMARY KEY ("currencyIdTo", "currencyIdFrom", "userId");
COMMIT TRANSACTION;

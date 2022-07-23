CREATE TABLE "public"."currency_rates" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"rate" float4 NOT NULL,
	"currencyIdFrom" uuid NOT NULL,
	"currencyIdTo" uuid NOT NULL,
	PRIMARY KEY ("currencyIdFrom", "currencyIdTo"),
	FOREIGN KEY ("currencyIdFrom") REFERENCES "public"."currencies"("id") ON UPDATE restrict ON DELETE restrict,
	FOREIGN KEY ("currencyIdTo") REFERENCES "public"."currencies"("id") ON UPDATE restrict ON DELETE restrict,
	UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
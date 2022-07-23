CREATE TABLE "public"."transactions" (
	"id" uuid NOT NULL DEFAULT gen_random_uuid(),
	"createdAt" timestamptz NOT NULL DEFAULT now(),
	"planedPaymentEach" text,
	"planedPaymentIteration" int2,
	"name" text NOT NULL,
	"description" text,
	"amount" money NOT NULL,
	"date" timestamptz NOT NULL DEFAULT now(),
	"type" text NOT NULL,
	"walletId" uuid NOT NULL,
	"categoryId" uuid NOT NULL,
	"userId" uuid NOT NULL,
	PRIMARY KEY ("id"),
	FOREIGN KEY ("walletId") REFERENCES "public"."wallets"("id") ON UPDATE restrict ON DELETE restrict,
	FOREIGN KEY ("categoryId") REFERENCES "public"."categories"("id") ON UPDATE restrict ON DELETE restrict,
	FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON UPDATE restrict ON DELETE restrict,
	UNIQUE ("id")
);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."transaction_labels" (
	"labelId" uuid NOT NULL,
	"transactionId" uuid NOT NULL,
	PRIMARY KEY ("labelId", "transactionId"),
	FOREIGN KEY ("labelId") REFERENCES "public"."labels"("id") ON UPDATE restrict ON DELETE restrict,
	FOREIGN KEY ("transactionId") REFERENCES "public"."transactions"("id") ON UPDATE restrict ON DELETE restrict
);
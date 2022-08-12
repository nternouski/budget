alter table "public"."transactions" drop constraint "transactions_walletId_fkey",
  add constraint "transactions_walletId_fkey"
  foreign key ("walletId")
  references "public"."wallets"
  ("id") on update restrict on delete cascade;

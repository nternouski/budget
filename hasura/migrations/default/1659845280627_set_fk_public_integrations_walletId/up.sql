alter table "public"."integrations" drop constraint "integrations_walletId_fkey",
  add constraint "integrations_walletId_fkey"
  foreign key ("walletId")
  references "public"."wallets"
  ("id") on update restrict on delete cascade;

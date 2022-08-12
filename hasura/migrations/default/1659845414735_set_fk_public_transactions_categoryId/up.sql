alter table "public"."transactions" drop constraint "transactions_categoryId_fkey",
  add constraint "transactions_categoryId_fkey"
  foreign key ("categoryId")
  references "public"."categories"
  ("id") on update restrict on delete cascade;

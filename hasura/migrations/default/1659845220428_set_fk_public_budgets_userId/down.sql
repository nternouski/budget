alter table "public"."budgets" drop constraint "budgets_userId_fkey",
  add constraint "budgets_userId_fkey"
  foreign key ("userId")
  references "public"."users"
  ("id") on update restrict on delete restrict;
